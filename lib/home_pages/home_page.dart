// ignore_for_file: unused_element_parameter, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/home_pages/details_parking.dart';
import 'package:flutter_application_vallet_cars/home_pages/location_page.dart';
import 'package:flutter_application_vallet_cars/home_pages/orders_pages.dart';

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()),
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ألوان
  static const kBlue = Color(0xFF3F7CFF);
  static const kBg = Color(0xFFF4F6F9);

  // 0=Car, 1=Bike, 2=Truck, 3=Bicycle
  int selectedCat = 0;

  // البحث
  final TextEditingController _searchCtr = TextEditingController();
  String _query = '';

  // ---- فلاتر السعر والوقت (قيم العرض) ----
  // حدود عامة
  static const double kPriceMin = 0;
  static const double kPriceMax = 10; // دولار/ساعة كمثال
  static const int kTimeMin = 0;
  static const int kTimeMax = 60; // دقيقة

  // القيم المختارة حالياً
  RangeValues _priceRange = const RangeValues(0, 10);
  double get minPrice => _priceRange.start;
  double get maxPrice => _priceRange.end;

  int _maxTime = 60; // حد أقصى دقائق للوصول

  // ======== البيانات ========
  final List<_ParkItem> _allParks = const [
    _ParkItem(
      imagePath: 'assets/img/car_parking1.jpeg',
      title: 'SolarPark Hub',
      address: '123 Green Energy St, Sunnyville, CA',
      priceLabel: '\$2.5 / hr',
      spacesLabel: '12 Available',
      timeLabel: '15 min',
      pricePerHour: 2.5,
      timeToLocationMin: 15,
      categories: ['Car', 'Bike'],
    ),
    _ParkItem(
      imagePath: 'assets/img/car_parking2.jpeg',
      title: 'Skyline Parking',
      address: '45 Sunset Blvd, Downtown, CA',
      priceLabel: '\$3 / hr',
      spacesLabel: '8 Available',
      timeLabel: '10 min',
      pricePerHour: 3.0,
      timeToLocationMin: 10,
      categories: ['Car', 'Truck'],
    ),
    _ParkItem(
      imagePath: 'assets/img/car_parking3.jpeg',
      title: 'City Center Garage',
      address: '88 Central Ave, Sunnyville, CA',
      priceLabel: '\$1.8 / hr',
      spacesLabel: '20 Available',
      timeLabel: '7 min',
      pricePerHour: 1.8,
      timeToLocationMin: 7,
      categories: ['Car', 'Bike'],
    ),
    _ParkItem(
      imagePath: 'assets/img/car_parking2.jpeg',
      title: 'Two Wheels Spot',
      address: '77 Cycle Rd, Midtown, CA',
      priceLabel: '\$1 / hr',
      spacesLabel: '30 Available',
      timeLabel: '6 min',
      pricePerHour: 1.0,
      timeToLocationMin: 6,
      categories: ['Bike', 'Bicycle'],
    ),
    _ParkItem(
      imagePath: 'assets/img/car_parking1.jpeg',
      title: 'LogiTruck Yard',
      address: '19 Cargo St, Docks, CA',
      priceLabel: '\$4 / hr',
      spacesLabel: '5 Available',
      timeLabel: '18 min',
      pricePerHour: 4.0,
      timeToLocationMin: 18,
      categories: ['Truck'],
    ),
  ];

  String _catName(int idx) => ['Car', 'Bike', 'Truck', 'Bicycle'][idx];

  List<_ParkItem> get _filteredParks {
    // 1) كاتيجوري
    final name = _catName(selectedCat);
    Iterable<_ParkItem> list = _allParks.where(
      (p) => p.categories.contains(name),
    );
    // 2) السعر
    list = list.where(
      (p) => p.pricePerHour >= minPrice && p.pricePerHour <= maxPrice,
    );
    // 3) الوقت
    list = list.where((p) => p.timeToLocationMin <= _maxTime);
    // 4) البحث + startsWith أولاً
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      final starts = <_ParkItem>[];
      final contains = <_ParkItem>[];
      for (final p in list) {
        final hay = '${p.title} ${p.address}'.toLowerCase();
        if (hay.startsWith(q)) {
          starts.add(p);
        } else if (hay.contains(q)) {
          contains.add(p);
        }
      }
      list = [...starts, ...contains];
    }
    return list.toList();
  }

  // فتح شيت الفلتر
  Future<void> _openFilterSheet() async {
    int tempCat = selectedCat;
    RangeValues tempPrice = _priceRange;
    int tempTime = _maxTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Categories (Scroll أفقي)
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChipPill(
                          text: 'Car',
                          icon: Icons.directions_car_filled_outlined,
                          selected: tempCat == 0,
                          onTap: () => setSheetState(() => tempCat = 0),
                        ),
                        _FilterChipPill(
                          text: 'Bike',
                          icon: Icons.pedal_bike_rounded,
                          selected: tempCat == 1,
                          onTap: () => setSheetState(() => tempCat = 1),
                        ),
                        _FilterChipPill(
                          text: 'Truck',
                          icon: Icons.local_shipping_outlined,
                          selected: tempCat == 2,
                          onTap: () => setSheetState(() => tempCat = 2),
                        ),
                        _FilterChipPill(
                          text: 'Bicycle',
                          icon: Icons.directions_bike_rounded,
                          selected: tempCat == 3,
                          onTap: () => setSheetState(() => tempCat = 3),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Price Range
                  const Text(
                    'Price Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  RangeSlider(
                    values: tempPrice,
                    min: kPriceMin,
                    max: kPriceMax,
                    divisions: 20,
                    activeColor: kBlue,
                    labels: RangeLabels(
                      '\$${tempPrice.start.toStringAsFixed(1)}',
                      '\$${tempPrice.end.toStringAsFixed(1)}',
                    ),
                    onChanged: (v) => setSheetState(() => tempPrice = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _pill('\$${tempPrice.start.toStringAsFixed(1)}'),
                      _pill('\$${tempPrice.end.toStringAsFixed(1)}'),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Time to Location
                  const Text(
                    'Time to Location (min)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Slider(
                    value: tempTime.toDouble(),
                    min: kTimeMin.toDouble(),
                    max: kTimeMax.toDouble(),
                    divisions: kTimeMax - kTimeMin,
                    activeColor: kBlue,
                    label: '$tempTime min',
                    onChanged: (v) => setSheetState(() => tempTime = v.round()),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _pill('$tempTime min'),
                  ),

                  const SizedBox(height: 10),
                  const Divider(),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              tempCat = selectedCat;
                              tempPrice = const RangeValues(
                                kPriceMin,
                                kPriceMax,
                              );
                              tempTime = kTimeMax;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedCat = tempCat;
                              _priceRange = tempPrice;
                              _maxTime = tempTime;
                            });
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                            backgroundColor: kBlue,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Container(height: 270, color: kBlue),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header ثابت
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Good Morning John 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            _LocationRow(),
                          ],
                        ),
                      ),
                      _CircleIcon(
                        Icons.receipt_long,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SessionPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 12),
                      const _CircleIcon(Icons.person_2_outlined),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Search + Filter button
                  Row(
                    children: [
                      Expanded(
                        child: _SearchField(
                          controller: _searchCtr,
                          hint: 'Find parking area...',
                          onChanged: (v) => setState(() => _query = v),
                          onClear: () => setState(() {
                            _query = '';
                            _searchCtr.clear();
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: _openFilterSheet,
                        child: const _CircleIcon(
                          Icons.tune_rounded,
                          //bg: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Categories (ثابت)
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _CatChip(
                          text: 'Car',
                          icon: Icons.directions_car_filled_outlined,
                          selected: selectedCat == 0,
                          onTap: () => setState(() => selectedCat = 0),
                        ),
                        _CatChip(
                          text: 'Bike',
                          icon: Icons.pedal_bike_rounded,
                          selected: selectedCat == 1,
                          onTap: () => setState(() => selectedCat = 1),
                        ),
                        _CatChip(
                          text: 'Truck',
                          icon: Icons.local_shipping_outlined,
                          selected: selectedCat == 2,
                          onTap: () => setState(() => selectedCat = 2),
                        ),
                        _CatChip(
                          text: 'Bicycle',
                          icon: Icons.directions_bike_rounded,
                          selected: selectedCat == 3,
                          onTap: () => setState(() => selectedCat = 3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Nearby Park Title (ثابت)
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Nearby Park',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // القائمة المتحركة فقط
                  Expanded(
                    child: _filteredParks.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _filteredParks.length,
                            itemBuilder: (context, i) {
                              final p = _filteredParks[i];

                              final tags = p.categories.map((c) {
                                switch (c) {
                                  case 'Car':
                                    return const _Tag(
                                      text: 'Car',
                                      bg: Color(0xFFE8F0FF),
                                      fg: kBlue,
                                    );
                                  case 'Bike':
                                    return const _Tag(
                                      text: 'Bike',
                                      bg: Color(0xFFEAF7F0),
                                      fg: Color(0xFF55A870),
                                    );
                                  case 'Truck':
                                    return const _Tag(
                                      text: 'Truck',
                                      bg: Color(0xFFFFF3DB),
                                      fg: Color(0xFFE3A83C),
                                    );
                                  case 'Bicycle':
                                    return const _Tag(
                                      text: 'Bicycle',
                                      bg: Color(0xFFEFF3FF),
                                      fg: Color(0xFF5D6BFF),
                                    );
                                  default:
                                    return const _Tag(
                                      text: 'Other',
                                      bg: Color(0xFFEDEDED),
                                      fg: Colors.black54,
                                    );
                                }
                              }).toList();

                              // ====== هنا التعديل المهم: فتح صفحة التفاصيل بنفس البيانات ======
                              return GestureDetector(
                                onTap: () {
                                  final categoryLabel = p.categories.isNotEmpty
                                      ? '${p.categories.first} Parking'
                                      : 'Parking';

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SpaceDetailsPage(
                                        imagePath: p.imagePath,
                                        title: p.title,
                                        address: p.address,
                                        categoryLabel:
                                            categoryLabel, // مثال: "Car Parking"
                                        priceLabel:
                                            p.priceLabel, // مثال: "$2.5 / hr"
                                        distanceLabel:
                                            '', // مرّر قيمة فعلية لو متاحة (مثلاً "2.5 km")
                                        reviews: 140,
                                        rating: 5.0,
                                        spacesLabel:
                                            p.spacesLabel, // "12 Available"
                                        timeLabel: p.timeLabel, // "15 min"
                                        operationTime: '24 hours',
                                      ),
                                    ),
                                  );
                                },
                                child: _ParkCard(
                                  imagePath: p.imagePath,
                                  title: p.title,
                                  address: p.address,
                                  price: p.priceLabel,
                                  spaces: p.spacesLabel,
                                  timeTo: p.timeLabel,
                                  chips: tags,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Widgets & Models --------------------

class _LocationRow extends StatelessWidget {
  const _LocationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NearbyParkingPage(
                  mapImagePath: 'assets/img/ny_map.jpg',
                ),
              ),
            );
          },
          child: const Text(
            'Jakarta, Indonesia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIcon(this.icon, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // <-- هنا بنستخدمه
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2F7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Find parking area...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _CatChip({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = _HomePageState.kBlue;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 74,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE9F1FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? blue : const Color(0xFFE2E6ED),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(height: 6),
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChipPill({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color border = selected
        ? _HomePageState.kBlue
        : const Color(0xFFE2E6ED);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE9F1FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black87, size: 18),
              const SizedBox(width: 6),
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipSegment extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChipSegment({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE9F1FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _HomePageState.kBlue : const Color(0xFFE2E6ED),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 6),
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParkCard extends StatelessWidget {
  final String imagePath, title, address, price, spaces, timeTo;
  final List<_Tag> chips;
  const _ParkCard({
    required this.imagePath,
    required this.title,
    required this.address,
    required this.price,
    required this.spaces,
    required this.timeTo,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: Image.asset(
                  imagePath,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _HomePageState.kBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 8, children: chips),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Metric(title: 'Price', value: price),
                    _Metric(title: 'Space', value: spaces),
                    _Metric(title: 'Time to Location', value: timeTo),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const _Tag({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title, value;
  const _Metric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ======== نموذج البيانات ========
class _ParkItem {
  final String imagePath, title, address, priceLabel, spacesLabel, timeLabel;
  final double pricePerHour; // للأفلترة
  final int timeToLocationMin; // للأفلترة
  final List<String> categories;

  const _ParkItem({
    required this.imagePath,
    required this.title,
    required this.address,
    required this.priceLabel,
    required this.spacesLabel,
    required this.timeLabel,
    required this.pricePerHour,
    required this.timeToLocationMin,
    required this.categories,
  });
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.black38),
          SizedBox(height: 8),
          Text('No results found', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

Widget _pill(String text) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: const Color(0xFFF2F4F7),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
);
