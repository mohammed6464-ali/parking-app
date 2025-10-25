import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/home_pages/reseet_page.dart';

class PickParkingSpotPage extends StatefulWidget {
  const PickParkingSpotPage({super.key});
  @override
  State<PickParkingSpotPage> createState() => _PickParkingSpotPageState();
}

/* ================== Models ================== */
enum SpotStatus { reserved, empty, withCar }

class _Spot {
  final String code;
  final SpotStatus status;
  const _Spot(this.code, this.status);

  // فقط اللي عليها عربية زرقاء هي المتاحة
  bool get reservable => status == SpotStatus.withCar;
  bool get hasCar => status == SpotStatus.withCar;
}

/* ================== Page ================== */
class _PickParkingSpotPageState extends State<PickParkingSpotPage> {
  static const kBlue = Color(0xFF3F7CFF);
  static const kGreen = Color(0xFF37B26C);

  final List<String> _floors = ['1st Floor', '2nd Floor', '3rd Floor', '4th Floor'];
  late String _selectedFloor;

  late List<_Spot> _spots; // grid spots for current floor
  String? _selectedCode;   // currently selected spot code

  @override
  void initState() {
    super.initState();
    _selectedFloor = _floors[1]; // 2nd floor default
    _loadFloor(_selectedFloor);
  }

  void _loadFloor(String floor) {
    // NOTE: غيّر البيانات كما تحب لكل دور
    if (floor == '2nd Floor') {
      _spots = const [
        // A-row
        _Spot('A-1', SpotStatus.empty),
        _Spot('A-2', SpotStatus.empty),
        _Spot('A-3', SpotStatus.empty),
        _Spot('A-4', SpotStatus.withCar),
        // B-row
        _Spot('B-1', SpotStatus.empty),
        _Spot('B-2', SpotStatus.empty),
        _Spot('B-3', SpotStatus.withCar),
        _Spot('B-4', SpotStatus.withCar),
        // B-row 2
        _Spot('B-5', SpotStatus.empty),
        _Spot('B-6', SpotStatus.withCar),
        _Spot('B-7', SpotStatus.reserved),
        _Spot('B-8', SpotStatus.empty),
      ];
      _selectedCode = 'B-3';
    } else if (floor == '1st Floor') {
      _spots = const [
        _Spot('A-1', SpotStatus.withCar),
        _Spot('A-2', SpotStatus.empty),
        _Spot('A-3', SpotStatus.reserved),
        _Spot('A-4', SpotStatus.reserved),
        _Spot('B-1', SpotStatus.empty),
        _Spot('B-2', SpotStatus.withCar),
        _Spot('B-3', SpotStatus.reserved),
        _Spot('B-4', SpotStatus.empty),
        _Spot('B-5', SpotStatus.empty),
        _Spot('B-6', SpotStatus.empty),
        _Spot('B-7', SpotStatus.withCar),
        _Spot('B-8', SpotStatus.empty),
      ];
      _selectedCode = null;
    } else if (floor == '3rd Floor') {
      _spots = const [
        _Spot('A-1', SpotStatus.empty),
        _Spot('A-2', SpotStatus.reserved),
        _Spot('A-3', SpotStatus.withCar),
        _Spot('A-4', SpotStatus.empty),
        _Spot('B-1', SpotStatus.withCar),
        _Spot('B-2', SpotStatus.empty),
        _Spot('B-3', SpotStatus.empty),
        _Spot('B-4', SpotStatus.withCar),
        _Spot('B-5', SpotStatus.reserved),
        _Spot('B-6', SpotStatus.empty),
        _Spot('B-7', SpotStatus.empty),
        _Spot('B-8', SpotStatus.withCar),
      ];
      _selectedCode = null;
    } else {
      // 4th floor
      _spots = const [
        _Spot('A-1', SpotStatus.reserved),
        _Spot('A-2', SpotStatus.empty),
        _Spot('A-3', SpotStatus.withCar),
        _Spot('A-4', SpotStatus.withCar),
        _Spot('B-1', SpotStatus.empty),
        _Spot('B-2', SpotStatus.reserved),
        _Spot('B-3', SpotStatus.withCar),
        _Spot('B-4', SpotStatus.empty),
        _Spot('B-5', SpotStatus.empty),
        _Spot('B-6', SpotStatus.empty),
        _Spot('B-7', SpotStatus.withCar),
        _Spot('B-8', SpotStatus.reserved),
      ];
      _selectedCode = null;
    }
    setState(() {});
  }

  int get _availableCount => _spots.where((s) => s.reservable).length;

