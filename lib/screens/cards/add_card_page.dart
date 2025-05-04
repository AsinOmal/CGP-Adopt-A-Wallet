import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/blocs/card/card_bloc.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/repositories/auth/auth_repository.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/custome_snackbar.dart';
import 'package:financial_app/models/card.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _cardNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  final FlipCardController _cardController = FlipCardController();

  Color nameBorderColor = Colors.transparent;
  Color numberBorderColor = Colors.transparent;
  Color dateBorderColor = Colors.transparent;
  Color cvvBorderColor = Colors.transparent;

  final FocusNode nameNode = FocusNode();
  final FocusNode dateNode = FocusNode();
  final FocusNode numberNode = FocusNode();
  final FocusNode cvvNode = FocusNode();

  void _flipCard() {
    cardKey.currentState!.toggleCard();
  }

  void _flipBackward() {
    if (!_cardController.state!.isFront) {
      cardKey.currentState!.toggleCard();
    }
  }

  Stack _buildCardBackView() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/card_back.png',
          height: 230,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 130),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Text(
                        _cvvController.text.isEmpty
                            ? '___'
                            : _cvvController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'CVV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Stack _buildFrontView() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/card.png',
          height: 230,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 130),
              Text(
                _cardNumberController.text.isEmpty
                    ? '____  ____  ____ ____'
                    : _cardNumberController.text,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, letterSpacing: 3),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _nameController.text.isEmpty
                        ? '______ _____'
                        : _nameController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _dateController.text.isEmpty
                        ? 'MM/YY'
                        : _dateController.text,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  final ImagePicker _picker = ImagePicker();
  String? frontImagePath;
  String? backImagePath;

  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void _getImage() async {
    await _captureBothSides();
  }

  Future<void> _captureBothSides() async {
    final XFile? frontImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (frontImage == null) {
      String message = AppLocalizations.of(context)
          .translate('front_side_image_not_captured');
      showErrorSnackBar(message);
      return;
    }
    frontImagePath = frontImage.path;

    //Future.delayed(const Duration(seconds: 1));
    String message =
        AppLocalizations.of(context).translate('capture_back_side_of_card');
    _speak(message);

    final XFile? backImage =
        await _picker.pickImage(source: ImageSource.camera);
    if (backImage == null) {
      String message = AppLocalizations.of(context)
          .translate('back_side_image_not_captured');
      showErrorSnackBar(message);
      return;
    }
    backImagePath = backImage.path;

    await _processBothCardImages(frontImagePath!, backImagePath!);
  }

  Future<void> _processBothCardImages(
      String frontImagePath, String backImagePath) async {
    final InputImage frontInputImage = InputImage.fromFilePath(frontImagePath);
    final InputImage backInputImage = InputImage.fromFilePath(backImagePath);
    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedFrontText =
        await textRecognizer.processImage(frontInputImage);
    final RecognizedText recognizedBackText =
        await textRecognizer.processImage(backInputImage);

    _extractDetailsFromImages(
        recognizedFrontText.text, recognizedBackText.text);
  }

  void _extractDetailsFromImages(String frontText, String backText) {
    String? cardNumber;
    String? expiryDate;
    String? cvv;

    final cardNumberRegex = RegExp(r'\b\d{4} \d{4} \d{4} \d{4}\b');
    final cardNumberMatch = cardNumberRegex.firstMatch(frontText);
    if (cardNumberMatch != null) {
      cardNumber = cardNumberMatch.group(0);
    }

    final expiryDateRegex = RegExp(r'\b\d{2}/\d{2}\b');
    final expiryDateMatch = expiryDateRegex.firstMatch(frontText);
    if (expiryDateMatch != null) {
      expiryDate = expiryDateMatch.group(0);
    }

    final cvvRegex = RegExp(r'\b\d{3}\b');
    final cvvMatch = cvvRegex.firstMatch(backText);
    if (cvvMatch != null) {
      cvv = cvvMatch.group(0);
    }

    if (cardNumber != null && expiryDate != null && cvv != null) {
      _populateCardFields(cardNumber, expiryDate, cvv);
    } else {
      String message =
          AppLocalizations.of(context).translate('unable_to_extract_details');
      showErrorSnackBar(message);
    }
  }

  void _populateCardFields(
      String? cardNumber, String? expiryDate, String? cvv) {
    setState(() {
      _cardNumberController.text = cardNumber ?? '';
      _dateController.text = expiryDate ?? '';
      _cvvController.text = cvv ?? '';
    });
  }

  void showErrorSnackBar(String error) {
    CustomSnackBar.show(context,
        title: 'Oh Snap!', message: error, contentType: ContentType.failure);
  }

  late CardBloc _cardBloc;
  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _cardBloc = RepositoryProvider.of<CardBloc>(context);
    _authRepository = RepositoryProvider.of<AuthRepository>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('add_your_card'),
            style: const TextStyle(fontSize: 22),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const ImageIcon(
                AssetImage('assets/icons/scan.ico'),
              ),
              onPressed: _getImage,
            ),
          ),
        ],
      ),
      body: BlocListener<CardBloc, CardState>(
        listener: (context, state) {
          if (state is CardAddLoading) {
            showDialog(
              context: context,
              builder: (context) {
                return const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                );
              },
            );
          } else if (state is CardAddSuccess) {
            Navigator.pop(context);
            _clearFields();
            CustomSnackBar.showSuccessSnackBar('Card add success', context);
            _cardBloc.add(CardFetchEvent(userID: _authRepository.userID));
          } else if (state is CardAddError) {
            Navigator.pop(context);
            CustomSnackBar.showErrorSnackBar(state.message, context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FlipCard(
                        controller: _cardController,
                        key: cardKey,
                        front: _buildFrontView(),
                        back: _buildCardBackView(),
                      ),
                      const SizedBox(height: 50),
                      InputField(
                        isObsecure: false,
                        controller: _nameController,
                        borderColor: nameBorderColor,
                        focusNode: nameNode,
                        isReadOnly: false,
                        label: AppLocalizations.of(context)
                            .translate('card_holder_name'),
                        onChanged: (p0) => setState(() {}),
                        inputFormat: [
                          LengthLimitingTextInputFormatter(16),
                        ],
                        onTap: _flipBackward,
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        isObsecure: false,
                        controller: _cardNumberController,
                        borderColor: numberBorderColor,
                        focusNode: numberNode,
                        isReadOnly: false,
                        label: AppLocalizations.of(context)
                            .translate('card_number'),
                        onChanged: (p0) => setState(() {}),
                        onTap: _flipBackward,
                        keyboardType: TextInputType.number,
                        inputFormat: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          CardNumberInputFormatter(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InputField(
                              isObsecure: false,
                              controller: _dateController,
                              borderColor: dateBorderColor,
                              focusNode: dateNode,
                              isReadOnly: false,
                              onChanged: (p0) => setState(() {}),
                              label: AppLocalizations.of(context)
                                  .translate('expire_date'),
                              onTap: _flipBackward,
                              keyboardType: TextInputType.number,
                              inputFormat: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                ExpiryDateInputFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: InputField(
                              isObsecure: false,
                              controller: _cvvController,
                              borderColor: cvvBorderColor,
                              focusNode: cvvNode,
                              isReadOnly: false,
                              onChanged: (p0) => setState(() {}),
                              keyboardType: TextInputType.number,
                              label:
                                  AppLocalizations.of(context).translate('cvv'),
                              inputFormat: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              onTap: _flipCard,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SimpleButton(
                data: 'save_card',
                onPressed: () {
                  nameNode.unfocus();
                  numberNode.unfocus();
                  dateNode.unfocus();
                  cvvNode.unfocus();
                  FocusScope.of(context).unfocus();
                  String name = _nameController.text;
                  String cardNumber = _cardNumberController.text;
                  String date = _dateController.text;
                  String cvv = _cvvController.text;

                  if (_validateInputs(name, cardNumber, date, cvv)) {
                    bool isVisa = false;
                    if (cardNumber.startsWith('4')) {
                      isVisa = true;
                    } else if (cardNumber.startsWith('2') ||
                        cardNumber.startsWith('5')) {
                      isVisa = false;
                    } else {
                      CustomSnackBar.showErrorSnackBar(
                          "Invalid Card Number", context);
                      return;
                    }

                    final card = Card(
                      userID: _authRepository.userID,
                      cardholderName: name,
                      cardNumber: cardNumber,
                      expireDate: date,
                      cvv: cvv,
                      isVisa: isVisa,
                      createdAt: Timestamp.now(),
                    );
                    _cardBloc.add(CardAddEvent(card: card));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isFutureDate(String expireDate) {
    // Split the input to get month and year parts
    final parts = expireDate.split('/');
    if (parts.length != 2) return true; // Ensure input format is correct

    final int month = int.tryParse(parts[0]) ?? 0;
    final int year = int.tryParse(parts[1]) ?? 0;

    if (month < 1 || month > 12) return true; // Check if month is valid

    // Get the current date
    final DateTime now = DateTime.now();
    final int currentYear =
        now.year % 100; // Get the last two digits of the year
    final int currentMonth = now.month;

    // Check if the entered year and month are in the future
    if (year > currentYear || (year == currentYear && month >= currentMonth)) {
      return false;
    }

    return true;
  }

  void _clearFields() {
    _nameController.text = '';
    _cardNumberController.text = '';
    _dateController.text = '';
    _cvvController.text = '';
  }

  bool _validateInputs(
      String name, String cardNumber, String expireDate, String cvv) {
    setState(() {
      nameBorderColor = Colors.transparent;
      numberBorderColor = Colors.transparent;
      dateBorderColor = Colors.transparent;
      cvvBorderColor = Colors.transparent;
    });

    if (name.isEmpty) {
      setState(() {
        nameBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Name must be required', context);
      return false;
    } else if (cardNumber.isEmpty) {
      setState(() {
        numberBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Card number must be required', context);
      return false;
    } else if (cardNumber.length != 19) {
      setState(() {
        numberBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar(
          'Card number must have 16 characters', context);
      return false;
    } else if (expireDate.isEmpty) {
      setState(() {
        dateBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Expire date must be required', context);
      return false;
    } else if (expireDate.length != 5 || isFutureDate(expireDate)) {
      setState(() {
        dateBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Invalid expire date', context);
      return false;
    } else if (cvv.isEmpty || cvv.length != 3) {
      setState(() {
        cvvBorderColor = Colors.red;
      });
      CustomSnackBar.showErrorSnackBar('Invalid CVV!', context);
      return false;
    }
    return true;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formattedText = '';
    for (int i = 0; i < newText.length; i++) {
      if (i % 4 == 0 && i != 0) formattedText += ' ';
      formattedText += newText[i];
    }
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formattedText = '';
    if (newText.length > 2) {
      formattedText =
          '${newText.substring(0, 2)}/${newText.substring(2, newText.length)}';
    } else {
      formattedText = newText;
    }
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
