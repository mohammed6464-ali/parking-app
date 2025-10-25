import 'package:flutter/material.dart';

class ReviewSummaryPage extends StatelessWidget {
  // ---- مدخلات الصفحة ----
  final String placeName;          // Jakarta Parking
  final String placeAddress;       // St. Jakarta Sudirman no. 17
  final String vehicleName;        // Speedster X
  final String vehiclePlate;       // B 1234 XY
  final String floorLabel;         // 2nd Floor
  final String spotCode;           // B-3
  final DateTime start;            // تاريخ/وقت البداية
  final DateTime end;              // تاريخ/وقت النهاية
  final double pricePerHour;       // السعر بالساعة
  final String initialPayment;     // Paypal / Visa / Apple Pay...

  static const kBlue = Color(0xFF3F7CFF);

  const ReviewSummaryPage({
    super.key,
    required this.placeName,
    required this.placeAddress,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.floorLabel,
    required this.spotCode,
    required this.start,
    required this.end,
    required this.pricePerHour,
    this.initialPayment = 'Paypal',
  });

  // ---- حسابات ----
  double get hours {
    final mins = end.difference(start).inMinutes;
    return mins / 60.0;
  }

  double get subTotal => hours * pricePerHour;
  double get tax => subTotal * 0.15; // 15%
  double get total => subTotal + tax;

  String _monthName(int m) => const [
        'January','February','March','April','May','June',
        'July','August','September','October','November','December'
      ][m - 1];

  String _fmtDate(DateTime d) => '${_monthName(d.month)} ${d.day}, ${d.year}';

  String _fmtTime(DateTime d) {
    final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    final p = d.hour < 12 ? 'AM' : 'PM';
    return '${h12.toString().padLeft(2, '0')}.$mm $p';
  }

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    String paymentMethod = initialPayment;

    return StatefulBuilder(
      builder: (context, setState) {
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
            title: const Text('Review Summary',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),

          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // بطاقة المكان
              _Card(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: const Color(0xFFE9EEF6),
                        child: const Icon(Icons.photo, color: Colors.black26),
                        // استبدلها بـ Image.asset(...) عندك
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(placeName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(placeAddress,
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // تفاصيل
              _Card(
                child: Column(
                  children: [
                    _RowKV('Vehicle', '$vehicleName  ($vehiclePlate)'),
                    _RowKV('Parking Spot', '$floorLabel ($spotCode)',
                        valueColor: kBlue),
                    _RowKV('Date', _fmtDate(start)),
                    _RowKV('Duration', '${hours.toStringAsFixed(1)} hours'),

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _ColKV('Start', _fmtTime(start)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ColKV('End', _fmtTime(end)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // طريقة الدفع + المبالغ
              _Card(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final sel = await _choosePayment(context, paymentMethod);
                        if (sel != null) setState(() => paymentMethod = sel);
                      },
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Payment Method',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ),
                          Text(paymentMethod,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          const Icon(Icons.chevron_right_rounded,
                              color: Colors.black45),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RowKV('Amount', _money(subTotal)),
                    _RowKV('Taxes (15%)', _money(tax)),
                    const Divider(height: 22),
                    _RowKV('Total', _money(total),
                        valueStyle: const TextStyle(
                            color: kBlue, fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),

          // زر التأكيد
          bottomNavigationBar: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
  await _showSuccessSheet(context);
  // ارجع لأول صفحة (الـ Home) بعد إغلاق الشيت
  Navigator.of(context).popUntil((route) => route.isFirst);
},

                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Payment Confirm',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16,color: Colors.white)),
              ),
            ),
          ),
        );
      },
    );
  }
  Future<void> _showSuccessSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20,
          top: 24,
          bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // دائرة زرقاء بداخلها صح
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3F7CFF),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(Icons.check_circle_outline,
                    size: 56, color: Colors.white),
                // نقط ديكورية
                ...List.generate(6, (i) {
                  final sizes = [8.0, 6.0, 10.0, 7.0, 6.0, 8.0];
                  final offsets = [
                    const Offset(-70, -30),
                    const Offset(70, -35),
                    const Offset(85, 8),
                    const Offset(-85, 12),
                    const Offset(-60, 48),
                    const Offset(60, 50),
                  ];
                  return Positioned(
                    left: 60 + offsets[i].dx,
                    top: 30 + offsets[i].dy,
                    child: Container(
                      width: sizes[i], height: sizes[i],
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F0FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Secure Your Spot\nSuccessful',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your parking subscription payment has\nbeen confirmed',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 24),

            // زر Continue (أو See Receipt لو حبيت)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(), // يقفل الشيت
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F7CFF),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,color: Colors.white)),
              ),
            ),

            const SizedBox(height: 8),
            // (اختياري) زر ثانوي لعرض إيصال
            // TextButton(
            //   onPressed: () { /* افتح صفحة الإيصال */ },
            //   child: const Text('See Receipt'),
            // ),
          ],
        ),
      );
    },
  );
}


  Future<String?> _choosePayment(BuildContext ctx, String current) async {
    final options = ['Paypal', 'Visa', 'Apple Pay', 'Cash'];
    return showModalBottomSheet<String>(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((o) => ListTile(
                      leading: Icon(
                        o == 'Paypal'
                            ? Icons.account_balance_wallet_rounded
                            : o == 'Visa'
                                ? Icons.credit_card
                                : o == 'Apple Pay'
                                    ? Icons.phone_iphone
                                    : Icons.money_rounded,
                      ),
                      title: Text(o),
                      trailing:
                          o == current ? const Icon(Icons.check, color: kBlue) : null,
                      onTap: () => Navigator.pop(ctx, o),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

/* ------------ Small widgets ------------ */

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _RowKV extends StatelessWidget {
  final String k;
  final String v;
  final Color? valueColor;
  final TextStyle? valueStyle;
  const _RowKV(this.k, this.v, {this.valueColor, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(k,
                style: const TextStyle(color: Colors.black54, fontSize: 14)),
          ),
          Text(
            v,
            style: valueStyle ??
                TextStyle(
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ColKV extends StatelessWidget {
  final String k, v;
  const _ColKV(this.k, this.v);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        const SizedBox(height: 6),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
