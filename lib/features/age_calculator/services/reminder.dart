import 'dart:math';

enum ReminderRepeat {
  none('Does not repeat'),
  monthly('Every month'),
  yearly('Every year');

  const ReminderRepeat(this.label);

  final String label;
}

enum ReminderStyle {
  onDay('On the day'),
  oneDayBefore('1 day before'),
  oneWeekBefore('1 week before');

  const ReminderStyle(this.label);

  final String label;
}

class Reminder {
  const Reminder({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.category,
    required this.targetDate,
    required this.repeat,
    required this.style,
    required this.createdAt,
  });

  final String id;
  final int notificationId;
  final String title;
  final String category;
  final DateTime targetDate;
  final ReminderRepeat repeat;
  final ReminderStyle style;
  final DateTime createdAt;

  Reminder copyWith({
    String? title,
    String? category,
    DateTime? targetDate,
    ReminderRepeat? repeat,
    ReminderStyle? style,
  }) {
    return Reminder(
      id: id,
      notificationId: notificationId,
      title: title ?? this.title,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      repeat: repeat ?? this.repeat,
      style: style ?? this.style,
      createdAt: createdAt,
    );
  }

  DateTime? nextTriggerDate(DateTime referenceDate) {
    final normalizedReference = _normalize(referenceDate);

    if (repeat == ReminderRepeat.none) {
      final trigger = _applyReminderStyle(_normalize(targetDate));
      return trigger.isBefore(normalizedReference) ? null : trigger;
    }

    var eventDate = _normalize(targetDate);

    for (var index = 0; index < 240; index += 1) {
      final triggerDate = _applyReminderStyle(eventDate);
      if (!triggerDate.isBefore(normalizedReference)) {
        return triggerDate;
      }
      eventDate = _advanceEventDate(eventDate);
    }

    return null;
  }

  DateTime nextEventDate(DateTime referenceDate) {
    final normalizedReference = _normalize(referenceDate);
    var eventDate = _normalize(targetDate);

    if (repeat == ReminderRepeat.none ||
        !eventDate.isBefore(normalizedReference)) {
      return eventDate;
    }

    for (var index = 0; index < 240; index += 1) {
      final triggerDate = _applyReminderStyle(eventDate);
      if (!triggerDate.isBefore(normalizedReference)) {
        return eventDate;
      }
      eventDate = _advanceEventDate(eventDate);
    }

    return eventDate;
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      'id': id,
      'notificationId': notificationId,
      'title': title,
      'category': category,
      'targetDate': targetDate.toIso8601String(),
      'repeat': repeat.name,
      'style': style.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      notificationId: json['notificationId'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      repeat: ReminderRepeat.values.byName(json['repeat'] as String),
      style: ReminderStyle.values.byName(json['style'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  DateTime _advanceEventDate(DateTime eventDate) {
    return switch (repeat) {
      ReminderRepeat.none => eventDate,
      ReminderRepeat.monthly => _addMonths(eventDate, 1),
      ReminderRepeat.yearly => _addYears(eventDate, 1),
    };
  }

  DateTime _applyReminderStyle(DateTime eventDate) {
    return switch (style) {
      ReminderStyle.onDay => eventDate,
      ReminderStyle.oneDayBefore => eventDate.subtract(const Duration(days: 1)),
      ReminderStyle.oneWeekBefore => eventDate.subtract(
        const Duration(days: 7),
      ),
    };
  }

  DateTime _addYears(DateTime date, int yearsToAdd) {
    return _addMonths(date, yearsToAdd * 12);
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final totalMonths = ((date.year * 12) + date.month - 1) + monthsToAdd;
    final year = totalMonths ~/ 12;
    final month = (totalMonths % 12) + 1;
    final day = min(date.day, _daysInMonth(year, month));

    return DateTime(year, month, day);
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
