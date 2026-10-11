import 'package:flutter/material.dart';

import '../core/widgets/garden_add_fab.dart';
import '../core/widgets/project_asset_picker.dart';
import '../data/garden_store.dart';
import '../models/garden_plant.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF1E3326);
const _paper = Color(0xFFF9F9F7);
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
      builder: (_) => const _PlantFormSheet(),
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
      builder: (_) => _PlantDetailsSheet(
        plant: plant,
        onViewGallery: widget.onViewGallery,
        onChanged: () {
          GardenStore.instance.changed();
          if (mounted) setState(() {});
        },
      ),
    );

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        title: const Text(
          'My Plants',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 24,
            color: _ink,
          ),
        ),
      ),
      body: _plants.isEmpty
          ? const Center(child: Text('No plants yet. Add your first plant!'))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
              itemCount: _plants.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemBuilder: (context, index) {
                final plant = _plants[index];
                return _PlantCard(
                  plant: plant,
                  onTap: () => _showPlant(plant),
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
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({
    required this.plant,
    required this.onTap,
  });

  final GardenPlant plant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE3E7E2)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _plantImage(plant.imageAsset),
              ),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F0E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plant.zone,
                      style: const TextStyle(fontSize: 10, color: _green),
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
}

Widget _plantImage(String? assetPath) {
  if (assetPath == null || assetPath.isEmpty) {
    return const ColoredBox(
      color: Color(0xFFDCE8D7),
      child: Icon(
        Icons.photo_outlined,
        size: 36,
        color: Color(0xFF789176),
      ),
    );
  }

  return Image.asset(
    assetPath,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const ColoredBox(
      color: Color(0xFFDCE8D7),
      child: Icon(Icons.broken_image_outlined),
    ),
  );
}

class _PlantDetailsSheet extends StatefulWidget {
  const _PlantDetailsSheet({
    required this.plant,
    required this.onViewGallery,
    required this.onChanged,
  });

  final GardenPlant plant;
  final ValueChanged<String> onViewGallery;
  final VoidCallback onChanged;

  @override
  State<_PlantDetailsSheet> createState() => _PlantDetailsSheetState();
}

class _PlantDetailsSheetState extends State<_PlantDetailsSheet> {
  static const _zones = [
    'Greenhouse',
    'Raised Beds',
    'Front Yard',
    'Orchard',
    'Indoor Loft',
    'Herb Garden',
    'Compost',
  ];

  Future<void> _pickPhoto() async {
    final asset = await ProjectAssetPicker.show(
      context,
      selectedAsset: widget.plant.imageAsset,
    );
    if (asset != null && mounted) {
      setState(() => widget.plant.imageAsset = asset);
      widget.onChanged();
    }
  }

  Future<void> _editText({
    required String title,
    required String initialValue,
    required ValueChanged<String> onSave,
    int maxLines = 1,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _TextEditDialog(
        title: title,
        initialValue: initialValue,
        maxLines: maxLines,
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) return;

    setState(() => onSave(result.trim()));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 22,
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
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _editableText(
                    plant.name,
                    onTap: () => _editText(
                      title: 'Plant name',
                      initialValue: plant.name,
                      onSave: (value) => plant.name = value,
                    ),
                    bold: true,
                    fontSize: 20,
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onViewGallery(plant.name);
                  },
                  child: const Text('View Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickPhoto,
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _plantImage(plant.imageAsset),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: FilledButton.tonalIcon(
                          onPressed: _pickPhoto,
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 16,
                          ),
                          label: const Text('Upload Photo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _detailRow(
              'Zone Assignment',
              DropdownButton<String>(
                value: _zones.contains(plant.zone) ? plant.zone : _zones.first,
                underline: const SizedBox.shrink(),
                items: _zones
                    .map((zone) =>
                        DropdownMenuItem(value: zone, child: Text(zone)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => plant.zone = value);
                    widget.onChanged();
                  }
                },
              ),
            ),
            _detailRow(
              'Planting Date',
              _editableText(
                plant.plantingDate,
                onTap: () => _editText(
                  title: 'Planting date',
                  initialValue: plant.plantingDate,
                  onSave: (value) => plant.plantingDate = value,
                ),
              ),
            ),
            _detailRow(
              'Watering Schedule',
              _editableText(
                plant.wateringSchedule,
                onTap: () => _editText(
                  title: 'Watering schedule',
                  initialValue: plant.wateringSchedule,
                  onSave: (value) => plant.wateringSchedule = value,
                ),
                color: const Color(0xFFD76D48),
              ),
            ),
            const SizedBox(height: 8),
            _editableText(
              plant.description,
              onTap: () => _editText(
                title: 'Description',
                initialValue: plant.description,
                maxLines: 3,
                onSave: (value) => plant.description = value,
              ),
              color: Colors.black54,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _green),
                onPressed: () {
                  widget.onChanged();
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            Flexible(child: value),
          ],
        ),
      );

  Widget _editableText(
    String text, {
    required VoidCallback onTap,
    bool bold = false,
    Color? color,
    double fontSize = 14,
    TextAlign textAlign = TextAlign.right,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text(
          text,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _PlantFormSheet extends StatefulWidget {
  const _PlantFormSheet();

  @override
  State<_PlantFormSheet> createState() => _PlantFormSheetState();
}

class _PlantFormSheetState extends State<_PlantFormSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _zone = 'Greenhouse';
  String _watering = 'Every 2 days (Morning)';
  String? _imageAsset;

  static const _zones = [
    'Greenhouse',
    'Raised Beds',
    'Front Yard',
    'Orchard',
    'Indoor Loft',
    'Herb Garden',
    'Compost',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final asset = await ProjectAssetPicker.show(
      context,
      selectedAsset: _imageAsset,
    );
    if (asset != null && mounted) {
      setState(() => _imageAsset = asset);
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(
      context,
      GardenPlant(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        zone: _zone,
        description: _descriptionController.text.trim(),
        plantingDate: 'Select date',
        wateringSchedule: _watering,
        imageAsset: _imageAsset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
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
            const SizedBox(height: 20),
            const Text(
              'Add New Plant',
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                color: _ink,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Plant Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: decoration.copyWith(hintText: 'e.g. Cherry Tomato'),
            ),

            // Photo picker in the add form.
            const SizedBox(height: 14),
            const Text('Plant Photo'),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickPhoto,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE8D7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _imageAsset == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            color: _green,
                            size: 28,
                          ),
                          SizedBox(height: 6),
                          Text('Add Photo'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _imageAsset!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),
            const Text('Zone Assignment'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _zone,
              decoration: decoration,
              items: _zones
                  .map((zone) =>
                      DropdownMenuItem(value: zone, child: Text(zone)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _zone = value);
              },
            ),
            const SizedBox(height: 14),
            const Text('Watering Schedule'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _watering,
              decoration: decoration,
              items: const [
                'Every day',
                'Every 2 days (Morning)',
                'Every 3 days',
                'Every 4 days',
                'Once a week',
              ]
                  .map(
                    (schedule) => DropdownMenuItem(
                      value: schedule,
                      child: Text(schedule),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _watering = value);
              },
            ),
            const SizedBox(height: 14),
            const Text('Description'),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: decoration.copyWith(
                hintText: 'Add a short note about this plant',
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
                    child: const Text('Save Plant'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TextEditDialog extends StatefulWidget {
  const _TextEditDialog({
    required this.title,
    required this.initialValue,
    required this.maxLines,
  });

  final String title;
  final String initialValue;
  final int maxLines;

  @override
  State<_TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<_TextEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLines: widget.maxLines,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}


