import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/home_pages/book_time_page.dart';

class SelectVehiclePage extends StatefulWidget {
  const SelectVehiclePage({super.key});

  @override
  State<SelectVehiclePage> createState() => _SelectVehiclePageState();
}

class _SelectVehiclePageState extends State<SelectVehiclePage> {
  static const kBlue = Color(0xFF3F7CFF);

  final List<_Vehicle> _vehicles = [
    _Vehicle(name: 'Jetour Dashing', plate: 'B 1234 XY', phone: '0501234567', color: Colors.blue),
    _Vehicle(name: 'Land Cruiser', plate: 'D 5678 AB', phone: '0558765432', color: Colors.black87),
        _Vehicle(name: 'Kia Sportage', plate: 'P 1679 AB', phone: '05367393432', color: const Color.fromARGB(221, 243, 2, 2)),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Your Vehicle',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        children: [
          ...List.generate(
            _vehicles.length,
            (i) => _VehicleTile(
              vehicle: _vehicles[i],
              selected: i == _selectedIndex,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          ),
          const SizedBox(height: 12),

          // زر إضافة مركبة
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _onAddVehicle,
              icon: const Icon(Icons.add,color: Colors.white),
              label: const Text('Add New Vehicle',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BookParkingDetailPage(
      pricePerHour: 2.5,         // ابعت السعر/ساعة من كارت المكان
      //initialVehicle: myVehicle, // (اختياري) العربية المختارة
    ),
  ),
);

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Select',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _onEditSelected,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: Color(0xFFDADDE2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Edit Detail',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddVehicle() async {
    final result = await showModalBottomSheet<_Vehicle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _VehicleFormSheet(),
    );

    if (result != null) {
      setState(() {
        _vehicles.add(result);
        _selectedIndex = _vehicles.length - 1;
      });
    }
  }

  void _onEditSelected() async {
    final current = _vehicles[_selectedIndex];
    final edited = await showModalBottomSheet<_Vehicle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _VehicleFormSheet(initial: current),
    );

    if (edited != null) {
      setState(() => _vehicles[_selectedIndex] = edited);
    }
  }
}

// ====== بلاطة المركبة ======
class _VehicleTile extends StatelessWidget {
  final _Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleTile({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF3F7CFF) : const Color(0xFFE2E6ED);
    final bg = selected ? const Color(0xFFEAF2FF) : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            _CarIcon(color: vehicle.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(vehicle.plate,
                      style: const TextStyle(
                          color: Color(0xFF5D79C0), fontWeight: FontWeight.w600)),
                  Text('📞 ${vehicle.phone}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
            _SelectDot(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SelectDot extends StatelessWidget {
  final bool selected;
  const _SelectDot({required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF2FF) : const Color(0xFFF1F3F6),
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF3F7CFF) : const Color(0xFFE2E6ED),
          width: selected ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2CD17E) : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CarIcon extends StatelessWidget {
  final Color color;
  const _CarIcon({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 18),
    );
  }
}

// ====== موديل المركبة ======
class _Vehicle {
  final String name;
  final String plate;
  final String phone;
  final Color color;
  _Vehicle({
    required this.name,
    required this.plate,
    required this.phone,
    required this.color,
  });

  _Vehicle copyWith({String? name, String? plate, String? phone, Color? color}) => _Vehicle(
        name: name ?? this.name,
        plate: plate ?? this.plate,
        phone: phone ?? this.phone,
        color: color ?? this.color,
      );
}

// ====== شاشة الإضافة/التعديل ======
class _VehicleFormSheet extends StatefulWidget {
  final _Vehicle? initial;
  const _VehicleFormSheet({this.initial});

  @override
  State<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<_VehicleFormSheet> {
  static const kBlue = Color(0xFF3F7CFF);

  late final TextEditingController _name =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _plate =
      TextEditingController(text: widget.initial?.plate ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.initial?.phone ?? '');
  Color _color = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _color = widget.initial!.color;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(widget.initial == null ? 'Add New Vehicle' : 'Edit Vehicle',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              )
            ],
          ),
          const SizedBox(height: 8),

          _LabeledField(label: 'Vehicle Name', controller: _name),
          const SizedBox(height: 10),
          _LabeledField(label: 'Plate Number', controller: _plate),
          const SizedBox(height: 10),
          _LabeledField(label: 'Phone Number', controller: _phone),
          const SizedBox(height: 12),

          const Text('Color', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final c in [Colors.blue, Colors.black87, Colors.black54, Colors.red, Colors.green])
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == c ? kBlue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_name.text.trim().isEmpty ||
                    _plate.text.trim().isEmpty ||
                    _phone.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                final v = _Vehicle(
                  name: _name.text.trim(),
                  plate: _plate.text.trim(),
                  phone: _phone.text.trim(),
                  color: _color,
                );
                Navigator.pop(context, v);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: const StadiumBorder(),
              ),
              child: Text(widget.initial == null ? 'Add Vehicle' : 'Save Changes',style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _LabeledField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
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
