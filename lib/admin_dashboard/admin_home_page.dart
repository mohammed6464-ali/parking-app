import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/admin_dashboard/admin_add_parking.dart';

/// Dashboard Page — English, matching your Home screen design
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Tokens
  static const kBlue = Color(0xFF3F7CFF);
  static const kBg = Color(0xFFF4F6F9);

  // ------- Mock lots -------
  final List<ParkingLot> lots = const [
    ParkingLot(id: 'l1', name: 'SolarPark Hub', location: 'Jeddah North', totalSpots: 120),
    ParkingLot(id: 'l2', name: 'Skyline Parking', location: 'Jeddah Center', totalSpots: 80),
    ParkingLot(id: 'l3', name: 'City Center Garage', location: 'Jeddah South', totalSpots: 150),
  ];

  // ------- Mock data -------
  late List<CarEntry> allCars;
  late List<RevenueEntry> allRevenue;

  // ------- Filters -------
  String? selectedLotId;             // null => all
  DateTimeRange? selectedRange;      // default last 7 days
  String carSearch = '';

  @override
  void initState() {
    super.initState();
    allCars = _buildMockCars();
    allRevenue = _buildMockRevenue();
    selectedRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now(),
    );
  }

  // ------- Derived data -------
  Iterable<CarEntry> get _filteredCars {
    Iterable<CarEntry> list = allCars;

    if (selectedLotId != null) {
      list = list.where((c) => c.lotId == selectedLotId);
    }

    if (selectedRange != null) {
      final s = DateTime(selectedRange!.start.year, selectedRange!.start.month, selectedRange!.start.day);
      final e = DateTime(selectedRange!.end.year, selectedRange!.end.month, selectedRange!.end.day).add(const Duration(days: 1));
      list = list.where((c) => !c.entryAt.isBefore(s) && c.entryAt.isBefore(e));
    }

    if (carSearch.trim().isNotEmpty) {
      final q = carSearch.toLowerCase();
      list = list.where((c) =>
          c.plate.toLowerCase().contains(q) ||
          c.color.toLowerCase().contains(q) ||
          c.modelName.toLowerCase().contains(q) ||
          c.ownerName.toLowerCase().contains(q) ||
          c.ownerPhone.toLowerCase().contains(q) ||
          c.spotCode.toLowerCase().contains(q)); // ← search by spot
    }

    return list;
  }

  int get _occupiedSpots => _filteredCars.where((c) => c.exitAt == null).length;

  int get _totalSpots {
    if (selectedLotId == null) {
      return lots.fold<int>(0, (sum, l) => sum + l.totalSpots);
    }
    return lots.firstWhere((l) => l.id == selectedLotId).totalSpots;
  }

  int get _availableSpots => _totalSpots - _occupiedSpots;

  double get _revenueDaily {
    final now = DateTime.now();
    final d0 = DateTime(now.year, now.month, now.day);
    final d1 = d0.add(const Duration(days: 1));
    return allRevenue
        .where((r) => selectedLotId == null || r.lotId == selectedLotId)
        .where((r) => !r.date.isBefore(d0) && r.date.isBefore(d1))
        .fold(0.0, (s, r) => s + r.amount);
  }

  double get _revenueMonthly {
    final now = DateTime.now();
    final m0 = DateTime(now.year, now.month, 1);
    final m1 = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);
    return allRevenue
        .where((r) => selectedLotId == null || r.lotId == selectedLotId)
        .where((r) => !r.date.isBefore(m0) && r.date.isBefore(m1))
        .fold(0.0, (s, r) => s + r.amount);
  }

  double get _revenueInSelectedRange {
    if (selectedRange == null) return 0;
    final s = DateTime(selectedRange!.start.year, selectedRange!.start.month, selectedRange!.start.day);
    final e = DateTime(selectedRange!.end.year, selectedRange!.end.month, selectedRange!.end.day).add(const Duration(days: 1));
    return allRevenue
        .where((r) => selectedLotId == null || r.lotId == selectedLotId)
        .where((r) => !r.date.isBefore(s) && r.date.isBefore(e))
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  // ------- UI -------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Container(height: 220, color: kBlue),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _circleIcon(Icons.add, onTap: (){Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddParkingPlacePage(),
                            ),
                          );}),
                      const SizedBox(width: 12),
                      _circleIcon(Icons.date_range, onTap: _pickDateRange),
                      const SizedBox(width: 12),
                      _circleIcon(Icons.filter_alt_rounded, onTap: () => _openFilterSheet(context)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _filtersCard(),

                  const SizedBox(height: 14),

                  // KPIs
                  Row(
                    children: [
                      _kpiCard(title: 'Available Spots', value: _availableSpots.toString(), icon: Icons.event_available, bg: const Color(0xFFEAF7F0)),
                      _kpiCard(title: 'Occupied Spots', value: _occupiedSpots.toString(), icon: Icons.local_parking, bg: const Color(0xFFFFEFEA)),
                      _kpiCard(title: 'Total Capacity', value: _totalSpots.toString(), icon: Icons.layers, bg: const Color(0xFFE9F1FF)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      _kpiCard(title: 'Today Revenue', value: _currency(_revenueDaily), icon: Icons.payments, bg: const Color(0xFFEFF7FF)),
                      _kpiCard(title: 'This Month', value: _currency(_revenueMonthly), icon: Icons.calendar_month, bg: const Color(0xFFF2F4F7)),
                      _kpiCard(title: 'Selected Range', value: _currency(_revenueInSelectedRange), icon: Icons.timeline, bg: const Color(0xFFFFF3DB)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _carsHeader(),
                  const SizedBox(height: 6),
                  _carsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------- Sections -------
  Widget _filtersCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String?>(
            value: selectedLotId,
            decoration: const InputDecoration(
              labelText: 'Parking Lot',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('All lots')),
              ...lots.map((l) => DropdownMenuItem<String?>(value: l.id, child: Text('${l.name} – ${l.location}'))),
            ],
            onChanged: (v) => setState(() => selectedLotId = v),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDateRange,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date Range',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              child: Text(_rangeLabel()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carsHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Registered Cars', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            width: 200,
            child: TextField(
              onChanged: (v) => setState(() => carSearch = v),
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search),
                hintText: 'Search (plate, name, phone, spot...)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carsList() {
    final rows = _filteredCars.toList()..sort((a, b) => b.entryAt.compareTo(a.entryAt));
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No cars within the current filters')),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, i) {
        final c = rows[i];
        final lot = lots.firstWhere((l) => l.id == c.lotId);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header chips (lot + dynamic color + spot code)
              Row(
                children: [
                  _chip(text: lot.name),
                  const SizedBox(width: 8),
                  _colorChip(c.color),
                  const SizedBox(width: 8),
                  _spotChip(c.spotCode),
                ],
              ),
              const SizedBox(height: 10),

              // Details (+ Paid inside the details with same yellow look)
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _kv('Plate', c.plate, boldValue: true),
                  _kv('Model', c.modelName),
                  _kv('Owner', c.ownerName),
                  _kv('Owner Phone', c.ownerPhone, nowrap: true),
                  _kv('Spot', c.spotCode, boldValue: true),       // ← NEW in details
                  _kv('Entry', _fmt(c.entryAt)),
                  _kv('Exit', c.exitAt == null ? 'In lot' : _fmt(c.exitAt!)),
                  _kvPill('Paid', _currency(c.paidAmount)),        // money inside details
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: rows.length,
    );
  }

  // ------- Reusable bits -------
  Widget _kpiCard({required String title, required String value, required IconData icon, Color bg = Colors.white}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Colors.black87), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)))]),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, {bool nowrap = false, bool boldValue = false}) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            Expanded(
              child: Text(
                v,
                maxLines: nowrap ? 1 : null,
                softWrap: !nowrap ? true : false,
                overflow: nowrap ? TextOverflow.ellipsis : TextOverflow.visible,
                style: TextStyle(fontWeight: boldValue ? FontWeight.w700 : FontWeight.w400),
              ),
            ),
          ],
        ),
      );

  // Paid pill (نفس لون البادج السابق)
  Widget _kvPill(String k, String v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3DB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3A83C).withOpacity(.4)),
        ),
        child: Text('$k: $v', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
      );

  // عادية (ازرق فاتح)
  Widget _chip({required String text}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F1FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      );

  // ديناميكية حسب اسم اللون
  Widget _colorChip(String colorName) {
    final n = colorName.toLowerCase().trim();
    final base = _namedColor(n);

    if (n == 'white') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E6ED)),
        ),
        child: const Text('White', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
      );
    }

    final bg = base.withOpacity(.16);
    final border = base.withOpacity(.28);
    final isDark = base.computeLuminance() < 0.3;
    final fg = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Text(
        _capitalize(colorName),
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  // كابسولة كود المكان
  Widget _spotChip(String code) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD7DDF2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.place_rounded, size: 16, color: Color(0xFF5D6BFF)),
            SizedBox(width: 6),
            // النص بيتضاف من الأب لأننا بنحتاج String code، فهنحطه برة:
          ],
        ),
      );

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _namedColor(String n) {
    switch (n) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'black':
        return Colors.black87;
      case 'white':
        return Colors.white;
      case 'silver':
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.amber;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'purple':
        return Colors.purple;
      default:
        return kBlue; // fallback
    }
  }

  Widget _circleIcon(IconData icon, {VoidCallback? onTap}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(color: Color(0xFFEFF2F7), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black87),
        ),
      );

  // ------- Helpers -------
  Future<void> _openFilterSheet(BuildContext context) async {
    String? tmpLot = selectedLotId;
    DateTimeRange? tmpRange = selectedRange;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
            ]),
            const Divider(height: 20),

            const Text('Parking Lot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: tmpLot,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('All lots')),
                ...lots.map((l) => DropdownMenuItem<String?>(value: l.id, child: Text('${l.name} – ${l.location}'))),
              ],
              onChanged: (v) => setS(() => tmpLot = v),
            ),

            const SizedBox(height: 16),
            const Text('Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final res = await _pickDateRangeInternal(context, tmpRange);
                if (res != null) setS(() => tmpRange = res);
              },
              icon: const Icon(Icons.date_range),
              label: Text(tmpRange == null ? 'Select range' : _rangeLabel(range: tmpRange)),
            ),

            const SizedBox(height: 10),
            const Divider(),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setS(() {
                    tmpLot = null;
                    tmpRange = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 6)), end: DateTime.now());
                  }),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: const StadiumBorder()),
                  child: const Text('Reset', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedLotId = tmpLot;
                      selectedRange = tmpRange;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: const StadiumBorder(), backgroundColor: kBlue),
                  child: const Text('Apply', style: TextStyle(color: Colors.white)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final res = await _pickDateRangeInternal(context, selectedRange);
    if (res != null) setState(() => selectedRange = res);
  }

  Future<DateTimeRange?> _pickDateRangeInternal(BuildContext ctx, DateTimeRange? initial) async {
    final now = DateTime.now();
    return showDateRangePicker(
      context: ctx,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial ?? DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
      saveText: 'Apply',
      helpText: 'Select a date range',
    );
  }

  String _rangeLabel({DateTimeRange? range}) {
    final r = range ?? selectedRange;
    if (r == null) return '—';
    final s = r.start;
    final e = r.end;
    String fmt(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
    return '${fmt(s)} → ${fmt(e)}';
  }

  String _currency(double v) => '${v.toStringAsFixed(2)} SAR';
  String _fmt(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // ------- Mock builders -------
  List<CarEntry> _buildMockCars() {
    final now = DateTime.now();
    return [
      CarEntry(lotId: 'l1', plate: 'JDD-1234', color: 'Blue',   modelName: 'Hyundai Elantra', ownerName: 'Ahmed Ali',  ownerPhone: '+966500000001', entryAt: now.subtract(const Duration(hours: 3)),  exitAt: null,                                paidAmount: 22.0, spotCode: 'A1'),
      CarEntry(lotId: 'l2', plate: 'JDD-9921', color: 'White',  modelName: 'Toyota Camry',     ownerName: 'Sara Mohamed', ownerPhone: '+966500000002', entryAt: now.subtract(const Duration(hours: 7)),  exitAt: now.subtract(const Duration(hours: 1)), paidAmount: 18.5, spotCode: 'B1'),
      CarEntry(lotId: 'l3', plate: 'JDD-5552', color: 'Black',  modelName: 'Kia Sportage',     ownerName: 'Hassan T.',     ownerPhone: '+966500000003', entryAt: now.subtract(const Duration(days: 1, hours: 5)), exitAt: now.subtract(const Duration(days: 1, hours: 1)), paidAmount: 35.0, spotCode: 'C4'),
      CarEntry(lotId: 'l1', plate: 'JDD-7788', color: 'Red',    modelName: 'Honda Civic',      ownerName: 'Mona S.',       ownerPhone: '+966500000004', entryAt: now.subtract(const Duration(hours: 2)),  exitAt: null,                                paidAmount: 12.0, spotCode: 'A7'),
      CarEntry(lotId: 'l2', plate: 'JDD-0012', color: 'Silver', modelName: 'Ford Focus',       ownerName: 'Mohamed M.',    ownerPhone: '+966500000005', entryAt: now.subtract(const Duration(days: 3)),   exitAt: now.subtract(const Duration(days: 2, hours: 20)), paidAmount: 40.0, spotCode: 'B9'),
    ];
  }

  List<RevenueEntry> _buildMockRevenue() {
    final List<RevenueEntry> list = [];
    final today = DateTime.now();
    for (int i = 0; i < 40; i++) {
      final d = today.subtract(Duration(days: i));
      for (final lot in lots) {
        final amount = 500 + (lot.totalSpots * 0.8) - (i * 2); // demo only
        list.add(RevenueEntry(lotId: lot.id, date: DateTime(d.year, d.month, d.day), amount: amount.clamp(100, 5000).toDouble()));
      }
    }
    return list;
  }
}

// ------- Models -------
class ParkingLot {
  final String id;
  final String name;
  final String location;
  final int totalSpots;
  const ParkingLot({required this.id, required this.name, required this.location, required this.totalSpots});
}

class CarEntry {
  final String lotId;
  final String plate;
  final String color;
  final String modelName;
  final String ownerName;
  final String ownerPhone;
  final DateTime entryAt;
  final DateTime? exitAt;
  final double paidAmount;
  final String spotCode; // NEW
  const CarEntry({
    required this.lotId,
    required this.plate,
    required this.color,
    required this.modelName,
    required this.ownerName,
    required this.ownerPhone,
    required this.entryAt,
    this.exitAt,
    required this.paidAmount,
    required this.spotCode,
  });
}

class RevenueEntry {
  final String lotId;
  final DateTime date; // yyyy-mm-dd (00:00)
  final double amount; // SAR
  const RevenueEntry({required this.lotId, required this.date, required this.amount});
}