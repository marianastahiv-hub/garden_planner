import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/widgets/garden_add_fab.dart';
import '../features/garden/bloc/garden_bloc.dart';
import '../features/garden/bloc/garden_event.dart';
import '../features/garden/bloc/garden_state.dart';
import '../models/garden_task.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF1E3326);
const _paper = Color(0xFFF9F9F7);
const _orange = Color(0xFFD97752);
const _muted = Color(0xFF68766D);

// Простий перелік завдань: додавання форми та позначення виконаних.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Форма повертає завдання; BLoC виконує create/update у репозиторії.
  Future<void> _addTask() async {
    final zones = context
        .read<GardenBloc>()
        .state
        .zones
        .map((zone) => zone.name)
        .toList();
    final task = await showModalBottomSheet<GardenTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _TaskFormSheet(zones: zones.isEmpty ? const ['Garden'] : zones),
    );
    if (task != null && mounted) {
      context.read<GardenBloc>().add(GardenTaskAdded(task));
    }
  }

  // Зміна прапорця оновлює й сам екран, і дашборд.
  void _toggleTask(GardenTask task, bool? value) {
    context.read<GardenBloc>().add(
      GardenTaskUpdated(
        GardenTask(
          id: task.id,
          title: task.title,
          zone: task.zone,
          plant: task.plant,
          dueDate: task.dueDate,
          priority: task.priority,
          isCompleted: value ?? !task.isCompleted,
        ),
      ),
    );
  }

  Future<void> _editTask(GardenTask task, List<String> zones) async {
    final updated = await showModalBottomSheet<GardenTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TaskFormSheet(zones: zones, initialTask: task),
    );
    if (updated != null && mounted) {
      context.read<GardenBloc>().add(GardenTaskUpdated(updated));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        title: const Text(
          'Tasks',
          style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: _ink),
        ),
      ),
      body: BlocBuilder<GardenBloc, GardenState>(
        builder: (context, state) {
          if (state.status == GardenStatus.loading ||
              state.status == GardenStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = List<GardenTask>.from(state.tasks)
            ..sort((a, b) {
              if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
              return a.dueDate.compareTo(b.dueDate);
            });
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add your first task!'),
            );
          }
          final zones = state.zones.map((zone) => zone.name).toList();
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: ValueKey(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                onDismissed: (_) =>
                    context.read<GardenBloc>().add(GardenTaskRemoved(task.id)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () =>
                      _editTask(task, zones.isEmpty ? const ['Garden'] : zones),
                  child: _TaskCard(
                    task: task,
                    onChanged: (value) => _toggleTask(task, value),
                  ),
                ),
              );
            },
          );
        },
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
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
                Text(
                  task.zone,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _monthDay(task.dueDate),
            style: const TextStyle(fontSize: 11, color: _orange),
          ),
        ],
      ),
    );
  }
}

class _TaskFormSheet extends StatefulWidget {
  const _TaskFormSheet({required this.zones, this.initialTask});
  final List<String> zones;
  final GardenTask? initialTask;

  @override
  State<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<_TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _zone;
  late DateTime _dueDate;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _nameController = TextEditingController(text: task?.title ?? '');
    _zone = task?.zone ?? widget.zones.first;
    _dueDate = task?.dueDate ?? DateTime.now();
    _priority = task?.priority ?? TaskPriority.medium;
  }

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
        id:
            widget.initialTask?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: _nameController.text.trim(),
        zone: _zone,
        plant: widget.initialTask?.plant ?? '',
        dueDate: DateTime(_dueDate.year, _dueDate.month, _dueDate.day),
        priority: _priority,
        isCompleted: widget.initialTask?.isCompleted ?? false,
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
              widget.initialTask == null ? 'New Task' : 'Edit Task',
              style: const TextStyle(
                fontFamily: 'Serif',
                fontSize: 22,
                color: _ink,
              ),
            ),
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
              initialValue: _zone,
              decoration: _inputDecoration(null),
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
            const SizedBox(height: 14),
            const _FieldLabel('Priority'),
            const SizedBox(height: 6),
            Row(
              children: TaskPriority.values.map((priority) {
                final selected = _priority == priority;
                final label = switch (priority) {
                  TaskPriority.low => 'Low',
                  TaskPriority.medium => 'Medium',
                  TaskPriority.high => 'High',
                };
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: priority == TaskPriority.high ? 0 : 8,
                    ),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _priority = priority),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: selected
                            ? const Color(0xFFE8F0EA)
                            : Colors.white,
                        foregroundColor: selected ? _green : _muted,
                        side: BorderSide(
                          color: selected ? _green : const Color(0xFFDCE4DC),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: Text(label),
                    ),
                  ),
                );
              }).toList(),
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
                    child: Text(widget.initialTask == null ? 'Create' : 'Save'),
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
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF59635B),
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

String _monthDay(DateTime date) => '${_monthName(date.month)} ${date.day}';
String _formatDate(DateTime date) => '${_monthDay(date)}, ${date.year}';

String _monthName(int month) => const [
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
