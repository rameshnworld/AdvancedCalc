import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _ctrl = TextEditingController();
  String _from = 'INR', _to = 'USD';
  String _result = '';

  // Rates relative to USD (approximate)
  static const Map<String, double> _ratesUSD = {
    'USD': 1.0,
    'INR': 83.5,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 149.5,
    'AUD': 1.53,
    'CAD': 1.35,
    'CHF': 0.90,
    'CNY': 7.24,
    'SGD': 1.34,
    'AED': 3.67,
    'SAR': 3.75,
    'MYR': 4.72,
    'THB': 35.7,
    'IDR': 15600.0,
  };

  static const Map<String, String> _symbols = {
    'USD': '\$', 'INR': '₹', 'EUR': '€', 'GBP': '£',
    'JPY': '¥', 'AUD': 'A\$', 'CAD': 'C\$', 'CHF': 'Fr',
    'CNY': '¥', 'SGD': 'S\$', 'AED': 'د.إ', 'SAR': '﷼',
    'MYR': 'RM', 'THB': '฿', 'IDR': 'Rp',
  };

  void _convert() {
    final val = double.tryParse(_ctrl.text);
    if (val == null) { setState(() => _result = 'Invalid'); return; }
    final inUSD = val / _ratesUSD[_from]!;
    final converted = inUSD * _ratesUSD[_to]!;
    setState(() {
      _result = '${_symbols[_to] ?? ''} ${_fmt(converted)}';
    });
  }

  String _fmt(double v) {
    if (v >= 1) return v.toStringAsFixed(2);
    return double.parse(v.toStringAsFixed(6)).toString();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currencies = _ratesUSD.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Card(
          color: cs.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Text('Note: Rates are approximate. Update manually for accuracy.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${_symbols[_from] ?? ''} ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                onChanged: (_) => _convert(),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _dropdown('From', currencies, _from, (v) => setState(() { _from = v!; _convert(); }))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filled(
                    onPressed: () => setState(() { final t = _from; _from = _to; _to = t; _convert(); }),
                    icon: const Icon(Icons.swap_horiz_rounded),
                  ),
                ),
                Expanded(child: _dropdown('To', currencies, _to, (v) => setState(() { _to = v!; _convert(); }))),
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
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_from, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_rounded)),
                Text(_to, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              Text(_result,
                  style: TextStyle(color: cs.onPrimaryContainer, fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('1 $_from = ${_fmt(_ratesUSD[_to]! / _ratesUSD[_from]!)} $_to',
                  style: TextStyle(color: cs.onPrimaryContainer.withOpacity(0.7), fontSize: 13)),
            ]),
          ),
        const SizedBox(height: 16),
        _buildRatesGrid(cs),
      ]),
    );
  }

  Widget _buildRatesGrid(ColorScheme cs) {
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Exchange Rates (vs USD)',
              style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
          const SizedBox(height: 8),
          ...(_ratesUSD.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Text('${_symbols[e.key] ?? ''} ${e.key}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(e.value.toStringAsFixed(e.value >= 10 ? 2 : 4),
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ]),
          ))),
        ]),
      ),
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
      items: items.map((e) => DropdownMenuItem(value: e, child: Text('${_symbols[e] ?? ''} $e'))).toList(),
      onChanged: fn,
      isExpanded: true,
    );
  }
}
