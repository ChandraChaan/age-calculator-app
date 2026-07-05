import 'package:agely/features/age_calculator/services/age_calculation_result.dart';
import 'package:agely/features/age_calculator/services/age_calculation_service.dart';
import 'package:agely/features/age_calculator/services/notification_service.dart';
import 'package:agely/features/age_calculator/services/reminder.dart';
import 'package:agely/features/age_calculator/services/reminder_storage_service.dart';
import 'package:flutter/material.dart';

typedef DateFactory = DateTime Function();

class AgeCalculatorController extends ChangeNotifier {
  static const String missingStartDateMessage =
      'Select a start date to continue.';
  static const String reminderLoadErrorMessage =
      'Could not load reminders right now.';
  static const String notificationPermissionMessage =
      'Reminders are saved, but notifications are currently disabled.';

  AgeCalculatorController({
    AgeCalculationService? calculationService,
    ReminderStorageService? reminderStorageService,
    NotificationService? notificationService,
    DateFactory? now,
  }) : _calculationService =
           calculationService ?? const AgeCalculationService(),
       _reminderStorageService =
           reminderStorageService ?? const ReminderStorageService(),
       _notificationService = notificationService ?? NotificationService(),
       _now = now ?? DateTime.now,
       _endDate = _normalizeDate(now?.call() ?? DateTime.now());

  final AgeCalculationService _calculationService;
  final ReminderStorageService _reminderStorageService;
  final NotificationService _notificationService;
  final DateFactory _now;

  DateTime? _startDate;
  DateTime _endDate;
  AgeCalculationResult? _result;
  String? _errorMessage;
  String? _reminderErrorMessage;
  bool _isLoadingReminders = true;
  bool _isSavingReminder = false;
  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  List<Reminder> _reminders = <Reminder>[];

  DateTime? get startDate => _startDate;
  DateTime get endDate => _endDate;
  AgeCalculationResult? get result => _result;
  String? get errorMessage => _errorMessage;
  String? get reminderErrorMessage => _reminderErrorMessage;
  bool get hasMissingStartDateError => errorMessage == missingStartDateMessage;
  bool get isLoadingReminders => _isLoadingReminders;
  bool get isSavingReminder => _isSavingReminder;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get canSaveReminder => result != null;
  ThemeMode get themeMode => _themeMode;
  List<Reminder> get reminders => List<Reminder>.unmodifiable(_reminders);

  List<Reminder> get upcomingReminders {
    final today = _normalizeDate(_now());
    final visibleReminders = _reminders.where(
      (reminder) => reminder.nextTriggerDate(today) != null,
    );

    final sortedReminders = visibleReminders.toList()
      ..sort((left, right) {
        final leftTrigger = left.nextTriggerDate(today)!;
        final rightTrigger = right.nextTriggerDate(today)!;
        return leftTrigger.compareTo(rightTrigger);
      });

    return List<Reminder>.unmodifiable(sortedReminders);
  }

  DateTime? get suggestedReminderDate {
    if (_result == null) {
      return null;
    }

    if (_result!.showsBirthdaySection) {
      return _result!.nextBirthday;
    }

    return _endDate;
  }

  Future<void> initialize() async {
    try {
      _themeMode = await _reminderStorageService.loadThemeMode();
      _reminders = await _reminderStorageService.loadReminders();
      _reminderErrorMessage = null;
    } catch (_) {
      _reminders = <Reminder>[];
      _reminderErrorMessage = reminderLoadErrorMessage;
    }

    try {
      await _syncReminderNotifications();
    } on NotificationPermissionDeniedException {
      _notificationsEnabled = false;
    } finally {
      _isLoadingReminders = false;
      notifyListeners();
    }
  }

  void updateStartDate(DateTime date) {
    _startDate = _normalizeDate(date);
    _clearCalculationFeedback();
  }

  void updateEndDate(DateTime date) {
    _endDate = _normalizeDate(date);
    _clearCalculationFeedback();
  }

