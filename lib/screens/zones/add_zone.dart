import 'package:flutter/material.dart';

import '../../models/garden_zone.dart';

const _green = Color(0xFF3F704F);
const _paleGreen = Color(0xFFCFE6D5);
const _ink = Color(0xFF1E3326);

class AddZoneSheet extends StatefulWidget {
  const AddZoneSheet({super.key});

  @override
  State<AddZoneSheet> createState() => _AddZoneSheetState();
}

class _AddZoneSheetState extends State<AddZoneSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  String _soilType = 'Sandy Loam';
  final Set<String> _plants = {};

  static const _availablePlants = [
    'Sweet Basil',
    'Mint',
    'Rosemary',
    'Dill',
    'Chives',
    'Parsley',
    'Oregano',
    'Thyme',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final zone = GardenZone(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      soilType: _soilType,
      areaSqM: double.parse(_areaController.text.trim().replaceAll(',', '.')),
      color: const Color(0xFFA8CFA0),
      left: 24,
      top: 24,
      width: 150,
      height: 118,
      plants: _plants.toList(),
    );

    Navigator.pop(context, zone);
  }

  @override
  Widget build(BuildContext context) {
    return _ZoneSheetFrame(
      title: 'Add New Zone',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(
              label: 'Zone Name',
              child: TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('e.g. Raised Beds North'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a zone name'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            _FieldLabel(
              label: 'Soil Type',
              child: DropdownButtonFormField<String>(
                value: _soilType,
                decoration: _inputDecoration(null),
                items: const [
                  'Sandy Loam',
                  'Rich Compost',
                  'Clay Silt',
                  'Mixed Soil',
                  'Organic Mix',
                  'Potting Mix',
                ]
                    .map((soil) =>
                        DropdownMenuItem(value: soil, child: Text(soil)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _soilType = value);
                },
              ),
            ),
            const SizedBox(height: 14),
            _FieldLabel(
              label: 'Area Size',
              child: TextFormField(
                controller: _areaController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration('e.g. 150 sq m'),
                validator: (value) {
                  final area =
                      double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                  if (area == null || area <= 0) return 'Enter a valid area';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: _paleGreen,
                  foregroundColor: _ink,
                  side: const BorderSide(color: _green),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () => _showPlantPicker(context),
                child: const Text('Pick Plants'),
              ),
            ),
            const SizedBox(height: 16),
            _SheetActions(
              cancelLabel: 'Cancel',
              saveLabel: 'Save Zone',
              onCancel: () => Navigator.pop(context),
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlantPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pick Plants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            ..._availablePlants.map(
              (plant) => StatefulBuilder(
                builder: (context, setPickerState) => CheckboxListTile(
                  value: _plants.contains(plant),
                  title: Text(plant),
                  activeColor: _green,
                  onChanged: (selected) {
                    setState(() {
                      selected == true
                          ? _plants.add(plant)
                          : _plants.remove(plant);
                    });
                    setPickerState(() {});
                  },
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}

InputDecoration _inputDecoration(String? hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3DC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3DC)),
      ),
    );

class _ZoneSheetFrame extends StatelessWidget {
  const _ZoneSheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          22,
          8,
          22,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE4DD),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                color: _ink,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _ink)),
          const SizedBox(height: 6),
          child,
        ],
      );
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.cancelLabel,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
  });

  final String cancelLabel;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: Text(cancelLabel),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _green),
              onPressed: onSave,
              child: Text(saveLabel),
            ),
          ),
        ],
      );
}
