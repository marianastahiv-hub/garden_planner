// Рівень важливості завдання.
enum TaskPriority { low, medium, high }

// Дані завдання: текст, зона, дата та стан виконання.
class GardenTask {
  GardenTask({
    required this.id,
    required this.title,
    required this.zone,
    required this.plant,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });

  final String id;
  String title;
  String zone;
  String plant;
  DateTime dueDate;
  TaskPriority priority;
  bool isCompleted;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'zone': zone,
    'plant': plant,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.name,
    'isCompleted': isCompleted,
  };

  factory GardenTask.fromJson(Map<String, dynamic> json) => GardenTask(
    id: json['id'] as String,
    title: json['title'] as String,
    zone: json['zone'] as String,
    plant: json['plant'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    priority: TaskPriority.values.firstWhere(
      (value) => value.name == json['priority'],
      orElse: () => TaskPriority.medium,
    ),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}
