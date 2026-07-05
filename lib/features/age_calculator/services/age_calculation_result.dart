class AgeCalculationResult {
  const AgeCalculationResult({
    required this.years,
    required this.months,
    required this.days,
    required this.weeks,
    required this.totalDays,
    required this.totalMonths,
    required this.hours,
    required this.minutes,
    this.nextBirthday,
    this.daysUntilBirthday,
  });

  final int years;
  final int months;
  final int days;
  final int weeks;
  final int totalDays;
  final int totalMonths;
  final int hours;
  final int minutes;
  final DateTime? nextBirthday;
  final int? daysUntilBirthday;

  bool get showsBirthdaySection =>
      nextBirthday != null && daysUntilBirthday != null;
}
