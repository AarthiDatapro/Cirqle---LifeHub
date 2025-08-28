class Event {
  final String? id; // Optional so backend can generate
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;

  Event({
    this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? json['id'],
      title: json['title'] ?? '',
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'description': description ?? '',
    };

    if (id != null) {
      data['id'] = id!; // force unwrap since we already checked null
    }

    return data;
  }
}
