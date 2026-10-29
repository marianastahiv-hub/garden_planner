import 'package:flutter/material.dart';

import '../core/widgets/garden_add_fab.dart';
import '../core/widgets/project_asset_picker.dart';
import '../data/garden_store.dart';
import '../models/garden_plant.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF1E3326);
const _paper = Color(0xFFF9F9F7);

// Каталог рослин: картки, проста форма додавання та перегляд деталей.
class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key, required this.onViewGallery});
  final ValueChanged<String> onViewGallery;

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  List<GardenPlant> get _plants => GardenStore.instance.plants;

  Future<void> _addPlant() async {
    final plant = await showModalBottomSheet<GardenPlant>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PlantFormSheet(
        zones: GardenStore.instance.zones.map((zone) => zone.name).toList(),
      ),
    );
    if (plant != null && mounted) {
      setState(() => GardenStore.instance.addPlant(plant));
    }
  }

  Future<void> _showPlant(GardenPlant plant) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE4DD), borderRadius: BorderRadius.circular(5)))),
              const SizedBox(height: 18),
              Text(plant.name, style: const TextStyle(fontFamily: 'Serif', fontSize: 23, color: _ink)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(height: 190, width: double.infinity, child: _plantImage(plant)),
              ),
              const SizedBox(height: 16),
              Text(plant.description, style: const TextStyle(color: Color(0xFF68766D), height: 1.4)),
              const SizedBox(height: 14),
              _InfoLine(label: 'Zone', value: plant.zone),
              _InfoLine(label: 'Planted', value: plant.plantingDate),
              _InfoLine(label: 'Watering', value: plant.wateringSchedule),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _green),
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        widget.onViewGallery(plant.name);
                      },
                      child: const Text('View Gallery'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _paper,
        appBar: AppBar(
          backgroundColor: _paper,
          title: const Text('My Plants', style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: _ink)),
        ),
        body: _plants.isEmpty
            ? const Center(child: Text('No plants yet. Add your first plant!'))
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 92),
                itemCount: _plants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final plant = _plants[index];
                  return _PlantCard(plant: plant, onTap: () => _showPlant(plant));
                },
              ),
        floatingActionButton: GardenAddFab(
          heroTag: 'add_plant',
          tooltip: 'Add plant',
          onPressed: _addPlant,
        ),
      );
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant, required this.onTap});
  final GardenPlant plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SizedBox(width: double.infinity, child: _plantImage(plant))),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plant.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFE8F0E9), borderRadius: BorderRadius.circular(12)),
                      child: Text(plant.zone, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: _green)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

Widget _plantImage(GardenPlant plant) {
  final path = plant.imageAsset;
  if (path == null) {
    return const ColoredBox(
      color: Color(0xFFE4EEE0),
      child: Center(child: Icon(Icons.local_florist_outlined, size: 42, color: _green)),
    );
  }
  return Image.asset(
    path,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const ColoredBox(
      color: Color(0xFFE4EEE0),
      child: Center(child: Icon(Icons.local_florist_outlined, size: 42, color: _green)),
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF68766D), fontSize: 12))),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _PlantFormSheet extends StatefulWidget {
  const _PlantFormSheet({required this.zones});
  final List<String> zones;
  @override
  State<_PlantFormSheet> createState() => _PlantFormSheetState();
}

class _PlantFormSheetState extends State<_PlantFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _zone = widget.zones.isEmpty ? 'Garden' : widget.zones.first;
  String? _imageAsset;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    Navigator.pop(
      context,
      GardenPlant(
        id: now.microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        zone: _zone,
        description: 'A new plant in your garden.',
        plantingDate: '${now.month}/${now.day}/${now.year}',
        wateringSchedule: 'As needed',
        imageAsset: _imageAsset,
      ),
    );
  }

  Future<void> _chooseImage() async {
    final asset = await ProjectAssetPicker.show(
      context,
      selectedAsset: _imageAsset,
    );
    if (asset != null && mounted) setState(() => _imageAsset = asset);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE4DD), borderRadius: BorderRadius.circular(5)))),
                const SizedBox(height: 20),
                const Text('Add Plant', style: TextStyle(fontFamily: 'Serif', fontSize: 22, color: _ink)),
                const SizedBox(height: 16),
                const Text('Plant Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: _plantInput('e.g. Sweet Basil'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter a plant name' : null,
                ),
                const SizedBox(height: 14),
                const Text('Zone'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _zone,
                  decoration: _plantInput(null),
                  items: {...widget.zones, _zone}.map((zone) => DropdownMenuItem(value: zone, child: Text(zone))).toList(),
                  onChanged: (value) { if (value != null) setState(() => _zone = value); },
                ),
                const SizedBox(height: 14),
                const Text('Photo'),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: _chooseImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_imageAsset == null ? 'Choose a project photo' : _imageAsset!.split('/').last),
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: _green), onPressed: _save, child: const Text('Save Plant'))),
                ]),
              ],
            ),
          ),
        ),
      );
}

InputDecoration _plantInput(String? hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDCE4DC))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDCE4DC))),
    );
