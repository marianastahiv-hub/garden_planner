import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/widgets/garden_add_fab.dart';
import '../core/widgets/project_asset_picker.dart';
import '../features/garden/bloc/garden_bloc.dart';
import '../features/garden/bloc/garden_event.dart';
import '../features/garden/bloc/garden_state.dart';
import '../models/garden_gallery_entry.dart';
import '../models/garden_plant.dart';

const _ink = Color(0xFF25412F);
const _green = Color(0xFF3F704F);
const _paper = Color(0xFFF9F9F7);
const _muted = Color(0xFF747A74);

/// Growth journal. Filters are built from the user's plant catalog so every
/// plant is available even before its first journal entry.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, this.initialPlantName});
  final String? initialPlantName;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? _selectedPlant;

  @override
  void initState() {
    super.initState();
    _selectedPlant = widget.initialPlantName;
  }

  @override
  void didUpdateWidget(covariant GalleryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPlantName != widget.initialPlantName) {
      _selectedPlant = widget.initialPlantName;
    }
  }

  Future<void> _openEntryForm({
    required List<GardenPlant> plants,
    GardenGalleryEntry? entry,
  }) async {
    final entryResult = await showModalBottomSheet<GardenGalleryEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _GalleryEntryForm(
        plants: plants,
        initialEntry: entry,
        initialPlantName: _selectedPlant,
      ),
    );
    if (entryResult == null || !mounted) return;
    final bloc = context.read<GardenBloc>();
    bloc.add(
      entry == null
          ? GardenGalleryEntryAdded(entryResult)
          : GardenGalleryEntryUpdated(entryResult),
    );
  }

  Future<void> _confirmDelete(GardenGalleryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete journal entry?'),
        content: const Text('This entry will be removed from the gallery.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<GardenBloc>().add(GardenGalleryEntryRemoved(entry.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _paper,
    appBar: AppBar(
      backgroundColor: _paper,
      title: const Text(
        'Gallery',
        style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: _ink),
      ),
    ),
    body: BlocBuilder<GardenBloc, GardenState>(
      builder: (context, state) {
        if (state.status == GardenStatus.initial ||
            state.status == GardenStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final plantNames = <String>{
          ...state.plants.map((plant) => plant.name),
          ...state.galleryEntries.map((entry) => entry.plantName),
        }.toList()..sort();
        if (_selectedPlant != null && !plantNames.contains(_selectedPlant)) {
          _selectedPlant = null;
        }
        final entries =
            state.galleryEntries
                .where(
                  (entry) =>
                      _selectedPlant == null ||
                      entry.plantName == _selectedPlant,
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        final latestByPlant = <String, GardenGalleryEntry>{};
        for (final entry in state.galleryEntries) {
          final current = latestByPlant[entry.plantName];
          if (current == null || entry.date.isAfter(current.date)) {
            latestByPlant[entry.plantName] = entry;
          }
        }
        return Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 5,
                ),
                children: [
                  _FilterPill(
                    label: 'All Plants',
                    selected: _selectedPlant == null,
                    onTap: () => setState(() => _selectedPlant = null),
                  ),
                  ...plantNames.map(
                    (name) => _FilterPill(
                      label: name,
                      selected: _selectedPlant == name,
                      onTap: () => setState(() => _selectedPlant = name),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        _selectedPlant == null
                            ? 'No journal entries yet. Tap + to add one.'
                            : 'No entries for $_selectedPlant yet. Tap + to add one.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return Dismissible(
                          key: ValueKey(entry.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            await _confirmDelete(entry);
                            return false;
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _openEntryForm(
                              plants: state.plants,
                              entry: entry,
                            ),
                            child: _EntryCard(
                              entry: entry,
                              isLatest: identical(
                                latestByPlant[entry.plantName],
                                entry,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
    floatingActionButton: GardenAddFab(
      heroTag: 'add_gallery_entry',
      tooltip: 'Add growth journal entry',
      onPressed: () =>
          _openEntryForm(plants: context.read<GardenBloc>().state.plants),
    ),
  );
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: _ink,
      side: BorderSide(color: selected ? _ink : const Color(0xFFE0E2DD)),
      labelStyle: TextStyle(
        fontSize: 12,
        color: selected ? Colors.white : _muted,
      ),
      shape: const StadiumBorder(),
    ),
  );
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.isLatest});
  final GardenGalleryEntry entry;
  final bool isLatest;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 205,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _galleryImage(entry.imageAsset),
              if (isLatest)
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _ink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Latest',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.plantName,
                style: const TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _dateLabel(entry.date),
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
              const SizedBox(height: 8),
              Text(
                entry.note,
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GalleryEntryForm extends StatefulWidget {
  const _GalleryEntryForm({
    required this.plants,
    required this.initialPlantName,
    this.initialEntry,
  });
  final List<GardenPlant> plants;
  final String? initialPlantName;
  final GardenGalleryEntry? initialEntry;

  @override
  State<_GalleryEntryForm> createState() => _GalleryEntryFormState();
}

class _GalleryEntryFormState extends State<_GalleryEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plantController;
  late final TextEditingController _noteController;
  late DateTime _date;
  late String? _plantName;
  String? _imageAsset;

  List<String> get _plantOptions => <String>{
    ...widget.plants.map((plant) => plant.name),
    if (widget.initialEntry != null) widget.initialEntry!.plantName,
  }.toList()..sort();

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _plantName =
        entry?.plantName ??
        (widget.initialPlantName != null &&
                _plantOptions.contains(widget.initialPlantName)
            ? widget.initialPlantName
            : (_plantOptions.isEmpty ? null : _plantOptions.first));
    _plantController = TextEditingController(text: _plantName ?? '');
    _noteController = TextEditingController(text: entry?.note ?? '');
    _date = entry?.date ?? DateTime.now();
    _imageAsset = entry?.imageAsset;
  }

  @override
  void dispose() {
    _plantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  Future<void> _chooseImage() async {
    final image = await ProjectAssetPicker.show(
      context,
      selectedAsset: _imageAsset,
    );
    if (image != null && mounted) setState(() => _imageAsset = image);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      GardenGalleryEntry(
        id:
            widget.initialEntry?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        plantName: _plantOptions.isEmpty
            ? _plantController.text.trim()
            : _plantName!,
        date: DateTime(_date.year, _date.month, _date.day),
        note: _noteController.text.trim(),
        imageAsset: _imageAsset,
      ),
    );
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
              widget.initialEntry == null ? 'New Journal Entry' : 'Edit Entry',
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                color: _ink,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Plant'),
            const SizedBox(height: 6),
            if (_plantOptions.isEmpty)
              TextFormField(
                controller: _plantController,
                decoration: _inputDecoration('Plant name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a plant name'
                    : null,
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _plantName,
                decoration: _inputDecoration(null),
                items: _plantOptions
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _plantName = value),
              ),
            const SizedBox(height: 14),
            const Text('Date'),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _chooseDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(_dateLabel(_date)),
            ),
            const SizedBox(height: 14),
            const Text('Photo'),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _chooseImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _imageAsset == null
                    ? 'Choose a photo'
                    : _imageAsset!.split('/').last,
              ),
            ),
            if (_imageAsset != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.asset(
                    _imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _ImagePlaceholder(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            const Text('Notes'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: _inputDecoration('What changed or grew?'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Add a short note'
                  : null,
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
                      widget.initialEntry == null ? 'Create' : 'Save',
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

InputDecoration _inputDecoration(String? hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(11),
    borderSide: const BorderSide(color: Color(0xFFDCE4DC)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(11),
    borderSide: const BorderSide(color: Color(0xFFDCE4DC)),
  ),
);

Widget _galleryImage(String? asset) => asset == null
    ? const _ImagePlaceholder()
    : Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _ImagePlaceholder(),
      );

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFB7D3AE),
    child: Icon(Icons.photo_outlined, size: 42, color: Color(0xFF789176)),
  );
}

String _dateLabel(DateTime date) =>
    '${_month(date.month)} ${date.day}, ${date.year} · Week ${date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7 + 1}';

String _month(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];
