import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isAgreed = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('MMMM d, y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('privacy_policy'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for Financial Manager App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Display the current date
            Text(
              'Effective Date: $currentDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('1. Introduction'),
            const Text(
              'Welcome to Financial Manager App! We respect your privacy and are committed to protecting your personal information.',
            ),
            const SizedBox(height: 16),

            if (!_isExpanded) _buildInitialContent(),

            if (_isExpanded) _buildFullContent(),

            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(_isExpanded ? 'See Less' : 'See More'),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Checkbox(
                  value: _isAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isAgreed = value ?? false;
                    });
                  },
                ),
                const Text('I agree to the Privacy Policy'),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isAgreed
                    ? () {
                        Navigator.pop(context);
                      }
                    : null, // Disable button if not agreed
                child: const Text('Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('2. Information We Collect'),
        const Text(
          'We collect the following types of information: Personal Information, Automatically Collected Information, Third-Party Information.',
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Full content to show after "See More" is clicked
  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('3. How We Use Your Information'),
        const Text(
          'We use your information for the following purposes: To Operate the App, To Improve Our Services, To Communicate with You, To Ensure Compliance.',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('4. Sharing Your Information'),
        const Text(
          'We do not sell your personal information to third parties, but we may share your data under certain circumstances.',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('5. Data Security'),
        const Text(
          'We take your privacy seriously and implement industry-standard security measures.',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('6. Your Data Rights'),
        const Text(
          'You may have rights regarding your personal information, including: Access, Correction, Deletion, Data Portability, Opt-Out of Marketing.',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('7. Data Retention'),
        const Text(
          'We will retain your personal information only as long as necessary.',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('8. Children’s Privacy'),
        const Text(
          'Our app is not intended for children under the age of 15.',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('9. Changes to This Privacy Policy'),
        const Text(
          'We may update this Privacy Policy from time to time.',
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('10. Contact Us'),
        const Text(
          'If you have any questions, please contact us at: Email: NIBM.lk',
        ),
      ],
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text(
            'You need to agree to the Privacy Policy before exiting.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
