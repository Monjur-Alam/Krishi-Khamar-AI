/// Example secrets file. Copy to `secrets.dart` and add your key.
/// Or run with: flutter run --dart-define=OPENAI_API_KEY=sk-...
class Secrets {
  Secrets._();

  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
}
