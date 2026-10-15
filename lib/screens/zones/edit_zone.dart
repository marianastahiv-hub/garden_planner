import 'package:flutter/material.dart';

import '../../models/garden_zone.dart';


class EditZoneSheet extends StatefulWidget {
  const EditZoneSheet({super.key, required this.zone});

  final GardenZone zone;

  @override
  State<EditZoneSheet> createState() => _EditZoneSheetState();
}

class _EditZoneSheetState extends State<EditZoneSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  late String _soilType;
  late final Set<String> _plants;

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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.zone.name);
    _areaController =
        TextEditingController(text: widget.zone.areaSqM.toStringAsFixed(0));
    _soilType = widget.zone.soilType;
    _plants = Set<String>.from(widget.zone.plants);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final area = double.tryParse(_areaController.text.trim().replaceAll(',', '.'));
    if (name.isEmpty || area == null || area <= 0) return;

    final updated = GardenZone(
      id: widget.zone.id,
      name: name,
      soilType: _soilType,
      areaSqM: area,
      color: widget.zone.color,
      left: widget.zone.left,
      top: widget.zone.top,
      width: widget.zone.width,
      height: widget.zone.height,
      plants: _plants.toList(),
      isActive: widget.zone.isActive,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
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
            const Text(
              'Edit Zone',
              style: TextStyle(fontFamily: 'Serif', fontSize: 22),
            ),
            const SizedBox(height: 18),
            _label('Zone Name'),
            TextField(controller: _nameController, decoration: decoration),
            const SizedBox(height: 14),
            _label('Soil Type'),
            DropdownButtonFormField<String>(
              value: _soilType,
              decoration: decoration,
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
            const SizedBox(height: 14),
            _label('Area Size'),
            TextField(
              controller: _areaController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: decoration.copyWith(suffixText: 'sq m'),
            ),
            const SizedBox(height: 16),
            if (_plants.isEmpty)
              const Text(
                'No plants added yet',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 7,
                children: _plants.map((plant) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3EEDF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(plant, style: const TextStyle(fontSize: 11)),
                )).toList(),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFCFE6D5),
                  side: const BorderSide(color: Color(0xFF3F704F)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed:  _showPlantPicker,
                child: const Text('Edit Plants'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3F704F),
                    ),
                    onPressed: _save,
                    child: const Text('Save Zone'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlantPicker() async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setPickerState) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pick Plants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            ..._availablePlants.map(
              (plant) => CheckboxListTile(
                value: _plants.contains(plant),
                title: Text(plant),
                activeColor: const Color(0xFF3F704F),
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
            FilledButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}
