import 'package:flutter/material.dart';

import '../core/widgets/garden_add_fab.dart';
import '../data/garden_store.dart';
import '../models/garden_task.dart';

const _green = Color(0xFF3F704F);
const _ink = Color(0xFF1E3326);
const _paper = Color(0xFFF9F9F7);
const _orange = Color(0xFFD97752);

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late DateTime _selectedDate;
  DateTime _displayedMonth = DateTime.now();
  bool _calendarExpanded = false;
  List<GardenTask> get _tasks => GardenStore.instance.tasks;

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
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _selectedDate = today;
    _displayedMonth = DateTime(today.year, today.month);
  }

  DateTime get _weekStart =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

  List<GardenTask> get _visibleTasks => _tasks
      .where((task) => _dateOnly(task.dueDate) == _selectedDate)
      .toList()
    ..sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? -1 : 1;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

  Future<void> _createTask() async {
    final task = await showModalBottomSheet<GardenTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _NewTaskSheet(
        zones: _zones,
        initialDate: _selectedDate,
      ),
    );

    if (task != null && mounted) {
      setState(() {
        GardenStore.instance.addTask(task);
        _selectedDate = _dateOnly(task.dueDate);
        _displayedMonth = DateTime(task.dueDate.year, task.dueDate.month);
      });
    }
  }

  Future<void> _editTask(GardenTask task) async {
    final updated = await showModalBottomSheet<GardenTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _NewTaskSheet(
        zones: _zones,
        initialDate: task.dueDate,
        task: task,
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        GardenStore.instance.replaceTask(updated);
        _selectedDate = _dateOnly(updated.dueDate);
        _displayedMonth = DateTime(updated.dueDate.year, updated.dueDate.month);
      });
    }
  }

  Future<void> _deleteTask(GardenTask task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _orange),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      setState(() => GardenStore.instance.removeTask(task.id));
    }
  }

  void _toggleTask(GardenTask task, bool? completed) {
    setState(() {
      task.isCompleted = completed ?? !task.isCompleted;
      GardenStore.instance.changed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = List.generate(
      7,
      (index) => _weekStart.add(Duration(days: index)),
    );
    final visibleTasks = _visibleTasks;

    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        title: const Text(
          'Tasks',
          style: TextStyle(fontFamily: 'Serif', fontSize: 24, color: _ink),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(weekDays),
          Expanded(
            child: visibleTasks.isEmpty
                ? Center(
                    child: Text(
                      'No tasks for ${_dateLabel(_selectedDate)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                    itemCount: visibleTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = visibleTasks[index];
                      return _TaskCard(
                        task: task,
                        onChanged: (value) => _toggleTask(task, value),
                        onEdit: () => _editTask(task),
                        onDelete: () => _deleteTask(task),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: GardenAddFab(
        heroTag: 'add_task',
        tooltip: 'Add task',
        onPressed: _createTask,
      ),
    );
  }

  Widget _buildCalendar(List<DateTime> weekDays) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Week'),
                selected: !_calendarExpanded,
                showCheckmark: false,
                onSelected: (_) => setState(() => _calendarExpanded = false),
                selectedColor: const Color(0xFFE4EEE6),
                labelStyle: TextStyle(
                  color: !_calendarExpanded ? _green : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Month'),
                selected: _calendarExpanded,
                showCheckmark: false,
                onSelected: (_) => setState(() {
                  _calendarExpanded = true;
                  _displayedMonth =
                      DateTime(_selectedDate.year, _selectedDate.month);
                }),
                selectedColor: const Color(0xFFE4EEE6),
                labelStyle: TextStyle(
                  color: _calendarExpanded ? _green : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (_calendarExpanded)
          _buildMonthCalendar()
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
            child: Row(
              children: weekDays.map((date) {
                final selected = _dateOnly(date) == _selectedDate;
                final hasTasks = _tasks.any(
                  (task) => _dateOnly(task.dueDate) == _dateOnly(date),
                );
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _selectedDate = _dateOnly(date);
                      _displayedMonth = DateTime(date.year, date.month);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? _green : Colors.transparent,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _weekday(date),
                            style: TextStyle(
                              fontSize: 11,
                              color: selected ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : _ink,
                            ),
                          ),
                          const SizedBox(height: 3),
                          _TaskDot(hasTasks: hasTasks, selected: selected),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildMonthCalendar() {
    final first = DateTime(_displayedMonth.year, _displayedMonth.month);
    final gridStart = first.subtract(Duration(days: first.weekday - 1));
    final days = List.generate(42, (index) => gridStart.add(Duration(days: index)));

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  );
                }),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  _monthYear(_displayedMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  );
                }),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          ...List.generate(6, (weekIndex) {
            final week = days.skip(weekIndex * 7).take(7).toList();
            return Row(
              children: week.map((date) {
                final inMonth = date.month == _displayedMonth.month;
                final selected = _dateOnly(date) == _selectedDate;
                final hasTasks = _tasks.any(
                  (task) => _dateOnly(task.dueDate) == _dateOnly(date),
                );
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() {
                      _selectedDate = _dateOnly(date);
                      _displayedMonth = DateTime(date.year, date.month);
                    }),
                    child: SizedBox(
                      height: 39,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? _green : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 12,
                                color: selected
                                    ? Colors.white
                                    : inMonth
                                        ? _ink
                                        : Colors.black26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          _TaskDot(hasTasks: hasTasks, selected: selected),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _TaskDot extends StatelessWidget {
  const _TaskDot({required this.hasTasks, required this.selected});
  final bool hasTasks;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: !hasTasks
              ? Colors.transparent
              : selected
                  ? Colors.white
                  : _green,
          shape: BoxShape.circle,
        ),
      );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final GardenTask task;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            side: const BorderSide(color: Color(0xFFDCE4DC), width: 2),
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
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
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
          PopupMenuButton<String>(
            tooltip: 'Task options',
            onSelected: (action) {
              if (action == 'edit') onEdit();
              if (action == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewTaskSheet extends StatefulWidget {
  const _NewTaskSheet({
    required this.zones,
    required this.initialDate,
    this.task,
  });

  final List<String> zones;
  final DateTime initialDate;
  final GardenTask? task;

  @override
  State<_NewTaskSheet> createState() => _NewTaskSheetState();
}

class _NewTaskSheetState extends State<_NewTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _zone;
  late DateTime _dueDate;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _nameController.text = task?.title ?? '';
    _zone = task?.zone ?? widget.zones.first;
    _dueDate = task?.dueDate ?? widget.initialDate;
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
        id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _nameController.text.trim(),
        zone: _zone,
        plant: widget.task?.plant ?? '',
        dueDate: _dateOnly(_dueDate),
        priority: _priority,
        isCompleted: widget.task?.isCompleted ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
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
              const SizedBox(height: 18),
              Text(
                widget.task == null ? 'New Task' : 'Edit Task',
                style: TextStyle(fontFamily: 'Serif', fontSize: 22, color: _ink),
              ),
              const SizedBox(height: 16),
              const _FormLabel('Task Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('e.g. Prune Apple Trees'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a task name'
                    : null,
              ),
              const SizedBox(height: 14),
              const _FormLabel('Assign to Zone'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _zone,
                decoration: _inputDecoration(null),
                items: {...widget.zones, _zone}
                    .toList()
                    .map((zone) => DropdownMenuItem(
                          value: zone,
                          child: Text(zone),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _zone = value);
                },
              ),
              const SizedBox(height: 14),
              const _FormLabel('Due Date'),
              const SizedBox(height: 6),
              InkWell(
                onTap: _chooseDate,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: _inputDecoration(null),
                  child: Text(
                    _dateLabel(_dueDate),
                    style: const TextStyle(color: Color(0xFF59635B)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const _FormLabel('Priority'),
              const SizedBox(height: 7),
              Row(
                children: TaskPriority.values.map((priority) {
                  final selected = priority == _priority;
                  final label = _priorityName(priority);
                  final color = priority == TaskPriority.high
                      ? _orange
                      : _green;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: InkWell(
                        onTap: () => setState(() => _priority = priority),
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withValues(alpha: 0.09)
                                : const Color(0xFFF0F3F0),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: selected ? color : Colors.transparent,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: selected ? color : Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
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
                      child: Text(widget.task == null ? 'Create' : 'Save'),
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
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
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

String _weekday(DateTime date) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[date.weekday - 1];
}

String _monthDay(DateTime date) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${names[date.month - 1]} ${date.day}';
}

String _dateLabel(DateTime date) => '${_monthDay(date)}, ${date.year}';

String _monthYear(DateTime date) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${names[date.month - 1]} ${date.year}';
}

String _priorityName(TaskPriority priority) => switch (priority) {
      TaskPriority.low => 'Low',
      TaskPriority.medium => 'Medium',
      TaskPriority.high => 'High',
    };
