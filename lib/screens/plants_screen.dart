import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/widgets/garden_add_fab.dart';
import '../core/widgets/project_asset_picker.dart';
import '../features/garden/bloc/garden_bloc.dart';
import '../features/garden/bloc/garden_event.dart';
import '../features/garden/bloc/garden_state.dart';
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
  Future<void> _addPlant() async {
    final zones = context
        .read<GardenBloc>()
        .state
        .zones
        .map((zone) => zone.name)
        .toList();
    final plant = await showModalBottomSheet<GardenPlant>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PlantFormSheet(zones: zones),
    );
    if (plant != null && mounted) {
      context.read<GardenBloc>().add(GardenPlantAdded(plant));
    }
  }

  Future<void> _editPlant(GardenPlant plant) async {
    final zones = context
        .read<GardenBloc>()
        .state
        .zones
        .map((zone) => zone.name)
        .toList();
    final updated = await showModalBottomSheet<GardenPlant>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PlantFormSheet(zones: zones, initialPlant: plant),
    );
    if (updated != null && mounted) {
      context.read<GardenBloc>().add(GardenPlantUpdated(updated));
    }
  }

  Future<void> _changePlantPhoto(GardenPlant plant) async {
    final image = await ProjectAssetPicker.show(
      context,
      selectedAsset: plant.imageAsset,
    );
    if (image == null || !mounted) return;
    context.read<GardenBloc>().add(
      GardenPlantUpdated(
        GardenPlant(
          id: plant.id,
          name: plant.name,
          zone: plant.zone,
          description: plant.description,
          plantingDate: plant.plantingDate,
          wateringSchedule: plant.wateringSchedule,
          imageAsset: image,
        ),
      ),
    );
  }

  Future<void> _showPlant(GardenPlant plant) async {
    final action = await showModalBottomSheet<String>(
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
              const SizedBox(height: 18),
              Text(
                plant.name,
                style: const TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 23,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: _plantImage(plant),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _changePlantPhoto(plant),
                  icon: const Icon(Icons.photo_outlined, size: 18),
                  label: const Text('Change photo'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                plant.description,
                style: const TextStyle(color: Color(0xFF68766D), height: 1.4),
              ),
              const SizedBox(height: 14),
              _InfoLine(label: 'Zone', value: plant.zone),
              _InfoLine(label: 'Planted', value: plant.plantingDate),
              _InfoLine(label: 'Watering', value: plant.wateringSchedule),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.read<GardenBloc>().add(
                        GardenPlantRemoved(plant.id),
                      );
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext, 'edit');
                    },
                    child: const Text('Edit'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _green),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      widget.onViewGallery(plant.name);
                    },
                    child: const Text('View Gallery'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (action == 'edit' && mounted) await _editPlant(plant);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _paper,
    appBar: AppBar(
      backgroundColor: _paper,
      title: const Text(
        'My Plants',
        style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: _ink),
      ),
    ),
    body: BlocBuilder<GardenBloc, GardenState>(
      builder: (context, state) {
        if (state.status == GardenStatus.loading ||
            state.status == GardenStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.plants.isEmpty) {
          return const Center(
            child: Text('No plants yet. Add your first plant!'),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 92),
          itemCount: state.plants.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            final plant = state.plants[index];
            return _PlantCard(plant: plant, onTap: () => _showPlant(plant));
          },
        );
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
          Expanded(
            child: SizedBox(width: double.infinity, child: _plantImage(plant)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plant.zone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: _green),
                  ),
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
      child: Center(
        child: Icon(Icons.local_florist_outlined, size: 42, color: _green),
      ),
    );
  }
  return Image.asset(
    path,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => const ColoredBox(
      color: Color(0xFFE4EEE0),
      child: Center(
        child: Icon(Icons.local_florist_outlined, size: 42, color: _green),
      ),
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF68766D), fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _PlantFormSheet extends StatefulWidget {
  const _PlantFormSheet({required this.zones, this.initialPlant});
  final List<String> zones;
  final GardenPlant? initialPlant;
  @override
  State<_PlantFormSheet> createState() => _PlantFormSheetState();
}

class _PlantFormSheetState extends State<_PlantFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _plantingDateController;
  late final TextEditingController _wateringController;
  late String _zone;
  String? _imageAsset;

  @override
  void initState() {
    super.initState();
    final plant = widget.initialPlant;
    final now = DateTime.now();
    _nameController = TextEditingController(text: plant?.name ?? '');
    _descriptionController = TextEditingController(
      text: plant?.description ?? 'A new plant in your garden.',
    );
    _plantingDateController = TextEditingController(
      text: plant?.plantingDate ?? '${now.month}/${now.day}/${now.year}',
    );
    _wateringController = TextEditingController(
      text: plant?.wateringSchedule ?? 'As needed',
    );
    _zone =
        plant?.zone ?? (widget.zones.isEmpty ? 'Garden' : widget.zones.first);
    _imageAsset = plant?.imageAsset;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _plantingDateController.dispose();
    _wateringController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      GardenPlant(
        id:
            widget.initialPlant?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        zone: _zone,
        description: _descriptionController.text.trim(),
        plantingDate: _plantingDateController.text.trim(),
        wateringSchedule: _wateringController.text.trim(),
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
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 20),
            Text(
              widget.initialPlant == null ? 'Add Plant' : 'Edit Plant',
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                color: _ink,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Plant Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              decoration: _plantInput('e.g. Sweet Basil'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a plant name'
                  : null,
            ),
            const SizedBox(height: 14),
            const Text('Zone'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _zone,
              decoration: _plantInput(null),
              items: {...widget.zones, _zone}
                  .map(
                    (zone) => DropdownMenuItem(value: zone, child: Text(zone)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _zone = value);
              },
            ),
            const SizedBox(height: 14),
            const Text('Description'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: _plantInput('Plant notes'),
            ),
            const SizedBox(height: 14),
            const Text('Planting Date'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _plantingDateController,
              decoration: _plantInput('e.g. April 12, 2026'),
            ),
            const SizedBox(height: 14),
            const Text('Watering Schedule'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _wateringController,
              decoration: _plantInput('e.g. Every 2 days'),
            ),
            const SizedBox(height: 14),
            const Text('Photo'),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _chooseImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _imageAsset == null
                    ? 'Choose a project photo'
                    : _imageAsset!.split('/').last,
              ),
            ),
            const SizedBox(height: 20),
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
                    style: FilledButton.styleFrom(backgroundColor: _green),
                    onPressed: _save,
                    child: Text(
                      widget.initialPlant == null
                          ? 'Save Plant'
                          : 'Save Changes',
                    ),
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

InputDecoration _plantInput(String? hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFDCE4DC)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFDCE4DC)),
  ),
);
