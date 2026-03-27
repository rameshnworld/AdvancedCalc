import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:math_expressions/math_expressions.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calc_button.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: cs.onPrimary,
            unselectedLabelColor: cs.onSurfaceVariant,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Basic'),
              Tab(text: 'Scientific'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: const [
              _BasicCalc(),
              _ScientificCalc(),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────── SHARED LOGIC ────────────
mixin _CalcLogic<T extends StatefulWidget> on State<T> {
  String displayExpr = '';
  String evalExpr = '';
  String result = '0';
  bool newEntry = false;
  bool isDegrees = true;

  void appendChar(String display, [String? eval]) {
    setState(() {
      if (newEntry) {
        displayExpr = display;
        evalExpr = eval ?? display;
        newEntry = false;
      } else {
        displayExpr += display;
        evalExpr += eval ?? display;
      }
    });
  }

  void clearAll() => setState(() { displayExpr = ''; evalExpr = ''; result = '0'; newEntry = false; });
  void backspace() => setState(() {
    if (displayExpr.isNotEmpty) displayExpr = displayExpr.substring(0, displayExpr.length - 1);
    if (evalExpr.isNotEmpty) evalExpr = evalExpr.substring(0, evalExpr.length - 1);
    if (displayExpr.isEmpty) result = '0';
  });

  void calculate(BuildContext ctx) {
    if (displayExpr.isEmpty) return;
    final res = _evaluate(evalExpr);
    setState(() { result = res; newEntry = true; });
    if (res != 'Error') {
      Provider.of<CalculatorProvider>(ctx, listen: false).add(displayExpr, res);
    }
  }

  String _evaluate(String expr) {
    try {
      String e = expr
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', '3.14159265358979')
          .replaceAll('√(', 'sqrt(');

      if (isDegrees) {
        e = _convertDeg(e);
      }

      final parsed = Parser().parse(e);
      final cm = ContextModel();
      final r = parsed.evaluate(EvaluationType.REAL, cm) as double;

      if (r.isNaN || r.isInfinite) return 'Error';
      if (r == r.truncateToDouble() && r.abs() < 1e12) return r.toInt().toString();
      return double.parse(r.toStringAsFixed(10)).toString();
    } catch (_) {
      return 'Error';
    }
  }

  String _convertDeg(String expr) {
    // Replace sin/cos/tan argument with degree-to-radian conversion
    final functions = ['sin', 'cos', 'tan'];
    for (final fn in functions) {
      final pattern = RegExp('$fn\\(');
      final buf = StringBuffer();
      int i = 0;
      while (i < expr.length) {
        final m = pattern.firstMatch(expr.substring(i));
        if (m == null) { buf.write(expr.substring(i)); break; }
        buf.write(expr.substring(i, i + m.start));
        buf.write('$fn(');
        int depth = 1;
        int j = i + m.end;
        final argStart = j;
        while (j < expr.length && depth > 0) {
          if (expr[j] == '(') depth++;
          else if (expr[j] == ')') depth--;
          j++;
        }
        final arg = expr.substring(argStart, j - 1);
        buf.write('($arg)*3.14159265358979/180');
        buf.write(')');
        i = j;
      }
      expr = buf.toString();
    }
    return expr;
  }
}

// ──────────── BASIC CALCULATOR ────────────
class _BasicCalc extends StatefulWidget {
  const _BasicCalc();

  @override
  State<_BasicCalc> createState() => _BasicCalcState();
}

class _BasicCalcState extends State<_BasicCalc> with _CalcLogic {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      _DisplayPanel(expr: displayExpr, result: result),
      const SizedBox(height: 8),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            _row([
              _btn('C', cs.errorContainer, cs.onErrorContainer, () => clearAll()),
              _btn('±', cs.secondaryContainer, cs.onSecondaryContainer, () {
                if (result != '0' && newEntry) {
                  final v = double.tryParse(result);
                  if (v != null) setState(() => result = (-v).toString());
                } else {
                  appendChar('-(', '-('  );
                }
              }),
              _btn('%', cs.secondaryContainer, cs.onSecondaryContainer, () => appendChar('%')),
              _btn('÷', cs.primary, cs.onPrimary, () => appendChar('÷', '/')),
            ]),
            _row([
              _btn('7', null, null, () => appendChar('7')),
              _btn('8', null, null, () => appendChar('8')),
              _btn('9', null, null, () => appendChar('9')),
              _btn('×', cs.primary, cs.onPrimary, () => appendChar('×', '*')),
            ]),
            _row([
              _btn('4', null, null, () => appendChar('4')),
              _btn('5', null, null, () => appendChar('5')),
              _btn('6', null, null, () => appendChar('6')),
              _btn('-', cs.primary, cs.onPrimary, () => appendChar('-')),
            ]),
            _row([
              _btn('1', null, null, () => appendChar('1')),
              _btn('2', null, null, () => appendChar('2')),
              _btn('3', null, null, () => appendChar('3')),
              _btn('+', cs.primary, cs.onPrimary, () => appendChar('+')),
            ]),
            _row([
              _btn('0', null, null, () => appendChar('0')),
              _btn('.', null, null, () => appendChar('.')),
              CalcButton(
                label: '⌫',
                backgroundColor: cs.secondaryContainer,
                textColor: cs.onSecondaryContainer,
                onPressed: backspace,
              ),
              _btn('=', cs.primary, cs.onPrimary, () => calculate(context)),
            ]),
          ]),
        ),
      ),
    ]);
  }

  Widget _row(List<Widget> children) => Expanded(
    child: Row(children: children.map((w) => Expanded(child: Padding(padding: const EdgeInsets.all(4), child: w))).toList()),
  );

  CalcButton _btn(String label, Color? bg, Color? fg, VoidCallback fn) =>
      CalcButton(label: label, backgroundColor: bg, textColor: fg, onPressed: fn);
}

