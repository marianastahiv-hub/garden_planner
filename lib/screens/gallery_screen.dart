import 'package:flutter/material.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF25412F);
const _paper = Color(0xFFF9F9F7);
const _muted = Color(0xFF747A74);

class _GalleryEntry {
  const _GalleryEntry({
    required this.plant,
    required this.date,
    required this.image,
    required this.note,
  });

  final String plant;
  final DateTime date;
  final String? image;
  final String note;
}

// Демонстраційна галерея з прикладами й фільтром за видом рослини.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, this.initialPlantName});
  final String? initialPlantName;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? _selectedPlant;

  static final _entries = <_GalleryEntry>[
    _GalleryEntry(plant: 'Sweet Basil', date: DateTime(2026, 9, 17), image: 'images/basil_healthy.jpg', note: 'New leaves are sprouting.'),
    _GalleryEntry(plant: 'Sweet Basil', date: DateTime(2026, 8, 8), image: 'images/basil_growth.jpg', note: 'The leaves are growing well.'),
    _GalleryEntry(plant: 'Sweet Basil', date: DateTime(2026, 7, 15), image: 'images/basil_healthy.jpg', note: 'Moved the plant to a sunnier spot.'),
    _GalleryEntry(plant: 'Sweet Basil', date: DateTime(2026, 6, 3), image: null, note: 'Planted basil seeds.'),
    _GalleryEntry(plant: 'Heritage Tomato', date: DateTime(2026, 9, 10), image: 'images/tomato_growth.jpg', note: 'The tomatoes are starting to ripen.'),
    _GalleryEntry(plant: 'Heritage Tomato', date: DateTime(2026, 5, 20), image: 'images/tomato_growth.jpg', note: 'The plant is growing steadily.'),
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

  List<String> get _plantNames => _entries.map((entry) => entry.plant).toSet().toList()..sort();

  List<_GalleryEntry> get _visibleEntries {
    final entries = _selectedPlant == null
        ? List<_GalleryEntry>.from(_entries)
        : _entries.where((entry) => entry.plant == _selectedPlant).toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _visibleEntries;
    final latestByPlant = <String, _GalleryEntry>{};
    for (final entry in entries.reversed) {
      latestByPlant[entry.plant] = entry;
    }

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        title: const Text('Gallery', style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: _ink)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              children: [
                _FilterPill(label: 'All Plants', selected: _selectedPlant == null, onTap: () => setState(() => _selectedPlant = null)),
                ..._plantNames.map((name) => _FilterPill(
                      label: name,
                      selected: _selectedPlant == name,
                      onTap: () => setState(() => _selectedPlant = name),
                    )),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _EntryCard(
                  entry: entry,
                  isLatest: identical(latestByPlant[entry.plant], entry),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});
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
          labelStyle: TextStyle(fontSize: 12, color: selected ? Colors.white : _muted),
          shape: const StadiumBorder(),
        ),
      );
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.isLatest});
  final _GalleryEntry entry;
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
                  _galleryImage(entry.image),
                  if (isLatest)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Latest', style: TextStyle(color: Colors.white, fontSize: 11)),
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
                  Text(entry.plant, style: const TextStyle(color: _ink, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 3),
                  Text(_dateLabel(entry.date), style: const TextStyle(fontSize: 12, color: _muted)),
                  const SizedBox(height: 8),
                  Text(entry.note, style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
          ],
        ),
      );
}

Widget _galleryImage(String? asset) {
  if (asset == null) return const _ImagePlaceholder();
  return Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _ImagePlaceholder());
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: Color(0xFFB7D3AE),
        child: Icon(Icons.photo_outlined, size: 42, color: Color(0xFF789176)),
      );
}

String _dateLabel(DateTime date) => '${_month(date.month)} ${date.day}, ${date.year} · Week ${date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7 + 1}';

String _month(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month - 1];
