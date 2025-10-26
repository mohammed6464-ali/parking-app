// add_parking_place_page.dart
// A complete "Add Parking Place" page (English UI) with auto-generated spot codes.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/admin_dashboard/admin_home_page.dart';
import 'package:image_picker/image_picker.dart';

class AddParkingPlacePage extends StatefulWidget {
  const AddParkingPlacePage({super.key});

  @override
  State<AddParkingPlacePage> createState() => _AddParkingPlacePageState();
}

class _AddParkingPlacePageState extends State<AddParkingPlacePage> {
  // Style tokens
  static const kBlue = Color(0xFF3F7CFF);
  static const kBg = Color(0xFFF4F6F9);

  // How many spots per alphabetic row: A1..A10 then B1..B10...
  static const int kSpotsPerRow = 10;

  final _formKey = GlobalKey<FormState>();

  // Image
  final ImagePicker _picker = ImagePicker();
  XFile? _picked;

  // Basic fields
  final _nameCtr = TextEditingController();
  final _streetCtr = TextEditingController();
  final _districtCtr = TextEditingController();
  final _cityCtr = TextEditingController();
  final _priceCtr = TextEditingController(); // per hour
  final _descCtr = TextEditingController();

  // Total spots & generated codes
  final _totalSpotsCtr = TextEditingController();
  int _totalSpots = 0;
  List<String> _spotsCodes = [];

  // Rating
  double _rating = 4.5;

  // Vehicle types
  final List<_Vehicle> _vehicles = [
    _Vehicle('Car', Icons.directions_car_filled_rounded),
    _Vehicle('Bike', Icons.pedal_bike_rounded),
    _Vehicle('Bicycle', Icons.directions_bike_rounded),
    _Vehicle('Scooter', Icons.electric_scooter_outlined),
    _Vehicle('Truck', Icons.local_shipping_outlined),
  ];
  final Set<String> _selectedTypes = {'Car'}; // default
  bool _selectAll = false;

  // Optional capacity per type
  final Map<String, TextEditingController> _capacityCtrs = {};

  // Working hours
  bool _open247 = true;
  TimeOfDay _openAt = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closeAt = const TimeOfDay(hour: 22, minute: 0);

  @override
  void initState() {
    super.initState();
    for (final v in _vehicles) {
      _capacityCtrs[v.name] = TextEditingController();
    }
    _totalSpotsCtr.addListener(_onTotalSpotsChanged);
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _streetCtr.dispose();
    _districtCtr.dispose();
    _cityCtr.dispose();
    _priceCtr.dispose();
    _descCtr.dispose();
    _totalSpotsCtr.removeListener(_onTotalSpotsChanged);
    _totalSpotsCtr.dispose();
    for (final c in _capacityCtrs.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ------- Image & time pickers -------
  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      setState(() => _picked = x);
    }
  }