// ──────────── SCIENTIFIC CALCULATOR ────────────
class _ScientificCalc extends StatefulWidget {
  const _ScientificCalc();

  @override
  State<_ScientificCalc> createState() => _ScientificCalcState();
}

class _ScientificCalcState extends State<_ScientificCalc> with _CalcLogic {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget sciBtn(String label, VoidCallback fn) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: CalcButton(
          label: label,
          backgroundColor: cs.tertiaryContainer,
          textColor: cs.onTertiaryContainer,
          fontSize: 14,
          onPressed: fn,
        ),
      ),
    );

    Widget numBtn(String label, Color? bg, Color? fg, VoidCallback fn) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: CalcButton(label: label, backgroundColor: bg, textColor: fg, fontSize: 18, onPressed: fn),
      ),
    );

    Row sciRow(List<Widget> children) => Row(children: children);
    Row numRow(List<Widget> children) => Row(children: children);

    return Column(children: [
      _DisplayPanel(expr: displayExpr, result: result),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: () => setState(() => isDegrees = !isDegrees),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDegrees ? cs.primary : cs.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(isDegrees ? 'DEG' : 'RAD',
                  style: TextStyle(color: isDegrees ? cs.onPrimary : cs.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ]),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Expanded(child: sciRow([
              sciBtn('sin', () => appendChar('sin(')),
              sciBtn('cos', () => appendChar('cos(')),
              sciBtn('tan', () => appendChar('tan(')),
              sciBtn('π', () => appendChar('π')),
              sciBtn('e', () => appendChar('e', '2.71828182845904')),
            ])),
            Expanded(child: sciRow([
              sciBtn('asin', () => appendChar('asin(', 'asin(')),
              sciBtn('acos', () => appendChar('acos(', 'acos(')),
              sciBtn('atan', () => appendChar('atan(', 'atan(')),
              sciBtn('log', () => appendChar('log(')),
              sciBtn('ln', () => appendChar('ln(', 'log(')),
            ])),
            Expanded(child: sciRow([
              sciBtn('√', () => appendChar('√(', 'sqrt(')),
              sciBtn('x²', () { appendChar('^'); appendChar('2'); }),
              sciBtn('xⁿ', () => appendChar('^')),
              sciBtn('(', () => appendChar('(')),
              sciBtn(')', () => appendChar(')')),
            ])),
            Expanded(child: numRow([
              numBtn('C', cs.errorContainer, cs.onErrorContainer, () => clearAll()),
              numBtn('⌫', cs.secondaryContainer, cs.onSecondaryContainer, backspace),
              numBtn('%', cs.secondaryContainer, cs.onSecondaryContainer, () => appendChar('%')),
              numBtn('÷', cs.primary, cs.onPrimary, () => appendChar('÷', '/')),
            ])),
            Expanded(child: numRow([
              numBtn('7', null, null, () => appendChar('7')),
              numBtn('8', null, null, () => appendChar('8')),
              numBtn('9', null, null, () => appendChar('9')),
              numBtn('×', cs.primary, cs.onPrimary, () => appendChar('×', '*')),
            ])),
            Expanded(child: numRow([
              numBtn('4', null, null, () => appendChar('4')),
              numBtn('5', null, null, () => appendChar('5')),
              numBtn('6', null, null, () => appendChar('6')),
              numBtn('-', cs.primary, cs.onPrimary, () => appendChar('-')),
            ])),
            Expanded(child: numRow([
              numBtn('1', null, null, () => appendChar('1')),
              numBtn('2', null, null, () => appendChar('2')),
              numBtn('3', null, null, () => appendChar('3')),
              numBtn('+', cs.primary, cs.onPrimary, () => appendChar('+')),
            ])),
            Expanded(child: numRow([
              numBtn('0', null, null, () => appendChar('0')),
              numBtn('.', null, null, () => appendChar('.')),
              numBtn('(', cs.secondaryContainer, cs.onSecondaryContainer, () => appendChar('(')),
              numBtn('=', cs.primary, cs.onPrimary, () => calculate(context)),
            ])),
          ]),
        ),
      ),
    ]);
  }
}

// ──────────── DISPLAY PANEL ────────────
class _DisplayPanel extends StatelessWidget {
  final String expr;
  final String result;

  const _DisplayPanel({required this.expr, required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            expr.isEmpty ? '0' : expr,
            key: ValueKey(expr),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 18,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            result,
            key: ValueKey(result),
            style: TextStyle(
              color: result == 'Error' ? cs.error : cs.onSurface,
              fontSize: 44,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ]),
    );
  }
}
