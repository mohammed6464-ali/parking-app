import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SessionPage(),
    ));

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});
  @override
  State<SessionPage> createState() => _SessionPageState();
}

/* ==================== Model ==================== */
class ParkingSession {
  final String title;
  final String address;
  final String floorSpot; // e.g. "2nd Floor (B-3)"
  final String vehicle;   // e.g. "Speedster X (B 1234 XY)"
  final double pricePerHour;
  DateTime start;
  DateTime end;

  ParkingSession({
    required this.title,
    required this.address,
    required this.floorSpot,
    required this.vehicle,
    required this.pricePerHour,
    required this.start,
    required this.end,
  });

  double get hours => end.difference(start).inMinutes / 60.0;
  double get amount => hours * pricePerHour;

  Duration get timeLeft => end.difference(DateTime.now());
  bool get isOngoing => timeLeft.inMilliseconds > 0;
}

/* ==================== Page ==================== */
class _SessionPageState extends State<SessionPage> {
  static const kBlue = Color(0xFF3F7CFF);

  // تبويب
  bool _ongoingTab = true;

  // بيانات تجربة
  final List<ParkingSession> _sessions = [
    ParkingSession(
      title: 'SolarPark Hub',
      address: '123 Green Energy St, Sunnyville, CA',
      floorSpot: '2nd Floor (B-3)',
      vehicle: 'Speedster X (B 1234 XY)',
      pricePerHour: 10.0,
      start: DateTime.now().subtract(const Duration(minutes: 30)),
      end: DateTime.now().add(const Duration(minutes: 30)),
    ),
    ParkingSession(
      title: 'Cilandak Parking',
      address: '123 Green Energy St, Sunnyville, CA',
      floorSpot: '2nd Floor (B-3)',
      vehicle: 'Speedster X (B 1234 XY)',
      pricePerHour: 10.0,
      start: DateTime.now().subtract(const Duration(hours: 1)),
      end: DateTime.now().add(const Duration(minutes: 30)),
    ),
    // تاريخ (منتهي)
    ParkingSession(
      title: 'Downtown Garage',
      address: '45 Sunset Blvd, Downtown, CA',
      floorSpot: 'B1 (A-4)',
      vehicle: 'Urban Cruiser (D 5678 AB)',
      pricePerHour: 8.0,
      start: DateTime.now().subtract(const Duration(hours: 5)),
      end: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // عدّاد يحدث الشاشة كل ثانية لعرض Time Left
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  List<ParkingSession> get _filtered =>
      _sessions.where((s) => _ongoingTab ? s.isOngoing : !s.isOngoing).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Stack(
        children: [
          Container(height: 220, color: kBlue),
          SafeArea(
            child: Column(
              children: [
                // Header
                // Header
Padding(
  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
  child: Row(
    children: [
      // 🔹 زر الرجوع
      InkWell(
        onTap: () => Navigator.pop(context), // <-- بيرجع للهوم
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white30),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
      ),
      const SizedBox(width: 12),

      // 🔹 عنوان الصفحة
      const Expanded(
        child: Text(
          'Session',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // 🔹 أيقونة البحث
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30),
        ),
        child: const Icon(Icons.search, color: Colors.white),
      ),
    ],
  ),
),

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      children: [
                        _TabPill(
                          title: 'On Going',
                          selected: _ongoingTab,
                          onTap: () => setState(() => _ongoingTab = true),
                        ),
                        _TabPill(
                          title: 'History',
                          selected: !_ongoingTab,
                          onTap: () => setState(() => _ongoingTab = false),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final s = _filtered[i];
                      return _SessionCard(
                        session: s,
                        onDetail: () => _openDetailSheet(s),
                        onExtend: s.isOngoing ? () => _openExtendSheet(s) : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* ======== BottomSheets ======== */

  void _openDetailSheet(ParkingSession s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _grabber(),
              const SizedBox(height: 8),
              Row(
                children: [
                  _thumb(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(s.address, style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  Text('\$${s.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              _kv('Floor / Spot', s.floorSpot),
              _kv('Vehicle', s.vehicle),
              _kv('Start', _fmtDT(s.start)),
              _kv('End', _fmtDT(s.end)),
              _kv('Duration', '${s.hours.toStringAsFixed(1)} hours'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _openExtendSheet(ParkingSession s) {
    int extraMinutes = 30;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final extraHours = extraMinutes / 60.0;
          final extraCost = extraHours * s.pricePerHour;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _grabber(),
                const SizedBox(height: 6),
                const Text('Extend Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Extra Minutes', style: TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('$extraMinutes min',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                Slider(
                  value: extraMinutes.toDouble(),
                  min: 15,
                  max: 240,
                  divisions: (240 - 15) ~/ 15,
                  label: '$extraMinutes',
                  onChanged: (v) => setSheet(() => extraMinutes = (v / 15).round() * 15),
                  activeColor: kBlue,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Extra Cost', style: TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('\$${extraCost.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: kBlue)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => s.end = s.end.add(Duration(minutes: extraMinutes)));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          );
        });
      },
    );
  }

  /* ======== helpers ======== */
  String _fmtDT(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final p = d.hour < 12 ? 'AM' : 'PM';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  $h:$m $p';
    // عدّل التنسيق اللي يعجبك
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(k, style: const TextStyle(color: Colors.black54))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );

  Widget _thumb() => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          color: const Color(0xFFE9EDF7),
          child: const Icon(Icons.image, color: Colors.black38),
        ),
      );

  Widget _grabber() => Center(
        child: Container(
          width: 42,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFE1E5EE),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
}

/* ==================== Widgets ==================== */

class _TabPill extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: selected
                ? const [BoxShadow(color: Color(0x2A000000), blurRadius: 8, offset: Offset(0, 2))]
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final ParkingSession session;
  final VoidCallback onDetail;
  final VoidCallback? onExtend;

  const _SessionCard({
    required this.session,
    required this.onDetail,
    required this.onExtend,
  });

  @override
  Widget build(BuildContext context) {
    final price = '\$${session.amount.toStringAsFixed(2)}';
    final ongoing = session.isOngoing;
    final timeLeft = session.timeLeft;

    String timeLeftText() {
      if (!ongoing) return 'Ended';
      final h = timeLeft.inHours;
      final m = timeLeft.inMinutes % 60;
      final s = timeLeft.inSeconds % 60;
      if (h > 0) return '$h h ${m.toString().padLeft(2, '0')} m';
      return '${m.toString().padLeft(2, '0')} min ${s.toString().padLeft(2, '0')} s';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFE9EDF7),
                  child: const Icon(Icons.image, color: Colors.black26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(session.address, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(session.floorSpot,
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        const Icon(Icons.directions_car_filled, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(session.vehicle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: Colors.black54),
              const SizedBox(width: 8),
              const Text('Time Left', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                timeLeftText(),
                style: TextStyle(
                  color: ongoing ? const Color(0xFFFFA21A) : Colors.black45,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F7CFF),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Detail', style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: onExtend,
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Color(0xFFDEE3EC)),
                    ),
                    child: const Text('Extend Time',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
