import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'unit_converter_screen.dart';
import 'currency_converter_screen.dart';
import 'price_calculator_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;
  final PageController _pc = PageController();

  final List<_NavItem> _items = [
    _NavItem('Calculator', Icons.calculate_rounded),
    _NavItem('Units', Icons.straighten_rounded),
    _NavItem('Currency', Icons.currency_exchange_rounded),
    _NavItem('Price Calc', Icons.shopping_cart_rounded),
    _NavItem('History', Icons.history_rounded),
  ];

  final List<Widget> _screens = [
    const CalculatorScreen(),
    const UnitConverterScreen(),
    const CurrencyConverterScreen(),
    const PriceCalculatorScreen(),
    const HistoryScreen(),
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    setState(() => _idx = i);
    _pc.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_idx].label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: PageView(
        controller: _pc,
        onPageChanged: (i) => setState(() => _idx = i),
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: _onTap,
        animationDuration: const Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: _items
            .map((e) => NavigationDestination(icon: Icon(e.icon), label: e.label))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  _NavItem(this.label, this.icon);
}
