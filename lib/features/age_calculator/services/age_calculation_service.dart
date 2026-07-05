import 'dart:math';

import 'package:agely/features/age_calculator/services/age_calculation_result.dart';

class AgeCalculationService {
  const AgeCalculationService();

  AgeCalculationResult calculate({
    required DateTime startDate,
    required DateTime endDate,
    required DateTime today,
  }) {
    final normalizedStart = _normalize(startDate);
    final normalizedEnd = _normalize(endDate);
    final normalizedToday = _normalize(today);

    if (normalizedStart.isAfter(normalizedToday)) {
      throw ArgumentError('Start date cannot be in the future.');
    }

    if (normalizedEnd.isAfter(normalizedToday)) {
      throw ArgumentError('End date cannot be in the future.');
    }

    if (normalizedStart.isAfter(normalizedEnd)) {
      throw ArgumentError('Start date cannot be after end date.');
    }

    final fullYears = _fullYearsBetween(normalizedStart, normalizedEnd);
    final afterYears = _addYears(normalizedStart, fullYears);
    final fullMonths = _fullMonthsBetween(afterYears, normalizedEnd);
    final afterMonths = _addMonths(afterYears, fullMonths);
    final remainingDays = normalizedEnd.difference(afterMonths).inDays;
    final totalDays = normalizedEnd.difference(normalizedStart).inDays;
    final totalMonths = (fullYears * 12) + fullMonths;
    final hours = totalDays * 24;
    final minutes = hours * 60;

    DateTime? nextBirthday;
    int? daysUntilBirthday;

    if (_isSameDate(normalizedEnd, normalizedToday)) {
      nextBirthday = _nextBirthdayFor(normalizedStart, normalizedToday);
      daysUntilBirthday = nextBirthday.difference(normalizedToday).inDays;
    }

    return AgeCalculationResult(
      years: fullYears,
      months: fullMonths,
      days: remainingDays,
      weeks: totalDays ~/ 7,
      totalDays: totalDays,
      totalMonths: totalMonths,
      hours: hours,
      minutes: minutes,
      nextBirthday: nextBirthday,
      daysUntilBirthday: daysUntilBirthday,
    );
  }

  int _fullYearsBetween(DateTime startDate, DateTime endDate) {
    var years = endDate.year - startDate.year;

    while (_addYears(startDate, years).isAfter(endDate)) {
      years -= 1;
    }

    return years;
  }

  int _fullMonthsBetween(DateTime startDate, DateTime endDate) {
    var months = 0;

    while (!_addMonths(startDate, months + 1).isAfter(endDate)) {
      months += 1;
    }

    return months;
  }

  DateTime _nextBirthdayFor(DateTime birthDate, DateTime today) {
    var candidate = _birthdayInYear(birthDate, today.year);

    if (candidate.isBefore(today)) {
      candidate = _birthdayInYear(birthDate, today.year + 1);
    }

    return candidate;
  }

  DateTime _birthdayInYear(DateTime birthDate, int year) {
    final day = min(birthDate.day, _daysInMonth(year, birthDate.month));
    return DateTime.utc(year, birthDate.month, day);
  }

  DateTime _addYears(DateTime date, int yearsToAdd) {
    return _addMonths(date, yearsToAdd * 12);
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final totalMonths = ((date.year * 12) + date.month - 1) + monthsToAdd;
    final year = totalMonths ~/ 12;
    final month = (totalMonths % 12) + 1;
    final day = min(date.day, _daysInMonth(year, month));

    return DateTime.utc(year, month, day);
  }

  int _daysInMonth(int year, int month) {
    return DateTime.utc(year, month + 1, 0).day;
  }

  DateTime _normalize(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
