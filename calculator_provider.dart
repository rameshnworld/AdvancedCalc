import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalcHistory {
  final String expression;
  final String result;
  final DateTime dateTime;
  final String type;

  CalcHistory({
    required this.expression,
    required this.result,
    required this.dateTime,
    this.type = 'Basic',
  });

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'result': result,
    'dateTime': dateTime.toIso8601String(),
    'type': type,
  };

  factory CalcHistory.fromJson(Map<String, dynamic> j) => CalcHistory(
    expression: j['expression'],
    result: j['result'],
    dateTime: DateTime.parse(j['dateTime']),
    type: j['type'] ?? 'Basic',
  );
}

class CalculatorProvider extends ChangeNotifier {
  List<CalcHistory> _history = [];
  List<CalcHistory> get history => List.unmodifiable(_history);

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString('calc_history');
    if (d != null) {
      final list = jsonDecode(d) as List;
      _history = list.map((e) => CalcHistory.fromJson(e)).toList();
    }
  }

  Future<void> add(String expr, String result, {String type = 'Basic'}) async {
    _history.insert(0, CalcHistory(
      expression: expr,
      result: result,
      dateTime: DateTime.now(),
      type: type,
    ));
    if (_history.length > 100) _history = _history.sublist(0, 100);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _history.clear();
    final p = await SharedPreferences.getInstance();
    await p.remove('calc_history');
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('calc_history', jsonEncode(_history.map((e) => e.toJson()).toList()));
  }
}
