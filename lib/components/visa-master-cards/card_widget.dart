import 'dart:math';

import 'package:flutter/material.dart' hide Card;
import 'package:financial_app/models/card.dart';

class CardWidget extends StatelessWidget {
  final Card card;
  final Function()? deleteFunction;
  CardWidget({super.key, required this.card, required this.deleteFunction});

  final List<String> visaCardImages = [
    'assets/images/visacard1.png',
    'assets/images/visacard2.png',
    'assets/images/visacard3.png',
  ];

  final List<String> masterCardImages = [
    'assets/images/mastercard1.png',
    'assets/images/mastercard2.png',
    'assets/images/mastercard3.png',
  ];

  String getRandomVisaCardImage() {
    final random = Random();
    return card.isVisa
        ? visaCardImages[random.nextInt(visaCardImages.length)]
        : masterCardImages[random.nextInt(masterCardImages.length)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: deleteFunction,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Stack(
          children: [
            Image.asset(
              getRandomVisaCardImage(),
              height: 210,
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    card.cardholderName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: '•••• •••• •••• ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: card.cardNumber.substring(15),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        card.expireDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