  void _onSelect(String code) {
    final spot = _spots.firstWhere((s) => s.code == code);
    if (!spot.reservable && code != _selectedCode) return; // لا تختار المحجوز
    setState(() => _selectedCode = code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: kBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Pick Parking Spot',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),

      body: Column(
        children: [
          // Header (floor + available)
          Container(
            width: double.infinity,
            color: kBlue,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                _FloorDropdown(
                  floors: _floors,
                  value: _selectedFloor,
                  onChanged: (v) {
                    if (v == null) return;
                    _selectedFloor = v;
                    _loadFloor(v);
                  },
                ),
                const Spacer(),
                Text(
                  '$_availableCount Available',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // Grid (scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  _GridSection(
                    titleRowCodes: const ['A-1','A-2','A-3','A-4'],
                    spots: _spots,
                    selectedCode: _selectedCode,
                    onSelect: _onSelect,
                  ),
                  const _EntryExitLine(),
                  _GridSection(
                    titleRowCodes: const ['B-1','B-2','B-3','B-4'],
                    spots: _spots,
                    selectedCode: _selectedCode,
                    onSelect: _onSelect,
                  ),
                  _GridSection(
                    titleRowCodes: const ['B-5','B-6','B-7','B-8'],
                    spots: _spots,
                    selectedCode: _selectedCode,
                    onSelect: _onSelect,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        color: Colors.white,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: (){
               Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ReviewSummaryPage(
      placeName: 'Jakarta Parking',
      placeAddress: 'St. Jakarta Sudirman no. 17',
      vehicleName: 'Speedster X',
      vehiclePlate: 'B 1234 XY',
      floorLabel: '2nd Floor',
      spotCode: 'B-3',
      start: DateTime(2025, 2, 12, 9, 0),   // 09:00 AM
      end:   DateTime(2025, 2, 12, 13, 0),  // 01:00 PM
      pricePerHour: 3.00,
      initialPayment: 'Paypal',
    ),
  ),
);

            },
                  
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue,
              shape: const StadiumBorder(),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------- Widgets ---------------- */

class _FloorDropdown extends StatelessWidget {
  final List<String> floors;
  final String value;
  final ValueChanged<String?> onChanged;
  const _FloorDropdown({required this.floors, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white38),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          onChanged: onChanged,
          items: floors
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f, style: const TextStyle(color: Colors.black)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _GridSection extends StatelessWidget {
  final List<String> titleRowCodes;
  final List<_Spot> spots;
  final String? selectedCode;
  final ValueChanged<String> onSelect;

  const _GridSection({
    required this.titleRowCodes,
    required this.spots,
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final rowSpots =
        titleRowCodes.map((c) => spots.firstWhere((s) => s.code == c)).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: rowSpots.map((s) {
          final isSelected = selectedCode == s.code;
          return Expanded(
            child: _SpotTile(
              spot: s,
              selected: isSelected,
              onTap: () => onSelect(s.code),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SpotTile extends StatelessWidget {
  final _Spot spot;
  final bool selected;
  final VoidCallback onTap;
  const _SpotTile({required this.spot, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFE6F0FF) : Colors.white;

    final carColor = spot.hasCar ? const Color(0xFF3F7CFF) : Colors.grey.shade400;
    final codeBg = selected ? Colors.black : Colors.white;
    final codeFg = selected ? Colors.white : Colors.black87;

    final canTap = spot.reservable || selected;

    return InkWell(
      onTap: canTap ? onTap : null,
      child: Container(
        height: 168, // ثابت لتجنّب overflow
        decoration: BoxDecoration(
          color: bg,
          border: Border(right: BorderSide(color: Colors.grey.shade200)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // كود المكان
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: codeBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(spot.code,
                  style: TextStyle(color: codeFg, fontWeight: FontWeight.w700)),
            ),

            // أيقونة العربية
            Icon(Icons.directions_car_filled, size: 48, color: carColor),

            // الحالة/التحديد
            if (selected)
              Column(
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFF3F7CFF)),
                  SizedBox(height: 4),
                  Text('Selected',
                      style:
                          TextStyle(color: Color(0xFF3F7CFF), fontWeight: FontWeight.w700)),
                ],
              )
            else
              Text(
                spot.reservable ? 'Available' : 'Reserved',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: spot.reservable ? _PickParkingSpotPageState.kGreen : Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EntryExitLine extends StatelessWidget {
  const _EntryExitLine();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Text('Entry',
              style: TextStyle(color: Color(0xFFDAA14C), fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(builder: (_, c) {
              return CustomPaint(
                painter: _DashedLinePainter(color: Colors.grey.shade400),
                size: Size(c.maxWidth, 1),
              );
            }),
          ),
          const SizedBox(width: 8),
          const Text('Exit',
              style: TextStyle(color: Color(0xFFD66B6B), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0, dashSpace = 6.0;
    double startX = 0;
    final paint = Paint()..color = color..strokeWidth = 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
