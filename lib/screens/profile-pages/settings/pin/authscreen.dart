import 'package:financial_app/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'pin_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum SupportState {
  unknown,
  supported,
  unSupported,
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;
  bool isBiometricEnabled = false;
  bool isPinEnabled = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then((bool isSupported) =>
        setState(() => supportState = isSupported ? SupportState.supported : SupportState.unSupported));
    checkBiometric();
    getAvailableBiometrics();
    _loadPinStatus();
  }

  Future<void> checkBiometric() async {
    late bool canCheckBiometric;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
      print("Biometric supported: $canCheckBiometric");
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometric = false;
    }

    if (canCheckBiometric) {
      setState(() {
        isBiometricEnabled = true;
      });
    }
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricTypes;
    try {
      biometricTypes = await auth.getAvailableBiometrics();
      print("Supported biometrics: $biometricTypes");
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) {
      return;
    }
    setState(() {
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> _loadPinStatus() async {
    String? savedPin = await secureStorage.read(key: 'user_pin');
    setState(() {
      isPinEnabled = savedPin != null;
    });
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      print('Attempting biometric authentication...');
      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate with fingerprint or Face ID',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    
      if (!mounted) return;

      print('Authenticated: $authenticated');
      if (authenticated) {
        Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } on PlatformException catch (e) {
      print('Authentication error: $e');
    }
  }

  Future<void> authenticateWithPin() async {
    // Check if a PIN has been set
    String? savedPin = await secureStorage.read(key: 'user_pin');
    if (savedPin != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinScreen(
            onSuccess: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
            },
            savedPin: savedPin,
          ),
        ),
      );
    } else {
      // If no PIN is set, prompt the user to set a PIN
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinScreen(
            isSettingPin: true,
            onPinSet: (pin) async {
              await secureStorage.write(key: 'user_pin', value: pin);
              setState(() {
                isPinEnabled = true;
              });
              Navigator.pop(context); // Return to the authentication screen
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security'),
      ),
      body: Column(
        children: [
          Text(
            supportState == SupportState.supported
                ? 'Biometric authentication is supported on this device'
                : supportState == SupportState.unSupported
                    ? 'Biometric authentication is not supported on this device'
                    : 'Checking biometric support...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: supportState == SupportState.supported
                  ? Colors.green
                  : supportState == SupportState.unSupported
                      ? Colors.red
                      : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Biometric Authentication"),
            secondary: const Icon(Icons.fingerprint),
            value: isBiometricEnabled,
            onChanged: (bool value) {
              if (value) {
                authenticateWithBiometrics();
              } else {
                setState(() {
                  isBiometricEnabled = false;
                });
              }
            },
          ),
          SwitchListTile(
            title: const Text("PIN Code"),
            secondary: const Icon(Icons.pin),
            value: isPinEnabled,
            onChanged: (bool value) {
              if (value) {
                authenticateWithPin();
              } else {
                setState(() {
                  isPinEnabled = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
