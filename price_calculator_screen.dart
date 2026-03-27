import 'package:flutter/material.dart';

class PriceCalculatorScreen extends StatefulWidget {
  const PriceCalculatorScreen({super.key});

  @override
  State<PriceCalculatorScreen> createState() => _PriceCalculatorScreenState();
}

class _PriceCalculatorScreenState extends State<PriceCalculatorScreen> {
  final _totalWtCtrl = TextEditingController();
  final _totalPriceCtrl = TextEditingController();
  final _customWtCtrl = TextEditingController();
  String _wtUnit = 'kg';
  List<_PriceResult> _results = [];
  double? _pricePerGram;

  final _wtUnits = ['kg', 'g', 'lb', 'oz'];

  double _toGrams(double val, String unit) {
    switch (unit) {
      case 'kg': return val * 1000;
      case 'g': return val;
      case 'lb': return val * 453.592;
      case 'oz': return val * 28.3495;
      default: return val;
    }
  }

  void _calculate() {
    final totalWt = double.tryParse(_totalWtCtrl.text);
    final totalPrice = double.tryParse(_totalPriceCtrl.text);
    if (totalWt == null || totalPrice == null || totalWt <= 0 || totalPrice <= 0) {
      setState(() { _results = []; _pricePerGram = null; });
      return;
    }

    final totalGrams = _toGrams(totalWt, _wtUnit);
    _pricePerGram = totalPrice / totalGrams;

    final List<_PriceResult> results = [
      _PriceResult('Per 1 gram', 1, _pricePerGram!),
      _PriceResult('Per 100 grams', 100, _pricePerGram! * 100),
      _PriceResult('Per 250 grams', 250, _pricePerGram! * 250),
      _PriceResult('Per 500 grams', 500, _pricePerGram! * 500),
      _PriceResult('Per 1 kg', 1000, _pricePerGram! * 1000),
      _PriceResult('Per 5 kg', 5000, _pricePerGram! * 5000),
      _PriceResult('Per 10 kg', 10000, _pricePerGram! * 10000),
    ];

    final customWt = double.tryParse(_customWtCtrl.text);
    if (customWt != null && customWt > 0) {
      results.insert(0, _PriceResult('Custom: $customWt g', customWt.toInt(), _pricePerGram! * customWt));
    }

    setState(() => _results = results);
  }

  String _fmt(double v) {
    if (v >= 1) return v.toStringAsFixed(2);
    return v.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _totalWtCtrl.dispose();
    _totalPriceCtrl.dispose();
    _customWtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Card(
          color: cs.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Weight & Price Calculator',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cs.primary)),
              const SizedBox(height: 4),
              Text('Example: 50 kg @ ₹1400 → price per 100g, 300g, 12kg...',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _totalWtCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Total Weight',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                    onChanged: (_) => _calculate(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonFormField<String>(
                  value: _wtUnit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _wtUnits.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) { setState(() => _wtUnit = v!); _calculate(); },
                ),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: _totalPriceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Total Price (₹ or any currency)',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customWtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Custom weight in grams (optional)',
                  hintText: 'e.g. 300 for 300g',
                  prefixIcon: const Icon(Icons.tune_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                onChanged: (_) => _calculate(),
              ),
            ]),
          ),
        ),
        if (_pricePerGram != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Text('Price per gram', style: TextStyle(color: cs.onPrimaryContainer, fontSize: 13)),
              Text('₹ ${_fmt(_pricePerGram!)}',
                  style: TextStyle(color: cs.onPrimaryContainer, fontSize: 32, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 12),
          ..._results.map((r) => _ResultCard(result: r, cs: cs)),
        ],
      ]),
    );
  }
}

class _PriceResult {
  final String label;
  final int grams;
  final double price;
  _PriceResult(this.label, this.grams, this.price);
}

class _ResultCard extends StatelessWidget {
  final _PriceResult result;
  final ColorScheme cs;
  const _ResultCard({required this.result, required this.cs});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(children: [
        Expanded(child: Text(result.label, style: const TextStyle(fontWeight: FontWeight.w500))),
        Text('₹ ${result.price >= 1 ? result.price.toStringAsFixed(2) : result.price.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.primary)),
      ]),
    );
  }
}
