import 'package:flutter/material.dart';

class NearbyParkingPage extends StatelessWidget {
  final String mapImagePath; // صورة الخريطة من عندك
  const NearbyParkingPage({super.key, required this.mapImagePath});

  static const Color kBlue = Color(0xFF3F7CFF);
  static const Color kBg   = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- AppBar ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  _roundIconBtn(
                    context,
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nearby Parking',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  _roundIconBtn(
                    context,
                    icon: Icons.more_horiz_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // ---------- Map + floating actions ----------
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                      child: Image.asset(
                        "assets/img/location.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // زرار locate/compass يمين
                  Positioned(
                    right: 16,
                    bottom: 90,
                    child: _floatingCircle(icon: Icons.explore_rounded),
                  ),
                  // تدرّج تفتيح أسفل الخريطة (زي الصورة)
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    height: 110,
                    child: IgnorePointer(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.white],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------- Bottom sheet (search + list) ----------
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // handle
                    Container(
                      width: 44, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search row
                    Row(
                      children: [
                        Expanded(
                          child: _SearchPill(
                            hint: 'Search Location',
                            onSubmitted: (v) {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        _circleButton(icon: Icons.search_rounded, onTap: () {}),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Nearby Location',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),

                    // List of locations
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: const [
                          _LocationTile(
                            selected: true,
                            name: 'New York Park',
                            address: 'New York no. 125',
                            distance: '1.25 km',
                          ),
                          SizedBox(height: 12),
                          _LocationTile(
                            selected: false,
                            name: 'Borough Park',
                            address: 'New York no. 125',
                            distance: '2.25 km',
                          ),
                          SizedBox(height: 12),
                          _LocationTile(
                            selected: false,
                            name: 'Riverside Parking',
                            address: 'W 79th St, NY',
                            distance: '3.10 km',
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------- helpers UI -------
  static Widget _roundIconBtn(BuildContext ctx, {required IconData icon, VoidCallback? onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ]),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  static Widget _floatingCircle({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54, height: 54,
        decoration: const BoxDecoration(color: kBlue, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  static Widget _circleButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: const BoxDecoration(color: kBlue, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onSubmitted;
  const _SearchPill({required this.hint, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: const [
          Icon(Icons.place_outlined, color: Colors.black45),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Location',
                hintStyle: TextStyle(color: Colors.black38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final bool selected;
  final String name, address, distance;
  const _LocationTile({
    required this.selected,
    required this.name,
    required this.address,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final Color border = selected ? const Color(0xFF3F7CFF) : const Color(0xFFE6EAF0);
    final Color bg     = selected ? const Color(0xFFE9F1FF) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            child: const Icon(Icons.place_outlined, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(address, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(distance, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
