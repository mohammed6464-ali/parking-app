import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/home_pages/book_parking_page.dart';

// ===== موديل المركبة (غيّره لموديلك لو عندك) =====
class Vehicle {
  final String name;
  final String plate;
  final Color color;
  Vehicle({required this.name, required this.plate, this.color = Colors.blue});
}

/// صفحة حجز باركينج بتاريخ بداية ونهاية + أوقات
class BookParkingDetailPage extends StatefulWidget {
  final double pricePerHour;
  final Vehicle? initialVehicle;

  const BookParkingDetailPage({
    super.key,
    required this.pricePerHour,
    this.initialVehicle,
  });

  @override
  State<BookParkingDetailPage> createState() => _BookParkingDetailPageState();
}

class _BookParkingDetailPageState extends State<BookParkingDetailPage> {
  static const kBlue = Color(0xFF3F7CFF);

  // مدى التاريخ: من/إلى
  late DateTimeRange _range;

  // أوقات اليوم الأول/الأخير
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime   = const TimeOfDay(hour: 13, minute: 0);

  Vehicle? _vehicle;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _range = DateTimeRange(
      start: DateTime(today.year, today.month, today.day),
      end: DateTime(today.year, today.month, today.day), // نفس اليوم كبداية
    );
    _vehicle = widget.initialVehicle ??
        Vehicle(name: 'Jetour Dashing', plate: 'B 1234 XY');
  }

  // ضمّ تاريخ + وقت
  DateTime _compose(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  // الساعات الكلية بين (startDate+time) و (endDate+time)
  double get _totalHours {
    final from = _compose(_range.start, _startTime);
    var to     = _compose(_range.end, _endTime);

    // لو المستخدم اختار نفس اليوم لكن وقت النهاية <= البداية، هنفترض يوم واحد زيادة
    if (!to.isAfter(from)) {
      to = to.add(const Duration(days: 1));
    }

    return to.difference(from).inMinutes / 60.0;
  }

  double get _totalPrice => _totalHours * widget.pricePerHour;

  // عدد الأيام (مجرّد عرض)
  int get _daysCount {
    // الفرق بالتواريخ (شامل الطرفين)
    final a = DateTime(_range.start.year, _range.start.month, _range.start.day);
    final b = DateTime(_range.end.year, _range.end.month, _range.end.day);
    final d = b.difference(a).inDays;
    return (d == 0) ? 1 : d + 1;
  }

  // Pick date range
  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
      helpText: 'Select booking range',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: kBlue,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(context: context, initialTime: _startTime);
    if (t != null) setState(() => _startTime = t);
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(context: context, initialTime: _endTime);
    if (t != null) setState(() => _endTime = t);
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h.$m $p';
  }

  String _fmtDate(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: kBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Book Parking Detail',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const Text('Select Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 10),

          // بطاقة اختيار المدى
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صف يبيّن من/إلى + زر تغيير
                Row(
                  children: [
                    Expanded(
                      child: _DatePill(
                        label: 'From',
                        value: _fmtDate(_range.start),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DatePill(
                        label: 'To',
                        value: _fmtDate(_range.end),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _pickRange,
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Color(0xFFE2E6ED)),
                    ),
                    icon: const Icon(Icons.date_range_rounded),
                    label: const Text('Select Booking Range'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Days: $_daysCount day(s)',
                  style: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Start / End hour
          Row(
            children: [
              Expanded(child: _TimeField(label: 'Start hour', value: _fmtTime(_startTime), onTap: _pickStartTime)),
              const SizedBox(width: 12),
              Expanded(child: _TimeField(label: 'End hour', value: _fmtTime(_endTime), onTap: _pickEndTime)),
            ],
          ),

          const SizedBox(height: 18),

          // Vehicle
          const Text('Vehicle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 10),
          _VehicleTile(
            vehicle: _vehicle!,
            onChange: () async {
              // افتح صفحة اختيار المركبة الخاصة بك هنا لو موجودة
              final chosen = await showDialog<Vehicle>(
                context: context,
                builder: (_) => _DummyVehicleChooser(current: _vehicle!),
              );
              if (chosen != null) setState(() => _vehicle = chosen);
            },
          ),

          const SizedBox(height: 12),

          // Total price
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Total Price',
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w700)),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$${_totalPrice.toStringAsFixed(2)} ',
                        style: const TextStyle(color: kBlue, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: '/ ${_totalHours.toStringAsFixed(1)} hours',
                        style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        color: Colors.white,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PickParkingSpotPage()),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue,
              shape: const StadiumBorder(),
            ),
            child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// ------------- Widgets مساعدة -------------

class _DatePill extends StatelessWidget {
  final String label;
  final String value;
  const _DatePill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E6ED)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_outlined, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _TimeField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E6ED)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, color: Colors.black54),
                const SizedBox(width: 10),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onChange;
  const _VehicleTile({required this.vehicle, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3F7CFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: vehicle.color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text(vehicle.plate, style: const TextStyle(color: Color(0xFF5D79C0), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onChange,
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: Color(0xFFBFC6D4)),
            ),
            child: const Text('Change', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

// بديل بسيط لاختيار مركبة (بدون صفحة حقيقية)
class _DummyVehicleChooser extends StatelessWidget {
  final Vehicle current;
  const _DummyVehicleChooser({required this.current});

  @override
  Widget build(BuildContext context) {
    final options = [
      current,
      Vehicle(name: 'Land Cruiser', plate: 'D 5678 AB', color: Colors.black87),
      Vehicle(name: 'Kia Sportage', plate: 'P 1679 AB', color: const Color(0xFFE53935)),
    ];
    return AlertDialog(
      title: const Text('Select Vehicle'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((v) {
            return ListTile(
              leading: const Icon(Icons.directions_car_filled),
              title: Text(v.name),
              subtitle: Text(v.plate),
              onTap: () => Navigator.pop(context, v),
            );
          }).toList(),
        ),
      ),
    );
  }
}
