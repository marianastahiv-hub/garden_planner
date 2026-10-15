import 'package:flutter/material.dart';

const _green = Color(0xFF3F704F);
const _darkGreen = Color(0xFF25412F);
const _paper = Color(0xFFF9F9F7);
const _muted = Color(0xFF747A74);
const _galleryAssets = [
  'images/garden_1.jpg',
  'images/basil_growth.jpg',
  'images/basil_healthy.jpg',
  'images/tomato_growth.jpg',
];

class GalleryEntry {
  GalleryEntry({
    required this.id,
    required this.plantName,
    required this.date,
    required this.note,
    this.imageAsset,
  });

  final String id;
  String plantName;
  DateTime date;
  String note;
  String? imageAsset;
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    this.initialPlantName,
  });

  final String? initialPlantName;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? _selectedPlant;

  final List<GalleryEntry> _entries = [
    GalleryEntry(
      id: '1',
      plantName: 'Sweet Basil',
      date: DateTime(2026, 9, 17),
      note: 'Looking healthy — new leaves sprouting on each side.',
    ),
    GalleryEntry(
      id: '2',
      plantName: 'Sweet Basil',
      imageAsset: 'images/basil_growth.jpg',
      date: DateTime(2026, 8, 8),
      note: 'The leaves are growing well.',
    ),
    GalleryEntry(
      id: '3',
      plantName: 'Sweet Basil',
      imageAsset: 'images/basil_healthy.jpg',
      date: DateTime(2026, 7, 15),
      note: 'Moved the plant to a sunnier spot.',
    ),
    GalleryEntry(
      id: '4',
      plantName: 'Sweet Basil',
      date: DateTime(2026, 6, 24),
      note: 'First new leaves appeared.',
    ),
    GalleryEntry(
      id: '5',
      plantName: 'Sweet Basil',
      date: DateTime(2026, 6, 3),
      note: 'Planted basil seeds.',
    ),
    GalleryEntry(
      id: '6',
      plantName: 'Heritage Tomato',
      date: DateTime(2026, 9, 10),
      note: 'The tomatoes are starting to ripen.',
    ),
    GalleryEntry(
      id: '7',
      plantName: 'Heritage Tomato',
      imageAsset: 'images/tomato_growth.jpg',
      date: DateTime(2026, 5, 20),
      note: 'The plant is growing steadily.',
    ),
    GalleryEntry(
      id: '8',
      plantName: 'Heritage Tomato',
      date: DateTime(2026, 4, 12),
      note: 'Added to the Raised Beds.',
    ),
  ];

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

  List<String> get _plantNames {
    final names = _entries.map((entry) => entry.plantName).toSet().toList()
      ..sort();
    return names;
  }

  List<GalleryEntry> get _filteredEntries {
    final entries = _selectedPlant == null
        ? List<GalleryEntry>.from(_entries)
        : _entries
            .where((entry) => entry.plantName == _selectedPlant)
            .toList();

    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> _addEntry() async {
    final entry = await showModalBottomSheet<GalleryEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EntryFormSheet(
        plantNames: _plantNames,
        initialPlantName: _selectedPlant,
      ),
    );

    if (entry != null && mounted) {
      setState(() {
        _entries.add(entry);
        _selectedPlant ??= entry.plantName;
      });
    }
  }

  Future<void> _editEntry(GalleryEntry entry) async {
    final updated = await showModalBottomSheet<GalleryEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EntryFormSheet(
        plantNames: _plantNames,
        initialPlantName: entry.plantName,
        entry: entry,
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        final index = _entries.indexWhere((item) => item.id == updated.id);
        if (index != -1) _entries[index] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredEntries;

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        title: const Text(
          'Gallery',
          style: TextStyle(
            fontFamily: 'Serif',
            fontSize: 24,
            color: _darkGreen,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              children: [
                _FilterPill(
                  label: 'All Plants',
                  selected: _selectedPlant == null,
                  onTap: () => setState(() => _selectedPlant = null),
                ),
                ..._plantNames.map(
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
                ? const Center(child: Text('No entries yet. Add one with +'))
                : _selectedPlant == null
                    ? _buildAllPlants(entries)
                    : _buildPlantFeed(entries),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_gallery_entry',
        backgroundColor: _green,
        foregroundColor: Colors.white,
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllPlants(List<GalleryEntry> entries) {
    final grouped = <String, List<GalleryEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.plantName, () => []).add(entry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
      children: [
        _EntryCard(
          entry: entries.first,
          featured: true,
          onTap: () => _editEntry(entries.first),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress Timeline',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                final firstPlant = entries.first.plantName;
                setState(() => _selectedPlant = firstPlant);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: entries.reversed.take(12).toList().asMap().entries.map(
              (item) {
                final entry = item.value;
                final colors = [
                  const Color(0xFFD5E7CC),
                  const Color(0xFFB9D6A7),
                  const Color(0xFF91BE77),
                  const Color(0xFF6EA34F),
                  const Color(0xFFF3D6B6),
                  const Color(0xFFEDA977),
                  const Color(0xFFDF713D),
                ];
                return GestureDetector(
                  onTap: () => _editEntry(entry),
                  child: Container(
                    width: 76,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      color: colors[item.key % colors.length],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _shortDate(entry.date),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
        const SizedBox(height: 18),
        ...grouped.entries.map((group) {
          final plantEntries = group.value
            ..sort((a, b) => b.date.compareTo(a.date));
          final latest = plantEntries.first;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${plantEntries.length} ${plantEntries.length == 1 ? 'entry' : 'entries'}',
                  style: const TextStyle(fontSize: 11, color: _muted),
                ),
                const SizedBox(height: 8),
                _EntryCard(
                  entry: latest,
                  onTap: () => _editEntry(latest),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlantFeed(List<GalleryEntry> entries) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _EntryCard(
        entry: entries[index],
        featured: index == 0,
        onTap: () => _editEntry(entries[index]),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: _darkGreen,
        side: BorderSide(
          color: selected ? _darkGreen : const Color(0xFFE0E2DD),
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : _muted,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.onTap,
    this.featured = false,
  });

  final GalleryEntry entry;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: featured ? 230 : 165,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _galleryImage(entry.imageAsset),
                  if (featured)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(
                          color: _darkGreen,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
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
                      color: _darkGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_formatDate(entry.date)} · Week ${_weekNumber(entry.date)}',
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      entry.note,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _galleryImage(String? assetPath) {
  if (assetPath != null) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
  return const _ImagePlaceholder();
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFB7D3AE),
      child: Icon(
        Icons.photo_outlined,
        size: 42,
        color: Color(0xFF789176),
      ),
    );
  }
}

class _EntryFormSheet extends StatefulWidget {
  const _EntryFormSheet({
    required this.plantNames,
    required this.initialPlantName,
    this.entry,
  });

  final List<String> plantNames;
  final String? initialPlantName;
  final GalleryEntry? entry;

  @override
  State<_EntryFormSheet> createState() => _EntryFormSheetState();
}

class _EntryFormSheetState extends State<_EntryFormSheet> {
  late final TextEditingController _noteController;
  late String _plantName;
  late DateTime _date;
  String? _imageAsset;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _plantName = entry?.plantName ??
        widget.initialPlantName ??
        (widget.plantNames.isNotEmpty ? widget.plantNames.first : 'New Plant');
    _date = entry?.date ?? DateTime.now();
    _noteController = TextEditingController(text: entry?.note ?? '');
    _imageAsset = entry?.imageAsset;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('Choose a project image', style: TextStyle(fontSize: 18)),
            ),
            ..._galleryAssets.map((asset) => ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(asset, width: 56, height: 44, fit: BoxFit.cover),
                  ),
                  title: Text(asset.split('/').last),
                  trailing: asset == _imageAsset
                      ? const Icon(Icons.check, color: _green)
                      : null,
                  onTap: () => Navigator.pop(context, asset),
                )),
          ],
        ),
      ),
    );
    if (image != null && mounted) setState(() => _imageAsset = image);
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

  void _save() {
    final existing = widget.entry;
    Navigator.pop(
      context,
      GalleryEntry(
        id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        plantName: _plantName,
        date: _date,
        note: _noteController.text.trim(),
        imageAsset: _imageAsset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plants = widget.plantNames.isEmpty
        ? [_plantName]
        : {...widget.plantNames, _plantName}.toList();

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
            const SizedBox(height: 18),
            Text(
              widget.entry == null ? 'New Gallery Entry' : 'Edit Gallery Entry',
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                color: _darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Plant'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: plants.contains(_plantName) ? _plantName : plants.first,
              decoration: _decoration(),
              items: plants
                  .map((name) =>
                      DropdownMenuItem(value: name, child: Text(name)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _plantName = value);
              },
            ),
            const SizedBox(height: 14),
            const Text('Photo'),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickPhoto,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _galleryImage(_imageAsset),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: FilledButton.tonalIcon(
                            onPressed: _pickPhoto,
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: const Text('Add Photo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Date'),
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: _chooseDate,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                alignment: Alignment.centerLeft,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 17),
                  const SizedBox(width: 9),
                  Text(_formatDate(_date)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Note'),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: _decoration(hint: 'What changed since the last entry?'),
            ),
            const SizedBox(height: 18),
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
                    child: const Text('Save Entry'),
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

InputDecoration _decoration({String? hint}) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3DC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3DC)),
      ),
    );

String _formatDate(DateTime date) {
  const months = [
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
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _shortDate(DateTime date) {
  const months = [
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
  ];
  return '${months[date.month - 1]} ${date.day}';
}

int _weekNumber(DateTime date) {
  final dayOfYear = int.parse(
    DateTime(date.year, date.month, date.day)
        .difference(DateTime(date.year, 1, 1))
        .inDays
        .toString(),
  );
  return (dayOfYear ~/ 7) + 1;
}