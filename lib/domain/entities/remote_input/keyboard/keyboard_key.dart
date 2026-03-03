class KeyboardKey {
  final int byte;
  final String label;

  const KeyboardKey(this.byte, this.label);

  static const KeyboardKey keyEnter = KeyboardKey(0x28, 'Enter');
  static const KeyboardKey keySpace = KeyboardKey(0x2C, 'Space');
  static const KeyboardKey keyBackspace = KeyboardKey(0x2A, 'Backspace');
  static const KeyboardKey keyTab = KeyboardKey(0x2B, 'Tab');
  static const KeyboardKey keyEscape = KeyboardKey(0x29, 'Esc');
  static const KeyboardKey keyDelete = KeyboardKey(0x4C, 'Delete');
  static const KeyboardKey keyShift = KeyboardKey(0xE1, 'Shift');
  static const KeyboardKey keyCtrl = KeyboardKey(0xE0, 'Ctrl');
  static const KeyboardKey keyAlt = KeyboardKey(0xE2, 'Alt');
  static const KeyboardKey keyCapsLock = KeyboardKey(0x39, 'Caps');
  
  // Numbers
  static const KeyboardKey key1 = KeyboardKey(0x1E, '1');
  static const KeyboardKey key2 = KeyboardKey(0x1F, '2');
  static const KeyboardKey key3 = KeyboardKey(0x20, '3');
  static const KeyboardKey key4 = KeyboardKey(0x21, '4');
  static const KeyboardKey key5 = KeyboardKey(0x22, '5');
  static const KeyboardKey key6 = KeyboardKey(0x23, '6');
  static const KeyboardKey key7 = KeyboardKey(0x24, '7');
  static const KeyboardKey key8 = KeyboardKey(0x25, '8');
  static const KeyboardKey key9 = KeyboardKey(0x26, '9');
  static const KeyboardKey key0 = KeyboardKey(0x27, '0');
}

int digitToKeyCode(int digit) {
  switch (digit) {
    case 1: return 0x1E;
    case 2: return 0x1F;
    case 3: return 0x20;
    case 4: return 0x21;
    case 5: return 0x22;
    case 6: return 0x23;
    case 7: return 0x24;
    case 8: return 0x25;
    case 9: return 0x26;
    case 0: return 0x27;
    default: throw ArgumentError('digit must be 0..9');
  }
}




class HidKey {
  final int modifier; // e.g. shift
  final int keycode;  // HID usage ID
  const HidKey(this.modifier, this.keycode);
}

class HidKeyMapper {
  static const int modNone = 0x00;
  static const int modShift = 0x02;

  static HidKey? fromLabel(String label) {
    // Special labels from your keyboard
    switch (label) {
      case 'SPACE':
      case ' ':
        return const HidKey(modNone, 0x2C);
      case 'ENTER':
        return const HidKey(modNone, 0x28);
      case 'BACKSPACE':
        return const HidKey(modNone, 0x2A);
      default:
        break;
    }

    if (label.isEmpty) return null;

    // Single character keys from your rows ("a", "A", "1", "@", etc.)
    if (label.length == 1) {
      final ch = label.codeUnitAt(0);

      // a-z
      if (ch >= 97 && ch <= 122) {
        return HidKey(modNone, 0x04 + (ch - 97));
      }

      // A-Z (shift + same keycode)
      if (ch >= 65 && ch <= 90) {
        return HidKey(modShift, 0x04 + (ch - 65));
      }

      // 1-9
      if (ch >= 49 && ch <= 57) {
        return HidKey(modNone, 0x1E + (ch - 49));
      }

      // 0
      if (ch == 48) {
        return const HidKey(modNone, 0x27);
      }

      // Minimal punctuation support (US layout assumptions)
      switch (label) {
        case '.':
          return const HidKey(modNone, 0x37);
        case ',':
          return const HidKey(modNone, 0x36);
        case '-':
          return const HidKey(modNone, 0x2D);
        case '_':
          return const HidKey(modShift, 0x2D);
        case '/':
          return const HidKey(modNone, 0x38);
        case '?':
          return const HidKey(modShift, 0x38);
        case '\'':
          return const HidKey(modNone, 0x34);
        case '"':
          return const HidKey(modShift, 0x34);
        case ';':
          return const HidKey(modNone, 0x33);
        case ':':
          return const HidKey(modShift, 0x33);
        case '=':
          return const HidKey(modNone, 0x2E);
        case '+':
          return const HidKey(modShift, 0x2E);
        case '!':
          return const HidKey(modShift, 0x1E); // Shift+1
        case '@':
          return const HidKey(modShift, 0x1F); // Shift+2
        case '#':
          return const HidKey(modShift, 0x20); // Shift+3
        case r'$':
          return const HidKey(modShift, 0x21); // Shift+4
        case '%':
          return const HidKey(modShift, 0x22); // Shift+5
        case '^':
          return const HidKey(modShift, 0x23); // Shift+6
        case '&':
          return const HidKey(modShift, 0x24); // Shift+7
        case '*':
          return const HidKey(modShift, 0x25); // Shift+8
        case '(':
          return const HidKey(modShift, 0x26); // Shift+9
        case ')':
          return const HidKey(modShift, 0x27); // Shift+0
        default:
          return null;
      }
    }

    return null;
  }
}
