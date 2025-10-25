import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/home_pages/select_car_page.dart';

class SpaceDetailsPage extends StatefulWidget {
  final String imagePath;
  final String title;
  final String address;

  // Labels المرسلة من الهوم
  final String categoryLabel;   // "Car Parking"
  final String priceLabel;      // "$2.5 / hr"
  final String distanceLabel;   // "2.5 km"
  final int reviews;            // 120 مثلا
  final double rating;          // 5.0 مثلا

  final String spacesLabel;     // "12 Available"
  final String timeLabel;       // "15 min"
  final String operationTime;   // "24 hours"

  const SpaceDetailsPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.address,
    required this.categoryLabel,
    required this.priceLabel,
    required this.distanceLabel,
    required this.reviews,
    required this.rating,
    required this.spacesLabel,
    required this.timeLabel,
    required this.operationTime,
  });

  @override
  State<SpaceDetailsPage> createState() => _SpaceDetailsPageState();
}

class _SpaceDetailsPageState extends State<SpaceDetailsPage> {
  static const kBlue = Color(0xFF3F7CFF);

  int _tab = 0; // 0=About, 1=Gallery, 2=Review

  // ====== Reviews State (قابل للإضافة) ======
  final List<_Review> _reviews = [
    _Review(
      name: 'Andi P.',
      avatar: null,
      rating: 5.0,
      title: 'Hassle-Free Parking!',
      text:
          'Jakarta Parking makes finding a spot so easy! No more driving around in circles—just book, park, and go. The cashless payment is super convenient too',
    ),
    _Review(
      name: 'Rina S.',
      avatar: null,
      rating: 5.0,
      title: 'Safe & Secure',
      text:
          'Love how secure the parking locations are. Well-lit, monitored, and easy to access. I feel much safer parking here, especially at night',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Space Details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== الصورة =====
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.asset(
                widget.imagePath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // ===== العنوان =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(widget.address,
                            style: const TextStyle(color: Colors.black54)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.route_rounded, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.distanceLabel,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(width: 12),
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text('${widget.rating.toStringAsFixed(1)} (${widget.reviews + _reviews.length})',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Tag(text: widget.categoryLabel, bg: const Color(0xFFE8F0FF), fg: kBlue),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ===== Tabs =====
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      children: [
                        _TabButton(
                          title: 'About',
                          selected: _tab == 0,
                          onTap: () => setState(() => _tab = 0),
                        ),
                        _TabButton(
                          title: 'Gallery',
                          selected: _tab == 1,
                          onTap: () => setState(() => _tab = 1),
                        ),
                        _TabButton(
                          title: 'Review',
                          selected: _tab == 2,
                          onTap: () => setState(() => _tab = 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ===== المحتوى المتغير =====
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _tab == 0
                        ? _buildAbout()
                        : _tab == 1
                            ? _buildGallery()
                            : _buildReviews(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ===== الشريط السفلي =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // زر فتح نافذة إضافة ريفيو
            InkWell(
              onTap: _openAddReviewSheet,
              borderRadius: BorderRadius.circular(23),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SelectVehiclePage()),
                );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white)),
              ),
            ),
         
          ],
        ),
      ),
    );
  }

  // ---------------- Sections ----------------

  Widget _buildAbout() {
    return Column(
      key: const ValueKey('about'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _MetricTile(label: 'Space', value: widget.spacesLabel)),
            const SizedBox(width: 12),
            Expanded(child: _MetricTile(label: 'Time to Location', value: widget.timeLabel)),
            const SizedBox(width: 12),
            Expanded(child: _MetricTile(label: 'Operation Time', value: widget.operationTime)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text('Total Price',
                style: TextStyle(color: Colors.black54, fontSize: 14)),
            const Spacer(),
            Text(
              widget.priceLabel,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
          'Park with ease at Jakarta Parking, your trusted solution for safe and accessible parking in Jakarta. Enjoy real-time availability tracking, affordable rates, and secure payment options for a hassle-free experience.',
          style: TextStyle(color: Colors.black54, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildGallery() {
    return Column(
      key: const ValueKey('gallery'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            6,
            (i) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(widget.imagePath, fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      key: const ValueKey('review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review (${widget.reviews + _reviews.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (c, i) => _ReviewCard(item: _reviews[i]),
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemCount: _reviews.length,
        ),
      ],
    );
  }

  // ---------------- Add Review Sheet ----------------

  void _openAddReviewSheet() {
    final nameCtr = TextEditingController();
    final titleCtr = TextEditingController();
    final textCtr = TextEditingController();
    double tempRating = 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
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
                      child: Text('Add Review',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                _Input(label: 'Your Name (optional)', controller: nameCtr),
                const SizedBox(height: 10),
                _Input(label: 'Title', controller: titleCtr),
                const SizedBox(height: 10),
                _Input(
                  label: 'Your Review',
                  controller: textCtr,
                  lines: 4,
                ),
                const SizedBox(height: 12),

                // Rating
                const Text('Rating',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    final filled = (i + 1) <= tempRating;
                    return IconButton(
                      onPressed: () => setSheet(() => tempRating = (i + 1).toDouble()),
                      icon: Icon(
                        Icons.star_rounded,
                        color: filled ? Colors.amber : Colors.grey.shade300,
                        size: 28,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleCtr.text.trim();
                          final text = textCtr.text.trim();
                          if (title.isEmpty || text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill title and review'),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _reviews.insert(
                              0,
                              _Review(
                                name: (nameCtr.text.trim().isEmpty)
                                    ? 'Anonymous'
                                    : nameCtr.text.trim(),
                                avatar: null,
                                rating: tempRating,
                                title: title,
                                text: text,
                              ),
                            );
                            _tab = 2; // انتقل إلى تبويب Review
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review added')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

// ---------------- Small Widgets ----------------

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? _SpaceDetailsPageState.kBlue : Colors.black87;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? _SpaceDetailsPageState.kBlue : Colors.transparent),
          ),
          child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Tag({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int lines;
  const _Input({required this.label, required this.controller, this.lines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: lines,
          maxLines: lines,
          decoration: InputDecoration(
            isDense: true,
            hintText: label,
            filled: true,
            fillColor: const Color(0xFFF6F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ---------------- Review Model & Card ----------------

class _Review {
  final String name;
  final String? avatar; // nullable: لو ماعندناش صورة
  final double rating;
  final String title;
  final String text;
  _Review({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.title,
    required this.text,
  });
}

class _ReviewCard extends StatelessWidget {
  final _Review item;
  const _ReviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFFFF0D9),
                backgroundImage:
                    item.avatar != null ? AssetImage(item.avatar!) : null,
                child: item.avatar == null
                    ? Text(
                        item.name.isNotEmpty ? item.name[0] : '?',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => Icon(
                      Icons.star_rounded,
                      color: (i + 1) <= item.rating ? Colors.amber : Colors.grey.shade300,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(item.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(item.text, style: const TextStyle(color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}
