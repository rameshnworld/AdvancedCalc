import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _ctrl = TextEditingController();
  String _result = '';

  // Length
  String _fromLen = 'Meter', _toLen = 'Kilometer';
  // Weight
  String _fromWt = 'Kilogram', _toWt = 'Gram';
  // Temp
  String _fromTp = 'Celsius', _toTp = 'Fahrenheit';

  static const lengthUnits = {
    'Meter': 1.0,
    'Kilometer': 0.001,
    'Centimeter': 100.0,
    'Millimeter': 1000.0,
    'Mile': 0.000621371,
    'Yard': 1.09361,
    'Foot': 3.28084,
    'Inch': 39.3701,
  };

  static const weightUnits = {
    'Kilogram': 1.0,
    'Gram': 1000.0,
    'Milligram': 1000000.0,
    'Pound': 2.20462,
    'Ounce': 35.274,
    'Ton': 0.001,
    'Quintal': 0.01,
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() { _result = ''; _ctrl.clear(); }));
  }

  @override
  void dispose() {
    _tab.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _convert() {
    final val = double.tryParse(_ctrl.text);
    if (val == null) { setState(() => _result = 'Invalid input'); return; }

    double r;
    String unit;
    switch (_tab.index) {
      case 0:
        r = val / lengthUnits[_fromLen]! * lengthUnits[_toLen]!;
        unit = _toLen;
        break;
      case 1:
        r = val / weightUnits[_fromWt]! * weightUnits[_toWt]!;
        unit = _toWt;
        break;
      default:
        r = _convertTemp(val, _fromTp, _toTp);
        unit = _toTp;
    }

    setState(() {
      _result = '${_fmt(r)} $unit';
    });
  }

  double _convertTemp(double val, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'Fahrenheit': celsius = (val - 32) * 5 / 9; break;
      case 'Kelvin': celsius = val - 273.15; break;
      default: celsius = val;
    }
    // Convert from Celsius
    switch (to) {
      case 'Fahrenheit': return celsius * 9 / 5 + 32;
      case 'Kelvin': return celsius + 273.15;
      default: return celsius;
    }
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return double.parse(v.toStringAsFixed(6)).toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tab,
          indicator: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: cs.onPrimary,
          unselectedLabelColor: cs.onSurfaceVariant,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: 'Length'), Tab(text: 'Weight'), Tab(text: 'Temperature')],
        ),
      ),
      Expanded(
        child: TabBarView(controller: _tab, children: [
          _buildConverter(lengthUnits.keys.toList(), _fromLen, _toLen,
              (v) => setState(() => _fromLen = v!),
              (v) => setState(() => _toLen = v!)),
          _buildConverter(weightUnits.keys.toList(), _fromWt, _toWt,
              (v) => setState(() => _fromWt = v!),
              (v) => setState(() => _toWt = v!)),
          _buildConverter(['Celsius', 'Fahrenheit', 'Kelvin'], _fromTp, _toTp,
              (v) => setState(() => _fromTp = v!),
              (v) => setState(() => _toTp = v!)),
        ]),
      ),
    ]);
  }

  Widget _buildConverter(List<String> units, String from, String to,
      ValueChanged<String?> onFrom, ValueChanged<String?> onTo) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Card(
          color: cs.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              TextField(
                controller: _ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Enter value',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                onChanged: (_) => _convert(),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _dropdown('From', units, from, onFrom)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filled(
                    onPressed: () {
                      final tmp = from;
                      onFrom(to);
                      onTo(tmp);
                      _convert();
                    },
                    icon: const Icon(Icons.swap_horiz_rounded),
                  ),
                ),
                Expanded(child: _dropdown('To', units, to, onTo)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        if (_result.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Text('Result', style: TextStyle(color: cs.onPrimaryContainer, fontSize: 14)),
              const SizedBox(height: 8),
              Text(_result,
                  style: TextStyle(color: cs.onPrimaryContainer, fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ]),
          ),
      ]),
    );
  }

  Widget _dropdown(String label, List<String> items, String val, ValueChanged<String?> fn) {
    return DropdownButtonFormField<String>(
      value: val,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: (v) { fn(v); _convert(); },
      isExpanded: true,
    );
  }
}