  void calculate() {
    if (_startDate == null) {
      _result = null;
      _errorMessage = missingStartDateMessage;
      notifyListeners();
      return;
    }

    try {
      _result = _calculationService.calculate(
        startDate: _startDate!,
        endDate: _endDate,
        today: _normalizeDate(_now()),
      );
      _errorMessage = null;
    } on ArgumentError catch (error) {
      _result = null;
      _errorMessage = error.message.toString();
    }

    notifyListeners();
  }

  Future<void> createReminder({
    required String title,
    required String category,
    required ReminderRepeat repeat,
    required ReminderStyle style,
    required DateTime targetDate,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedCategory = category.trim();

    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Enter a reminder title.');
    }

    if (trimmedCategory.isEmpty) {
      throw ArgumentError('Enter a reminder category.');
    }

    _isSavingReminder = true;
    notifyListeners();

    final timestamp = DateTime.now();
    final reminder = Reminder(
      id: timestamp.microsecondsSinceEpoch.toString(),
      notificationId: timestamp.millisecondsSinceEpoch.remainder(1 << 31),
      title: trimmedTitle,
      category: trimmedCategory,
      targetDate: _normalizeDate(targetDate),
      repeat: repeat,
      style: style,
      createdAt: _normalizeDate(_now()),
    );

    final previousReminders = List<Reminder>.from(_reminders);

    try {
      _reminders = <Reminder>[..._reminders, reminder];
      await _persistReminders();
      await _syncReminderNotifications();
      _reminderErrorMessage = null;
    } on NotificationPermissionDeniedException {
      _reminderErrorMessage = notificationPermissionMessage;
    } catch (_) {
      _reminders = previousReminders;
      _reminderErrorMessage = 'Could not save this reminder.';
      rethrow;
    } finally {
      _isSavingReminder = false;
      notifyListeners();
    }
  }

  Future<void> updateReminder({
    required Reminder reminder,
    required String title,
    required String category,
    required ReminderRepeat repeat,
    required ReminderStyle style,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedCategory = category.trim();

    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Enter a reminder title.');
    }

    if (trimmedCategory.isEmpty) {
      throw ArgumentError('Enter a reminder category.');
    }

    _isSavingReminder = true;
    notifyListeners();

    final updatedReminder = reminder.copyWith(
      title: trimmedTitle,
      category: trimmedCategory,
      repeat: repeat,
      style: style,
    );

    final originalReminders = List<Reminder>.from(_reminders);
    _reminders = _reminders
        .map((item) => item.id == reminder.id ? updatedReminder : item)
        .toList();

    try {
      await _persistReminders();
      await _syncReminderNotifications();
      _reminderErrorMessage = null;
    } on NotificationPermissionDeniedException {
      _reminderErrorMessage = notificationPermissionMessage;
    } catch (_) {
      _reminders = originalReminders;
      _reminderErrorMessage = 'Could not update this reminder.';
      rethrow;
    } finally {
      _isSavingReminder = false;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    final originalReminders = List<Reminder>.from(_reminders);
    _reminders = _reminders.where((item) => item.id != reminder.id).toList();
    notifyListeners();

    try {
      await _persistReminders();
      await _syncReminderNotifications();
      _reminderErrorMessage = null;
    } on NotificationPermissionDeniedException {
      _reminderErrorMessage = notificationPermissionMessage;
    } catch (_) {
      _reminders = originalReminders;
      _reminderErrorMessage = 'Could not delete this reminder.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> enableNotifications() async {
    try {
      await _syncReminderNotifications();
      _reminderErrorMessage = null;
      notifyListeners();
    } on NotificationPermissionDeniedException {
      _notificationsEnabled = false;
      _reminderErrorMessage = notificationPermissionMessage;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await _reminderStorageService.saveThemeMode(_themeMode);
    notifyListeners();
  }

  Future<void> _persistReminders() {
    return _reminderStorageService.saveReminders(_reminders);
  }

  Future<void> _syncReminderNotifications() async {
    try {
      await _notificationService.syncReminders(_reminders);
      _notificationsEnabled = true;
      if (_reminderErrorMessage == notificationPermissionMessage) {
        _reminderErrorMessage = null;
      }
    } on NotificationPermissionDeniedException {
      _notificationsEnabled = false;
      _reminderErrorMessage = notificationPermissionMessage;
      rethrow;
    }
  }

  void _clearCalculationFeedback() {
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
