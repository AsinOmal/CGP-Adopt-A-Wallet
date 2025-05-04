import 'package:financial_app/language/language_provider.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/screens/profile-pages/account_info/change_password.dart';
import 'package:financial_app/screens/profile-pages/settings/pin/authscreen.dart';
import 'package:financial_app/services/sms_service.dart';
import 'package:financial_app/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isOnline = true;
  bool autoLogin = false;
  bool rememberLoginDetails = false;
  bool pinCode = false;
  String pinNumber = '';
  late SmsService _smsService;
  bool isTransactionEnabled = false;
  bool _isLoading = true; // Add this line

  Future<bool> getBoolValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool('isTransactionEnabled') ?? false;

    return value;
  }

  Future<void> saveBoolValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTransactionEnabled', value);
  }

  Future<void> _initializeSmsService() async {
    isTransactionEnabled = await getBoolValue();
    setState(() {
      _isLoading = false; // Add this line
    });
    dev.log(isTransactionEnabled.toString());
  }

  @override
  void initState() {
    super.initState();
    _smsService = Provider.of<SmsService>(context, listen: false);
    _initializeSmsService();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    if (_isLoading) {
      // Add this block
      return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('settings'),
            style: const TextStyle(fontSize: 22),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('settings'),
          style: const TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            AppLocalizations.of(context).translate('account'),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.key,
                size: 26,
              ),
              title: Text(
                AppLocalizations.of(context).translate('change_password'),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePassword(),
                    ));
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.sync,
                size: 26,
              ),
              title: Text(
                AppLocalizations.of(context).translate('auto_transaction'),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isTransactionEnabled,
                  onChanged: (value) {
                    _smsService.toggleListen(value);
                    saveBoolValue(value);
                    setState(() {
                      isTransactionEnabled = value;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: 26,
              ),
              title: Text(
                AppLocalizations.of(context).translate('dark_mode'),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(!isDarkMode);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.language,
                size: 26,
              ),
              title: Text(
                AppLocalizations.of(context).translate('language'),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  elevation: 6,
                  value: languageProvider.locale,
                  items: const [
                    DropdownMenuItem(
                        value: Locale('en'), child: Text('English')),
                    DropdownMenuItem(value: Locale('sl'), child: Text('සිංහල')),
                  ],
                  onChanged: (Locale? value) {
                    if (value != null) {
                      languageProvider.setLocale(value);
                    }
                  },
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.grey),
          ),
          Text(
            AppLocalizations.of(context).translate('security'),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(
                pinCode ? Icons.lock : Icons.lock_open,
                size: 26,
              ),
              title: Text(
                AppLocalizations.of(context).translate('pin_code'),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: pinCode,
                  onChanged: (value) {
                    setState(() {
                      pinCode = value;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()),
                    );
                  },
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.grey),
          ),
          Text(
            AppLocalizations.of(context).translate('app_information'),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceDim,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.help_outline,
                size: 26,
              ),
              title: Text(
                AppLocalizations.of(context).translate('help_support'),
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              onTap: () {
                // Handle Help / Support tap
              },
            ),
          ),
          const SizedBox(height: 80),
          const Center(
              child: Text(
            'v1.0.0',
            style: TextStyle(fontSize: 16),
          )),
        ],
      ),
    );
  }
}
