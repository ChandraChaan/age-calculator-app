import 'package:agely/features/age_calculator/services/age_calculation_result.dart';
import 'package:agely/features/age_calculator/services/age_calculation_service.dart';
import 'package:flutter/foundation.dart';

typedef DateFactory = DateTime Function();

class AgeCalculatorController extends ChangeNotifier {
  static const String missingStartDateMessage =
      'Select a start date to continue.';

  AgeCalculatorController({
    AgeCalculationService? calculationService,
    DateFactory? now,
  }) : _calculationService =
           calculationService ?? const AgeCalculationService(),
       _now = now ?? DateTime.now,
       _endDate = _normalizeDate(now?.call() ?? DateTime.now());

  final AgeCalculationService _calculationService;
  final DateFactory _now;

  DateTime? _startDate;
  DateTime _endDate;
  AgeCalculationResult? _result;
  String? _errorMessage;

  DateTime? get startDate => _startDate;
  DateTime get endDate => _endDate;
  AgeCalculationResult? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get hasMissingStartDateError => errorMessage == missingStartDateMessage;

  void updateStartDate(DateTime date) {
    _startDate = _normalizeDate(date);
    _clearFeedback();
  }

  void updateEndDate(DateTime date) {
    _endDate = _normalizeDate(date);
    _clearFeedback();
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

  void _clearFeedback() {
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
