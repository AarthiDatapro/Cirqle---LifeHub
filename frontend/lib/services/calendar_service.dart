import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event.dart';

class CalendarService {
  // Use a more flexible base URL that works for both web and mobile
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );

  Future<List<Event>> getMonthEvents(String month) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/calendar?month=$month'));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final List list = body is List ? body : (body['events'] ?? []);
        return list.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addEvent(Event event) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/calendar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event.toJson()),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
