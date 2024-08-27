import 'dart:async';

class NotificationEvent {
  final String message;
  NotificationEvent(this.message);
}

class NotificationManager {
  static final _notificationStreamController =
      StreamController<NotificationEvent>.broadcast();
  static Stream<NotificationEvent> get notificationStream =>
      _notificationStreamController.stream;

  static void notify(final String message) {
    _notificationStreamController.add(NotificationEvent(message));
  }
}
