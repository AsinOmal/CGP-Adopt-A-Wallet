import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ImageScanner {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.camera);
  }

  Future<void> processImage(
      String imagePath, Function(String) onTextParsed) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      onTextParsed(recognizedText.text);
    } finally {
      textRecognizer.close();
    }
  }

  void parseReceiptText(
      String text, Function(double?, String?, String?, String?) onParsed) {
    double? amount;
    String? category;
    String? date;
    String? description;

    final totalAmountRegex = RegExp(
        r'(?:total|amount|net amount)\s+(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
        caseSensitive: false);
    final totalAmountMatch = totalAmountRegex.firstMatch(text);
    if (totalAmountMatch != null) {
      amount = double.tryParse(totalAmountMatch.group(1)!.replaceAll(',', ''));
    } else {
      final amountRegex =
          RegExp(r'(\$|LKR|Rs\.)?\s?\d{1,3}(,\d{3})*(\.\d{2})?');
      final allMatches = amountRegex.allMatches(text);
      if (allMatches.isNotEmpty) {
        amount = double.tryParse(allMatches.last
            .group(0)!
            .replaceAll(',', '')
            .replaceAll(RegExp(r'(\$|LKR|Rs\.)'), ''));
      }
    }

    final dateRegex = RegExp(
        r'\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{1,2}\s+\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\b\s+\d{2,4})\b',
        caseSensitive: false);
    final dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      String? extractedDate = dateMatch.group(0);
      DateTime parsedDate;

      try {
        parsedDate = DateFormat('yyyy-MM-dd').parseStrict(extractedDate!);
      } catch (e) {
        try {
          parsedDate = DateFormat('dd/MM/yyyy').parseStrict(extractedDate!);
        } catch (e) {
          try {
            parsedDate = DateFormat('dd MMM yyyy').parseStrict(extractedDate!);
          } catch (e) {
            parsedDate = DateTime.now();
          }
        }
      }

      date = DateFormat('yyyy-MM-dd').format(parsedDate);
    }

    const transportKeywords = [
      'transport',
      'travel',
      'taxi',
      'bus',
      'train',
      'subway',
      'airfare',
      'fuel',
      'parking',
      'car rental'
    ];
    const educationKeywords = [
      'education',
      'school',
      'tuition',
      'institute',
      'college',
      'university',
      'books',
      'course',
      'training',
      'exam',
      'learning',
      'class',
      'study',
      'stationery'
    ];
    const sportKeywords = [
      'sport',
      'gym',
      'fitness',
      'exercise',
      'yoga',
      'running',
      'swimming',
      'cycling',
      'team',
      'equipment'
    ];
    const shoppingKeywords = [
      'shopping',
      'purchase',
      'buy',
      'store',
      'mall',
      'market',
      'clothing',
      'electronics',
      'online shopping',
      'sale'
    ];
    const kidsKeywords = [
      'kids',
      'children',
      'toys',
      'education',
      'school',
      'daycare',
      'activities',
      'playground',
      'babysitter',
      'clothes'
    ];
    const entertainmentKeywords = [
      'entertainment',
      'movie',
      'concert',
      'game',
      'ticket',
      'show',
      'theater',
      'amusement park',
      'streaming',
      'night out'
    ];
    const foodKeywords = [
      'food',
      'meal',
      'restaurant',
      'dining',
      'groceries',
      'takeaway',
      'delivery',
      'cafe',
      'fast food',
      'snacks'
    ];
    const healthKeywords = [
      'health',
      'medical',
      'doctor',
      'hospital',
      'clinic',
      'pharmacy',
      'medication',
      'insurance',
      'therapy',
      'treatment',
      'dentist',
      'optometrist',
      'wellness',
      'health check',
      'exercise',
      'physical therapy',
      'vitamins',
      'supplements',
      'emergency',
      'vaccination'
    ];

    if (healthKeywords.any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Health';
    }
    if (educationKeywords
        .any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Education';
    }
    if (transportKeywords
        .any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Transport';
    } else if (sportKeywords
        .any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Sport';
    } else if (shoppingKeywords
        .any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Shopping';
    } else if (kidsKeywords
        .any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Kids';
    } else if (entertainmentKeywords
        .any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Entertainment';
    } else if (foodKeywords
        .any((keyword) => text.toLowerCase().contains(keyword))) {
      category = 'Food';
    }

    description = text.split('\n').first;
    onParsed(amount, category, date, description);
  }
}
