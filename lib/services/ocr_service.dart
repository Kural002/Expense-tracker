import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class BillScanResult {
  final double? amount;
  final String? title;
  final DateTime? date;

  BillScanResult({this.amount, this.title, this.date});
}

class _AmountCandidate {
  final double value;
  final double height;
  final bool hasCurrency;
  final bool isStandalone;
  final bool hasContextPenalty;

  _AmountCandidate({
    required this.value,
    required this.height,
    this.hasCurrency = false,
    this.isStandalone = false,
    this.hasContextPenalty = false,
  });

  double get score {
    double s = height * 2; // Font size is the primary indicator
    if (hasCurrency) s += 200; // Currency symbol is very strong
    if (isStandalone) s += 100; // Standalone numbers are better than sentences
    if (hasContextPenalty) s -= 1000; // Negative context (Bank, ID) is a killer
    return s;
  }
}

class OcrService {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<BillScanResult?> scanBill() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseRecognizedText(recognizedText);
    } catch (e) {
      debugPrint("OCR Error: $e");
      return null;
    }
  }

  Future<BillScanResult?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return _parseRecognizedText(recognizedText);
    } catch (e) {
      debugPrint("OCR Error: $e");
      return null;
    }
  }

  BillScanResult _parseRecognizedText(RecognizedText recognizedText) {
    if (recognizedText.text.isEmpty) return BillScanResult();

    String? title;
    double? amount;
    List<_AmountCandidate> candidates = [];

    final currencyPattern = RegExp(r'₹|Rs|RS|INR|\$');
    final genericNumberPattern = RegExp(r'\d+(?:[.,]\d{1,2})?');
    final contextPenaltyPattern = RegExp(r'bank|account|a/c|ending|id|mobile|card|xxx', caseSensitive: false);
    final upiTitleKeywords = RegExp(r'paid to|sent to|to ', caseSensitive: false);

    // Flatten lines for title searching
    List<String> allLines = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final lineText = line.text.trim();
        allLines.add(lineText);

        // --- Amount Parsing Logic ---
        final matches = genericNumberPattern.allMatches(lineText);
        for (var m in matches) {
          final valStr = m.group(0)!.replaceAll(',', '.');
          
          // Noise filter: Transaction IDs (10+ digits) or year-like constants
          if (valStr.replaceAll('.', '').length >= 10) continue;
          
          final val = double.tryParse(valStr);
          if (val != null && val > 0) {
            // Heuristics
            final hasCurrency = currencyPattern.hasMatch(lineText) || 
                               (line.text.length < 5 &&  recognizedText.text.contains(RegExp(r'₹|Rs')));
            
            final isStandalone = line.text.length < 15; // Short lines are usually the total
            final hasContextPenalty = contextPenaltyPattern.hasMatch(lineText);
            
            // Priority Check: If year-like (2024-2026), penalize unless it has a currency symbol
            bool isYear = val >= 2024 && val <= 2030;
            
            candidates.add(_AmountCandidate(
              value: val,
              height: line.boundingBox.height,
              hasCurrency: hasCurrency,
              isStandalone: isStandalone,
              hasContextPenalty: hasContextPenalty || isYear,
            ));
          }
        }
      }
    }

    // --- Title Parsing Logic ---
    for (int i = 0; i < allLines.length; i++) {
      if (upiTitleKeywords.hasMatch(allLines[i])) {
        String potentialTitle = allLines[i].replaceFirst(upiTitleKeywords, '').trim();
        if (potentialTitle.isEmpty && i + 1 < allLines.length) {
          potentialTitle = allLines[i + 1];
        }
        if (potentialTitle.isNotEmpty && potentialTitle.length > 2) {
          title = potentialTitle;
          break;
        }
      }
    }

    // Fallback title
    if (title == null) {
      for (var line in allLines) {
        if (line.length > 5 && !RegExp(r'^\d+$').hasMatch(line) && !line.toLowerCase().contains("payment")) {
          title = line;
          break;
        }
      }
    }

    // --- Select Best Amount ---
    if (candidates.isNotEmpty) {
      candidates.sort((a, b) => b.score.compareTo(a.score));
      amount = candidates.first.value;
    }

    return BillScanResult(
      amount: amount,
      title: title,
      date: DateTime.now(),
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
