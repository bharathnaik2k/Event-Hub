// event_service.dart
import 'package:eventhub/src/models/events_model.dart' show EventModel;

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  List<EventModel> events = [];
}
