import 'package:flutter/material.dart';

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({super.key});

  @override
  State<LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle> {
  String _currentLanguage = 'English';

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'English' ? 'Myanmar' : 'English';
      // TODO: Implement actual language change logic
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _toggleLanguage,
      child: Text(_currentLanguage),
    );
  }
}
