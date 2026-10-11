enum TaskPriority { low, medium, high }

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
}
