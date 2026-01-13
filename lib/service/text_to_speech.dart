import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  // ---------------- Singleton ----------------
  static final TtsHelper _instance = TtsHelper._internal();
  factory TtsHelper() => _instance;
  TtsHelper._internal() {
    _init();
  }

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  // Callbacks
  Function()? onStart;
  Function()? onComplete;
  Function(String msg)? onError;

  // ---------------- Initialization ----------------
  Future<void> _init() async {
    if (_initialized) return;

    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1);
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.6);
    await _tts.awaitSpeakCompletion(true);

    // Callbacks
    _tts.setStartHandler(() {
      if (onStart != null) onStart!();
    });

    _tts.setCompletionHandler(() {
      if (onComplete != null) onComplete!();
    });

    _tts.setErrorHandler((msg) {
      if (onError != null) onError!(msg);
    });

    _initialized = true;
  }

  // ---------------- Voice Selection ----------------
  Future<List<dynamic>> getVoices() async {
    return await _tts.getVoices;
  }

  Future<void> setVoice(Map<String, String> voice) async {
    await _tts.setVoice(voice);
  }

  Future<List<Map<String, String>>> getEnglishVoices() async {
    final voices = await getVoices();
    return voices
        .where((v) => v["locale"]?.toString().startsWith("en") ?? false)
        .map<Map<String, String>>(
          (v) => {"name": v["name"], "locale": v["locale"]},
        )
        .toList();
  }

  // ---------------- Text Splitting ----------------
  List<String> _splitText(String text, {int chunkSize = 200}) {
    final List<String> chunks = [];
    text = text.trim();

    while (text.isNotEmpty) {
      if (text.length <= chunkSize) {
        chunks.add(text);
        break;
      }

      // Split on last space near chunkSize
      int splitIndex = text.lastIndexOf(' ', chunkSize);
      if (splitIndex == -1) splitIndex = chunkSize;

      chunks.add(text.substring(0, splitIndex).trim());
      text = text.substring(splitIndex).trim();
    }

    return chunks;
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.speak(text);
  }

  /*   // ---------------- Speak (with long text support) ----------------
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    final chunks = _splitText(text);

    for (final chunk in chunks) {
      await _tts.speak(chunk);
      await Future.doWhile(() async => await _tts.isSpeaking);
    }
  } */

  // ---------------- Stop ----------------
  Future<void> stop() async {
    await _tts.stop();
  }

  // ---------------- Dispose ----------------
  Future<void> dispose() async {
    await _tts.stop();
  }
}
