import 'package:financial_app/language/transalation.dart';
import 'package:flutter/material.dart';

class RatingDialog extends StatelessWidget {
  final ValueNotifier<double> userRating = ValueNotifier<double>(0);

  RatingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).translate('rate_our_app')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < userRating.value ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () {
                  if (userRating.value == index + 1) {
                    userRating.value = 0;
                  } else {
                    userRating.value = index + 1.0;
                  }
                },
              );
            }),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<double>(
            valueListenable: userRating,
            builder: (context, rating, child) {
              return Text(
                  "${AppLocalizations.of(context).translate('your_rating')}: $rating");
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child:  Text(AppLocalizations.of(context).translate('cancel')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context).translate('submit')),
          onPressed: () {
            // You can handle the submission of the rating here
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
