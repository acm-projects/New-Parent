class Todo {
  String title;
  String id;
  String description;
  DateTime createdTime;
  bool isDone;

  Todo({
    required this.title,
    this.description = '',
    this.id = '',
    required this.createdTime,
    this.isDone = false,
  });

  String get time => createdTime.toString();

  void toggleDone() => isDone = !isDone;
  
  List<dynamic> fields() => [title, description, id, time, isDone];
}