  Future<void> _pickTime({required bool open}) async {
    final current = open ? _openAt : _closeAt;
    final res = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) => Theme(data: Theme.of(ctx), child: child!),
    );
    if (res != null) {
      setState(() {
        if (open) {
          _openAt = res;
        } else {
          _closeAt = res;
        }
      });
    }
  }

  // ------- Vehicle types selection -------
  void _toggleAll(bool v) {
    setState(() {
      _selectAll = v;
      _selectedTypes.clear();
      if (v) {
        _selectedTypes.addAll(_vehicles.map((e) => e.name));
      }
    });
  }

  void _toggleType(String name) {
    setState(() {
      if (_selectedTypes.contains(name)) {
        _selectedTypes.remove(name);
      } else {
        _selectedTypes.add(name);
      }
      _selectAll = _selectedTypes.length == _vehicles.length;
    });
  }

  // ------- Spots generation -------
  void _onTotalSpotsChanged() {
    final n = int.tryParse(_totalSpotsCtr.text.trim()) ?? 0;
    if (n != _totalSpots) {
      setState(() {
        _totalSpots = n.clamp(0, 100000); // safety cap
        _spotsCodes = _generateSpotCodes(_totalSpots, perRow: kSpotsPerRow);
      });
    }
  }

  List<String> _generateSpotCodes(int count, {int perRow = 10}) {
    if (count <= 0) return [];
    final List<String> codes = [];
    for (int i = 0; i < count; i++) {
      final rowIndex = i ~/ perRow; // 0 => A, 1 => B...
      final number = (i % perRow) + 1; // 1..perRow
      final rowLetter = _lettersForIndex(rowIndex); // A..Z, AA..AZ, BA.. etc
      codes.add('$rowLetter$number');
    }
    return codes;
  }

  // Convert 0.. -> A, 1 -> B ... 25 -> Z, 26 -> AA, 27 -> AB ...
  String _lettersForIndex(int index) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String result = '';
    int n = index;
    do {
      result = letters[n % 26] + result;
      n = (n ~/ 26) - 1;
    } while (n >= 0);
    return result;
  }

  // ------- Helpers -------
  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_totalSpots <= 0 || _spotsCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Total Spots number')),
      );
      return;
    }

    // Build payload (replace with Firebase/your backend call)
    final Map<String, dynamic> payload = {
      'imagePath': _picked?.path,
      'name': _nameCtr.text.trim(),
      'address': {
        'street': _streetCtr.text.trim(),
        'district': _districtCtr.text.trim(),
        'city': _cityCtr.text.trim(),
      },
      'rating': double.parse(_rating.toStringAsFixed(1)),
      'vehicleTypes': _selectedTypes.toList(),
      'capacityPerType': {
        for (final e in _selectedTypes)
          e: int.tryParse(_capacityCtrs[e]?.text.trim() ?? '') ?? 0,
      },
      'pricePerHour': double.tryParse(_priceCtr.text.trim()) ?? 0.0,
      'openHours': _open247 ? '24/7' : '${_fmtTime(_openAt)} – ${_fmtTime(_closeAt)}',
      'description': _descCtr.text.trim(),
      'totalSpots': _totalSpots,
      'spotsCodes': _spotsCodes, // << generated list
      'spotsPerRow': kSpotsPerRow,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Show demo result
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Parking Place JSON'),
        content: SingleChildScrollView(
          child: Text(payload.toString()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
  elevation: 0,
  backgroundColor: kBlue,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    onPressed: () {Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardPage(),
                            ),
                          );},
  ),
  title: const Text(
    'Add Parking Place',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
  ),
),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 96,
                          height: 96,
                          color: const Color(0xFFE9F1FF),
                          child: _picked == null
                              ? const Icon(Icons.image, size: 36, color: Colors.black45)
                              : Image.file(File(_picked!.path), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Place Image', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            const Text(
                              'Upload a clear photo that represents the parking place.',
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.upload_rounded,color: Colors.white,),
                                  label: const Text('Upload',style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(backgroundColor: kBlue),
                                ),
                                const SizedBox(width: 8),
                                if (_picked != null)
                                  TextButton.icon(
                                    onPressed: () => setState(() => _picked = null),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Remove'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Basic info
                _card(
                  child: Column(
                    children: [
                      _textField(controller: _nameCtr, label: 'Place Name', icon: Icons.place_rounded, required: true),
                      const SizedBox(height: 10),
                      _textField(controller: _streetCtr, label: 'Street', icon: Icons.signpost_outlined, required: true),
                      const SizedBox(height: 10),
                      _textField(controller: _districtCtr, label: 'District', icon: Icons.maps_home_work_outlined),
                      const SizedBox(height: 10),
                      _textField(controller: _cityCtr, label: 'City', icon: Icons.location_city_outlined, required: true),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Spots + Rating + Price + Hours
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total Spots
                      _textField(
                        controller: _totalSpotsCtr,
                        label: 'Total Spots',
                        icon: Icons.grid_view_rounded,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      if (_totalSpots > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Generated Spots (preview):',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            _spotsPreview(_spotsCodes),
                          ],
                        ),

                      const SizedBox(height: 14),

                      // Rating
                      const Text('Rating', style: TextStyle(fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _rating,
                              min: 1.0,
                              max: 5.0,
                              divisions: 8,
                              activeColor: kBlue,
                              label: _rating.toStringAsFixed(1),
                              onChanged: (v) => setState(() => _rating = v),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F1FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Price per hour
                      _textField(
                        controller: _priceCtr,
                        label: 'Price per hour (SAR)',
                        icon: Icons.payments_rounded,
                        keyboardType: TextInputType.number,
                        required: true,
                      ),

                      const SizedBox(height: 12),

                      // Hours
                      Row(
                        children: [
                          Switch(
                            value: _open247,
                            activeColor: kBlue,
                            onChanged: (v) => setState(() => _open247 = v),
                          ),
                          const SizedBox(width: 6),
                          const Text('Open 24/7', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (!_open247)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickTime(open: true),
                                icon: const Icon(Icons.schedule_rounded),
                                label: Text('Opens at ${_fmtTime(_openAt)}'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickTime(open: false),
                                icon: const Icon(Icons.schedule_rounded),
                                label: Text('Closes at ${_fmtTime(_closeAt)}'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Vehicle types
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Allowed Vehicle Types', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          Checkbox(
                            value: _selectAll,
                            onChanged: (v) => _toggleAll(v ?? false),
                            activeColor: kBlue,
                          ),
                          const Text('Select All'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _vehicles.map((v) {
                          final selected = _selectedTypes.contains(v.name);
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(v.icon, size: 18),
                                const SizedBox(width: 6),
                                Text(v.name),
                              ],
                            ),
                            selected: selected,
                            onSelected: (_) => _toggleType(v.name),
                            selectedColor: const Color(0xFFE9F1FF),
                            showCheckmark: false,
                            side: BorderSide(color: selected ? kBlue : const Color(0xFFE2E6ED)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text('Optional: Capacity per selected type',
                          style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _vehicles.where((v) => _selectedTypes.contains(v.name)).map((v) {
                          return SizedBox(
                            width: 140,
                            child: TextField(
                              controller: _capacityCtrs[v.name],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                isDense: true,
                                labelText: '${v.name} capacity',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                _card(
                  child: TextField(
                    controller: _descCtr,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded,color: Colors.white),
                    label: const Text('Save',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      shape: const StadiumBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- UI helpers ----
  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _spotsPreview(List<String> codes) {
    const maxPreview = 30;
    final show = codes.take(maxPreview).toList();
    final more = codes.length - show.length;

    if (codes.isEmpty) {
      return const Text('—', style: TextStyle(color: Colors.black54));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...show.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD7DDF2)),
              ),
              child: Text(c, style: const TextStyle(fontWeight: FontWeight.w700)),
            )),
        if (more > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3DB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3A83C).withOpacity(.4)),
            ),
            child: Text('+$more more', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

class _Vehicle {
  final String name;
  final IconData icon;
  _Vehicle(this.name, this.icon);
}
