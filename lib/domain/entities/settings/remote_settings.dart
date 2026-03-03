import '../remote_input/keyboard/keyboard_language.dart';
import '../remote_navigation_entity.dart';

class RemoteSettings {
  // Mouse
  final double mouseSpeed;
  final bool shouldInvertMouseScrollingDirection;
  final bool useGyroscope;

  // Keyboard
  final KeyboardLanguage keyboardLanguage;
  final bool mustClearInputField;
  final bool useAdvancedKeyboard;
  final bool useAdvancedKeyboardIntegrated;

  // Remote
  final RemoteNavigationEntity remoteNavigationEntity;
  final bool useMinimalistRemote;
  final bool useEnterForSelection;

  const RemoteSettings({
    this.mouseSpeed = 1.0,
    this.shouldInvertMouseScrollingDirection = false,
    this.useGyroscope = false,
    this.keyboardLanguage = KeyboardLanguage.english,
    this.mustClearInputField = false,
    this.useAdvancedKeyboard = false,
    this.useAdvancedKeyboardIntegrated = false,
    this.remoteNavigationEntity = RemoteNavigationEntity.dPad,
    this.useMinimalistRemote = false,
    this.useEnterForSelection = false,
  });

  RemoteSettings copyWith({
    double? mouseSpeed,
    bool? shouldInvertMouseScrollingDirection,
    bool? useGyroscope,
    KeyboardLanguage? keyboardLanguage,
    bool? mustClearInputField,
    bool? useAdvancedKeyboard,
    bool? useAdvancedKeyboardIntegrated,
    RemoteNavigationEntity? remoteNavigationEntity,
    bool? useMinimalistRemote,
    bool? useEnterForSelection,
  }) {
    return RemoteSettings(
      mouseSpeed: mouseSpeed ?? this.mouseSpeed,
      shouldInvertMouseScrollingDirection:
          shouldInvertMouseScrollingDirection ??
          this.shouldInvertMouseScrollingDirection,
      useGyroscope: useGyroscope ?? this.useGyroscope,
      keyboardLanguage: keyboardLanguage ?? this.keyboardLanguage,
      mustClearInputField: mustClearInputField ?? this.mustClearInputField,
      useAdvancedKeyboard: useAdvancedKeyboard ?? this.useAdvancedKeyboard,
      useAdvancedKeyboardIntegrated:
          useAdvancedKeyboardIntegrated ?? this.useAdvancedKeyboardIntegrated,
      remoteNavigationEntity:
          remoteNavigationEntity ?? this.remoteNavigationEntity,
      useMinimalistRemote: useMinimalistRemote ?? this.useMinimalistRemote,
      useEnterForSelection: useEnterForSelection ?? this.useEnterForSelection,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mouseSpeed': mouseSpeed,
      'shouldInvertMouseScrollingDirection': shouldInvertMouseScrollingDirection,
      'useGyroscope': useGyroscope,
      'keyboardLanguage': keyboardLanguage.name,
      'mustClearInputField': mustClearInputField,
      'useAdvancedKeyboard': useAdvancedKeyboard,
      'useAdvancedKeyboardIntegrated': useAdvancedKeyboardIntegrated,
      'remoteNavigationEntity': remoteNavigationEntity.name,
      'useMinimalistRemote': useMinimalistRemote,
      'useEnterForSelection': useEnterForSelection,
    };
  }

  factory RemoteSettings.fromJson(Map<String, dynamic> json) {
    return RemoteSettings(
      mouseSpeed: (json['mouseSpeed'] as num?)?.toDouble() ?? 1.0,
      shouldInvertMouseScrollingDirection:
          json['shouldInvertMouseScrollingDirection'] as bool? ?? false,
      useGyroscope: json['useGyroscope'] as bool? ?? false,
      keyboardLanguage: KeyboardLanguage.values.firstWhere(
        (e) => e.name == json['keyboardLanguage'],
        orElse: () => KeyboardLanguage.english,
      ),
      mustClearInputField: json['mustClearInputField'] as bool? ?? false,
      useAdvancedKeyboard: json['useAdvancedKeyboard'] as bool? ?? false,
      useAdvancedKeyboardIntegrated:
          json['useAdvancedKeyboardIntegrated'] as bool? ?? false,
      remoteNavigationEntity: RemoteNavigationEntity.values.firstWhere(
        (e) => e.name == json['remoteNavigationEntity'],
        orElse: () => RemoteNavigationEntity.dPad,
      ),
      useMinimalistRemote: json['useMinimalistRemote'] as bool? ?? false,
      useEnterForSelection: json['useEnterForSelection'] as bool? ?? false,
    );
  }
}

