import 'dart:convert';
import 'package:financial_app/data/keys.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../components/simple_button.dart';

class MoneyConveror extends StatefulWidget {
  const MoneyConveror({super.key});

  @override
  State<MoneyConveror> createState() => _MoneyConverorState();
}

class _MoneyConverorState extends State<MoneyConveror> {
  String? fromCurrency = 'USD';
  String? toCurrency = 'SGD';
  TextEditingController amountController = TextEditingController();
  double convertedAmount = 0.0;

  List<String> currencies = [
    'USD', // United States Dollar
    'SGD', // Singapore Dollar
    'EUR', // Euro
    'JPY', // Japanese Yen
    'GBP', // British Pound Sterling
    'AUD', // Australian Dollar
    'LKR', // Sri Lankan Rupee
    'CAD', // Canadian Dollar
    'CHF', // Swiss Franc
    'CNY', // Chinese Yuan
    'INR', // Indian Rupee
    'NZD', // New Zealand Dollar
    'MXN', // Mexican Peso
    'HKD', // Hong Kong Dollar
    'SEK', // Swedish Krona
    'NOK', // Norwegian Krone
    'RUB', // Russian Ruble
    'ZAR', // South African Rand
    'BRL', // Brazilian Real
    'IDR', // Indonesian Rupiah
    'MYR', // Malaysian Ringgit
    'PHP', // Philippine Peso
    'THB', // Thai Baht
    'VND', // Vietnamese Dong
    'DKK', // Danish Krone
    'PLN', // Polish Zloty
    'HUF', // Hungarian Forint
    'CZK', // Czech Koruna
    'ILS', // Israeli New Shekel
    'AED', // United Arab Emirates Dirham
    'SAR', // Saudi Riyal
    'TRY', // Turkish Lira
    'PKR', // Pakistani Rupee
    'NGN', // Nigerian Naira
    'KES', // Kenyan Shilling
    'CLP', // Chilean Peso
    'COP', // Colombian Peso
    'PEN', // Peruvian Sol
    'MAD', // Moroccan Dirham
    'DOP', // Dominican Peso
    'GTQ', // Guatemalan Quetzal
    'PAB', // Panamanian Balboa
  ];

  String exchangeRateMessage = '';

