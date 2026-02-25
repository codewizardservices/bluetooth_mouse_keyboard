import '../control/mini_keycap_data.dart';

/// Layout modeled after the reference mini-keyboard photo.
///
/// Notes:
/// - Uses 4 rows.
/// - Back and Enter are wide "pill" keys on rows 2 and 3.
/// - The bottom row includes the special keys + the "www\.com" key.
class MiniKeyboardLayout {
  static const row1 = <MiniKeycapData>[
    MiniKeycapData('Esc', secondary: '↩', style: KeycapStyle.round),
    MiniKeycapData('Q', secondary: '•', style: KeycapStyle.round),
    MiniKeycapData('W', secondary: '1', style: KeycapStyle.round),
    MiniKeycapData('E', secondary: '2', style: KeycapStyle.round),
    MiniKeycapData('R', secondary: '3', style: KeycapStyle.round),
    MiniKeycapData('T', secondary: '4', style: KeycapStyle.round),
    MiniKeycapData('Y', secondary: '5', style: KeycapStyle.round),
    MiniKeycapData('U', secondary: '6', style: KeycapStyle.round),
    MiniKeycapData('I', secondary: '7', style: KeycapStyle.round),
    MiniKeycapData('O', secondary: '8', style: KeycapStyle.round),
    MiniKeycapData('P', secondary: '9', style: KeycapStyle.round),
    MiniKeycapData('0', secondary: '', style: KeycapStyle.round),
    MiniKeycapData('Del', secondary: '', style: KeycapStyle.round),
  ];

  static const row2 = <MiniKeycapData>[
    MiniKeycapData('Caps', secondary: '~', style: KeycapStyle.round),
    MiniKeycapData('A', secondary: '!', style: KeycapStyle.round),
    MiniKeycapData('S', secondary: '@', style: KeycapStyle.round),
    MiniKeycapData('D', secondary: '#', style: KeycapStyle.round),
    MiniKeycapData('F', secondary: r'$', style: KeycapStyle.round),
    MiniKeycapData('G', secondary: '%', style: KeycapStyle.round),
    MiniKeycapData('H', secondary: '^', style: KeycapStyle.round),
    MiniKeycapData('J', secondary: '&', style: KeycapStyle.round),
    MiniKeycapData('K', secondary: '*', style: KeycapStyle.round),
    MiniKeycapData('L', secondary: '(', style: KeycapStyle.round),
    MiniKeycapData(')', secondary: '', style: KeycapStyle.round),
    MiniKeycapData(
      'BACK',
      secondary: '←',
      style: KeycapStyle.longPill,
      flex: 2,
    ),
  ];

  static const row3 = <MiniKeycapData>[
    MiniKeycapData('Shift', secondary: r'\', style: KeycapStyle.round),
    MiniKeycapData('Z', secondary: '<', style: KeycapStyle.round),
    MiniKeycapData('X', secondary: '>', style: KeycapStyle.round),
    MiniKeycapData('C', secondary: '·', style: KeycapStyle.round),
    MiniKeycapData('V', secondary: '"', style: KeycapStyle.round),
    MiniKeycapData('B', secondary: ':', style: KeycapStyle.round),
    MiniKeycapData('N', secondary: ';', style: KeycapStyle.round),
    MiniKeycapData('M', secondary: ',', style: KeycapStyle.round),
    MiniKeycapData('?', secondary: '.', style: KeycapStyle.round),
    MiniKeycapData('PgUp', secondary: '▲', style: KeycapStyle.round),
    MiniKeycapData(
      'Enter',
      secondary: 'CTRL+ALT+DEL',
      style: KeycapStyle.longPill,
      flex: 2,
    ),
  ];

  static const row4 = <MiniKeycapData>[
    MiniKeycapData('Ctrl', secondary: ';', style: KeycapStyle.round),
    MiniKeycapData('Fn', secondary: '', style: KeycapStyle.round),
    MiniKeycapData('-', secondary: '_', style: KeycapStyle.round),
    MiniKeycapData('+', secondary: '=', style: KeycapStyle.round),
    MiniKeycapData('Alt', secondary: '{', style: KeycapStyle.round),
    MiniKeycapData('␣', secondary: '', style: KeycapStyle.longPill, flex: 2),
    MiniKeycapData('AltGr', secondary: '}', style: KeycapStyle.round),
    MiniKeycapData('Home', secondary: '◀', style: KeycapStyle.round),
    MiniKeycapData('PgDn', secondary: '▼', style: KeycapStyle.round),
    MiniKeycapData('End', secondary: '▶', style: KeycapStyle.round),
    MiniKeycapData('www\n.com', secondary: '', style: KeycapStyle.round),
  ];
}
