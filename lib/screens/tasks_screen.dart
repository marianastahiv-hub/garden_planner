import 'package:flutter/material.dart';

import '../core/widgets/garden_add_fab.dart';
import '../data/garden_store.dart';
import '../models/garden_task.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF1E3326);
const _paper = Color(0xFFF9F9F7);
const _orange = Color(0xFFD97752);

// Простий перелік завдань: додавання форми та позначення виконаних.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const _zones = [
    'Greenhouse',
    'Raised Beds',
    'Front Yard',
    'Orchard',
    'Indoor Loft',
    'Herb Garden',
    'Compost',
  ];

  // Форма повертає нове завдання; Store додає його до спільного списку.
  Future<void> _addTask() async {
    final task = await showModalBottomSheet<GardenTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _TaskFormSheet(zones: _zones),
    );
    if (task != null && mounted) {
      setState(() => GardenStore.instance.addTask(task));
    }
  }

  // Зміна прапорця оновлює й сам екран, і дашборд.
  void _toggleTask(GardenTask task, bool? value) {
    setState(() {
      task.isCompleted = value ?? !task.isCompleted;
      GardenStore.instance.changed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = List<GardenTask>.from(GardenStore.instance.tasks)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        title: const Text(
          'Tasks',
          style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: _ink),
        ),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Add your first task!'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _TaskCard(
                task: tasks[index],
                onChanged: (value) => _toggleTask(tasks[index], value),
              ),
            ),
      floatingActionButton: GardenAddFab(
        heroTag: 'add_task',
        tooltip: 'Add task',
        onPressed: _addTask,
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onChanged});
  final GardenTask task;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E6E0)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: completed,
            onChanged: onChanged,
            activeColor: _green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: completed ? Colors.grey : const Color(0xFF202820),
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(task.zone, style: const TextStyle(fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_monthDay(task.dueDate), style: const TextStyle(fontSize: 11, color: _orange)),
        ],
      ),
    );
  }
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({required this.zones});
  final List<String> zones;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _zone = widget.zones.first;
  DateTime _dueDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) setState(() => _dueDate = date);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      GardenTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _nameController.text.trim(),
        zone: _zone,
        plant: '',
        dueDate: DateTime(_dueDate.year, _dueDate.month, _dueDate.day),
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
                const Text('New Task', style: TextStyle(fontFamily: 'Serif', fontSize: 22, color: _ink)),
                const SizedBox(height: 16),
                const _FieldLabel('Task Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('e.g. Water the herbs'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task name'
                      : null,
                ),
                const SizedBox(height: 14),
                const _FieldLabel('Zone'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _zone,
                  decoration: _inputDecoration(null),
                  items: widget.zones
                      .map((zone) => DropdownMenuItem(value: zone, child: Text(zone)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _zone = value);
                  },
                ),
                const SizedBox(height: 14),
                const _FieldLabel('Due Date'),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: _chooseDate,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(_formatDate(_dueDate)),
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
                        child: const Text('Create'),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF59635B)),
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

String _monthDay(DateTime date) => '${_monthName(date.month)} ${date.day}';
String _formatDate(DateTime date) => '${_monthDay(date)}, ${date.year}';

String _monthName(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month - 1];