  Map<String, String> currencyFlags = {
    'USD': 'https://flagcdn.com/w320/us.png', // United States Dollar
    'SGD': 'https://flagcdn.com/w320/sg.png', // Singapore Dollar
    'EUR': 'https://flagcdn.com/w320/eu.png', // Euro
    'JPY': 'https://flagcdn.com/w320/jp.png', // Japanese Yen
    'GBP': 'https://flagcdn.com/w320/gb.png', // British Pound Sterling
    'AUD': 'https://flagcdn.com/w320/au.png', // Australian Dollar
    'LKR': 'https://flagcdn.com/w320/lk.png', // Sri Lankan Rupee
    'CAD': 'https://flagcdn.com/w320/ca.png', // Canadian Dollar
    'CHF': 'https://flagcdn.com/w320/ch.png', // Swiss Franc
    'CNY': 'https://flagcdn.com/w320/cn.png', // Chinese Yuan
    'INR': 'https://flagcdn.com/w320/in.png', // Indian Rupee
    'NZD': 'https://flagcdn.com/w320/nz.png', // New Zealand Dollar
    'MXN': 'https://flagcdn.com/w320/mx.png', // Mexican Peso
    'HKD': 'https://flagcdn.com/w320/hk.png', // Hong Kong Dollar
    'SEK': 'https://flagcdn.com/w320/se.png', // Swedish Krona
    'NOK': 'https://flagcdn.com/w320/no.png', // Norwegian Krone
    'RUB': 'https://flagcdn.com/w320/ru.png', // Russian Ruble
    'ZAR': 'https://flagcdn.com/w320/za.png', // South African Rand
    'BRL': 'https://flagcdn.com/w320/br.png', // Brazilian Real
    'IDR': 'https://flagcdn.com/w320/id.png', // Indonesian Rupiah
    'MYR': 'https://flagcdn.com/w320/my.png', // Malaysian Ringgit
    'PHP': 'https://flagcdn.com/w320/ph.png', // Philippine Peso
    'THB': 'https://flagcdn.com/w320/th.png', // Thai Baht
    'VND': 'https://flagcdn.com/w320/vn.png', // Vietnamese Dong
    'DKK': 'https://flagcdn.com/w320/dk.png', // Danish Krone
    'PLN': 'https://flagcdn.com/w320/pl.png', // Polish Zloty
    'HUF': 'https://flagcdn.com/w320/hu.png', // Hungarian Forint
    'CZK': 'https://flagcdn.com/w320/cz.png', // Czech Koruna
    'ILS': 'https://flagcdn.com/w320/il.png', // Israeli New Shekel
    'AED': 'https://flagcdn.com/w320/ae.png', // United Arab Emirates Dirham
    'SAR': 'https://flagcdn.com/w320/sa.png', // Saudi Riyal
    'TRY': 'https://flagcdn.com/w320/tr.png', // Turkish Lira
    'PKR': 'https://flagcdn.com/w320/pk.png', // Pakistani Rupee
    'NGN': 'https://flagcdn.com/w320/ng.png', // Nigerian Naira
    'KES': 'https://flagcdn.com/w320/ke.png', // Kenyan Shilling
    'CLP': 'https://flagcdn.com/w320/cl.png', // Chilean Peso
    'COP': 'https://flagcdn.com/w320/co.png', // Colombian Peso
    'PEN': 'https://flagcdn.com/w320/pe.png', // Peruvian Sol
    'MAD': 'https://flagcdn.com/w320/ma.png', // Moroccan Dirham
    'DOP': 'https://flagcdn.com/w320/do.png', // Dominican Peso
    'GTQ': 'https://flagcdn.com/w320/gt.png', // Guatemalan Quetzal
    'PAB': 'https://flagcdn.com/w320/pa.png', // Panamanian Balboa
  };

  Future<void> convertCurrency() async {
    String from = fromCurrency!;
    String to = toCurrency!;
    double amount = double.parse(amountController.text);

    String url =
        'https://v6.exchangerate-api.com/v6/$CONVERTOR_API_KEY/pair/$from/$to/$amount';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          convertedAmount = data['conversion_result'];
          exchangeRateMessage = '1 $from = ${data['conversion_rate']} $to';
        });
      } else {
        throw Exception('Failed to load conversion rate');
      }
    } catch (e) {
      setState(() {
        exchangeRateMessage = 'Error fetching exchange rate';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Center(
          child: Text(
            AppLocalizations.of(context).translate('currency_converter'),
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
             Text(
              AppLocalizations.of(context).translate('live_rates_info'),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.network(
                        currencyFlags[fromCurrency]!,
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: fromCurrency,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (String? newValue) {
                            setState(() {
                              fromCurrency = newValue;
                            });
                          },
                          items: currencies
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: AppLocalizations.of(context).translate('amount'),
                      labelStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF456EFE), width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.swap_vert,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        setState(() {
                          String? temp = fromCurrency;
                          fromCurrency = toCurrency;
                          toCurrency = temp;
                        });
                        await convertCurrency();
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Divider(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.network(
                        currencyFlags[toCurrency]!,
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: toCurrency,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (String? newValue) {
                            setState(() {
                              toCurrency = newValue;
                            });
                          },
                          items: currencies
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.surfaceDim),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      convertedAmount.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
             Text(
              AppLocalizations.of(context).translate('indicative_exchange_rate'),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              exchangeRateMessage,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            SimpleButton(
              data: 'convert',
              onPressed: () async {
                await convertCurrency();
              },
            ),
          ],
        ),
      ),
    );
  }
}
