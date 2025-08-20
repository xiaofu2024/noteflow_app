import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  final SpeechToText _speechToText = SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();

  bool _speechEnabled = false;
  bool get speechEnabled => _speechEnabled;

  // Initialize AI services
  Future<void> initialize() async {
    try {
      _speechEnabled = await _speechToText.initialize();
    } catch (e) {
      print('Error initializing AI services: $e');
    }
  }

  // OCR Text Recognition
  Future<String?> recognizeTextFromImage({File? imageFile}) async {
    try {
      File? file = imageFile;
      
      if (file == null) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        
        if (pickedFile == null) return null;
        file = File(pickedFile.path);
      }

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text.isNotEmpty ? recognizedText.text : null;
    } catch (e) {
      print('Error recognizing text from image: $e');
      return null;
    }
  }

  // Pick image from gallery and extract text
  Future<String?> recognizeTextFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      
      return await recognizeTextFromImage(imageFile: File(pickedFile.path));
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Speech to Text
  Future<String?> startListening({
    String localeId = 'zh_CN',
    Function(String)? onResult,
    Function(String)? onError,
  }) async {
    if (!_speechEnabled) {
      onError?.call('Speech recognition not available');
      return null;
    }

    try {
      String recognizedWords = '';
      
      await _speechToText.listen(
        localeId: localeId,
        onResult: (result) {
          recognizedWords = result.recognizedWords;
          onResult?.call(recognizedWords);
        },
        onSoundLevelChange: (level) {
          // Handle sound level changes for UI feedback
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
        ),
      );
      
      return recognizedWords;
    } catch (e) {
      print('Error starting speech recognition: $e');
      onError?.call('Error starting speech recognition: $e');
      return null;
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  // Audio Recording (for voice notes)
  Future<bool> startRecording({required String filePath}) async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
        return true;
      } else {
        print('Audio recording permission not granted');
        return false;
      }
    } catch (e) {
      print('Error starting audio recording: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      return path;
    } catch (e) {
      print('Error stopping audio recording: $e');
      return null;
    }
  }

  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  // Get available speech locales
  Future<List<String>> getAvailableLanguages() async {
    try {
      final locales = await _speechToText.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      print('Error getting available languages: $e');
      return ['zh_CN', 'en_US'];
    }
  }

  // AI Text Enhancement (placeholder for future implementation)
  Future<String> enhanceText(String text) async {
    // TODO: Integrate with AI service (OpenAI, Google AI, etc.)
    // For now, just return basic formatting
    return text.trim();
  }

  // AI Text Summary (placeholder for future implementation)
  Future<String> summarizeText(String text) async {
    // TODO: Integrate with AI service for text summarization
    if (text.length <= 100) return text;
    
    // Simple truncation for now
    return '${text.substring(0, 100)}...';
  }

  // Generate tags from content (basic implementation)
  List<String> generateTags(String content) {
    final commonWords = ['的', '是', '在', '了', '和', '就', '都', '而', '及', '与', '或'];
    
    // Extract potential keywords (simplified)
    final words = content
        .replaceAll(RegExp(r'[^\u4e00-\u9fa5a-zA-Z\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1 && !commonWords.contains(word))
        .toSet()
        .take(5)
        .toList();
    
    return words;
  }

  // Dispose resources
  Future<void> dispose() async {
    await _textRecognizer.close();
    _audioRecorder.dispose();
  }
}