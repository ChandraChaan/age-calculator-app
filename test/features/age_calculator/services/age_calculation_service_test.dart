import 'package:agely/features/age_calculator/services/age_calculation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = AgeCalculationService();

  group('AgeCalculationService', () {
    test('calculates age across month boundaries', () {
      final result = service.calculate(
        startDate: DateTime(2024, 1, 31),
        endDate: DateTime(2024, 3, 1),
        today: DateTime(2024, 3, 1),
      );

      expect(result.years, 0);
      expect(result.months, 1);
      expect(result.days, 1);
      expect(result.weeks, 4);
      expect(result.totalDays, 30);
      expect(result.totalMonths, 1);
      expect(result.hours, 720);
      expect(result.minutes, 43200);
      expect(result.daysUntilBirthday, 336);
      expect(result.nextBirthday, DateTime.utc(2025, 1, 31));
    });

    test('handles leap-day birthdays on non-leap years', () {
      final result = service.calculate(
        startDate: DateTime(2024, 2, 29),
        endDate: DateTime(2025, 2, 28),
        today: DateTime(2025, 2, 28),
      );

      expect(result.years, 1);
      expect(result.months, 0);
      expect(result.days, 0);
      expect(result.totalDays, 365);
      expect(result.nextBirthday, DateTime.utc(2025, 2, 28));
      expect(result.daysUntilBirthday, 0);
    });

    test('hides birthday details when end date is not today', () {
      final result = service.calculate(
        startDate: DateTime(1997, 11, 15),
        endDate: DateTime(2024, 5, 4),
        today: DateTime(2024, 6, 1),
      );

      expect(result.showsBirthdaySection, isFalse);
      expect(result.nextBirthday, isNull);
      expect(result.daysUntilBirthday, isNull);
    });

    test('throws when start date is after end date', () {
      expect(
        () => service.calculate(
          startDate: DateTime(2024, 5, 10),
          endDate: DateTime(2024, 5, 9),
          today: DateTime(2024, 5, 10),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'Start date cannot be after end date.',
          ),
        ),
      );
    });

    test('throws when the end date is in the future', () {
      expect(
        () => service.calculate(
          startDate: DateTime(2024, 5, 1),
          endDate: DateTime(2024, 5, 2),
          today: DateTime(2024, 5, 1),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            'End date cannot be in the future.',
          ),
        ),
      );
    });
  });
}
