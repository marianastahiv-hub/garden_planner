import 'package:flutter/material.dart';

import '../data/garden_store.dart';
import '../models/garden_task.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF1E3326);
const _paper = Color(0xFFF9F9F7);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenZones,
    required this.onOpenPlants,
    required this.onOpenTasks,
  });

  final VoidCallback onOpenZones;
  final VoidCallback onOpenPlants;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final store = GardenStore.instance;
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final tasks = store.tasks.where((task) => !task.isCompleted).toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
            final upcoming = tasks.take(5).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, Garden Keeper', style: TextStyle(color: Color(0xFF68766D), fontSize: 14)),
                          SizedBox(height: 3),
                          Text('Sarah Jenkins', style: TextStyle(fontFamily: 'Serif', fontSize: 25, color: _ink)),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: const Color(0xFFE4EEE6),
                      child: const Icon(Icons.person, color: _green, size: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _CountCard(
                        title: 'PLANTS', count: '${store.plants.length}',
                        subtitle: 'In your catalog', icon: Icons.spa_outlined,
                        color: _green, onTap: onOpenPlants,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _CountCard(
                        title: 'ZONES', count: '${store.zones.length}',
                        subtitle: 'Managed plots', icon: Icons.location_on_outlined,
                        color: const Color(0xFFE88964), onTap: onOpenZones,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text('Upcoming Tasks', style: TextStyle(fontFamily: 'Serif', fontSize: 23, color: _ink)),
                    ),
                    TextButton(
                      onPressed: onOpenTasks,
                      style: TextButton.styleFrom(foregroundColor: _green, padding: EdgeInsets.zero),
                      child: const Text('View Calendar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (upcoming.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: _cardDecoration(),
                    child: const Text('No upcoming tasks', style: TextStyle(color: Colors.black54)),
                  )
                else
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: upcoming.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => _TaskPreview(
                        task: upcoming[index], onTap: onOpenTasks,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFE7F0E9),
                        child: Icon(Icons.wb_sunny_outlined, color: _green),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Seasonal Shift Alert', style: TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                            SizedBox(height: 3),
                            Text('Days are lengthening. Adjust watering intervals for high-growth zones.', style: TextStyle(color: Color(0xFF68766D), fontSize: 12, height: 1.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.title, required this.count, required this.subtitle, required this.icon, required this.color, required this.onTap});
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 142,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6F3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDCE6DE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(icon, color: color, size: 22), const Spacer(), Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))]),
              const Spacer(),
              Text(count, style: const TextStyle(fontFamily: 'Serif', fontSize: 34, color: _ink, height: 1)),
              const SizedBox(height: 6),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF68766D), fontSize: 11)),
            ],
          ),
        ),
      );
}

class _TaskPreview extends StatelessWidget {
  const _TaskPreview({required this.task, required this.onTap});
  final GardenTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 205,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0E7E1))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF202820))),
                  const SizedBox(height: 4),
                  Text(_dueLabel(task.dueDate), style: const TextStyle(color: Color(0xFF87968C), fontSize: 11)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE8F0E9), borderRadius: BorderRadius.circular(20)),
                    child: Text(task.zone, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE0E7E1)),
    );

String _dueLabel(DateTime due) {
  final today = DateTime.now();
  final date = DateTime(due.year, due.month, due.day);
  final current = DateTime(today.year, today.month, today.day);
  final difference = date.difference(current).inDays;
  if (difference == 0) return 'Due Today';
  if (difference == 1) return 'Tomorrow';
  if (difference == -1) return 'Yesterday';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[due.month - 1]} ${due.day}';
}
