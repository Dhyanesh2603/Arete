import 'dart:js_interop';

@JS('soundscapePlay')
external void _jsSoundscapePlay(JSString preset);

@JS('soundscapeStop')
external void _jsSoundscapeStop();

@JS('soundscapeSetVolume')
external void _jsSoundscapeSetVolume(JSNumber volume);

class SoundscapePlatformService {
  static void play(String preset) {
    try {
      _jsSoundscapePlay(preset.toJS);
    } catch (_) {}
  }

  static void stop() {
    try {
      _jsSoundscapeStop();
    } catch (_) {}
  }

  static void setVolume(double volume) {
    try {
      _jsSoundscapeSetVolume(volume.toJS);
    } catch (_) {}
  }
}
