import 'package:financial_app/language/language_provider.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({super.key});

  @override
  State<LanguageSelection> createState() => _LanguageSelectionState();
}

class _LanguageSelectionState extends State<LanguageSelection> {
  final String usaImg = 'assets/images/usa.png';

  final String slImg = 'assets/images/sri_lanka.png';
  String _selectedType = 'en';

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context).translate('welcome'),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            AppLocalizations.of(context).translate('select_language'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 40),
          LanguageButton(
            language: 'English',
            flag: usaImg, // Replace with an English flag asset or widget
            selected: _selectedType == 'en',
            onTap: () {
              setState(() {
                _selectedType = 'en';
              });
              languageProvider.setLocale(const Locale('en'));
            },
          ),
          const SizedBox(height: 15),
          LanguageButton(
            language: 'සිංහල',
            flag: slImg, // Replace with an Arabic flag asset or widget
            selected: _selectedType == 'sl',
            onTap: () {
              setState(() {
                _selectedType = 'sl';
              });
              languageProvider.setLocale(const Locale('sl'));
            },
          ),
        ],
      ),
    );
  }
}

class LanguageButton extends StatelessWidget {
  final String language;
  final String flag;
  final bool selected;

  final VoidCallback onTap;

  const LanguageButton({
    required this.language,
    required this.flag,
    required this.selected,
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 60, // Increased height
          decoration: BoxDecoration(
            color: selected ? Colors.white : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 20.0,
                backgroundImage: AssetImage(flag),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(width: 12),
              Text(
                language,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.black54 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
