// HID Consumer Page 0x0C - Remote Control Codes
// https://source.android.com/docs/core/interaction/input/keyboard-devices#hid-consumer-page-0x0c

class RemoteInput {
  // Navigation
  static final List<int> menu = [0x40, 0x00];
  static final List<int> select = [0x41, 0x00];
static final List<int> up = [0x42, 0x00];
static final List<int> down = [0x43, 0x00];
static final List<int> left = [0x44, 0x00];
static final List<int> right = [0x45, 0x00];


// Multimedia
  static final List<int> playPause = [0xCD, 0x00];
  static final List<int> previous = [0xB4, 0x00];
  static final List<int> next = [0xB3, 0x00];
  static final List<int> closedCaptions = [0x61, 0x00];
static final List<int> rewind = [0xB4, 0x00];      // Scan Previous Track (often treated as rewind)
static final List<int> forward = [0xB3, 0x00];     // Scan Next Track (often treated as forward)


  // Volume
  static final List<int> volumeUp = [0xE9, 0x00];
  static final List<int> volumeDown = [0xEA, 0x00];
  static final List<int> mute = [0xE2, 0x00];

  // Brightness
  static final List<int> brightnessUp = [0x6F, 0x00];
  static final List<int> brightnessDown = [0x70, 0x00];

  // Channel
  static final List<int> channelUp = [0x9C, 0x00];
  static final List<int> channelDown = [0x9D, 0x00];

  // Others
  static final List<int> home = [0x23, 0x02];
  static final List<int> back = [0x24, 0x02];
  static final List<int> power = [0x30, 0x00];

  static final List<int> none = [0x00, 0x00];


  static final List<int> leftClick = [0x01, 0, 0, 0];
  static final List<int> rightClick = [0x01, 0, 0, 0];
  static final List<int> releaseClick = [0x00, 0, 0, 0];
}

