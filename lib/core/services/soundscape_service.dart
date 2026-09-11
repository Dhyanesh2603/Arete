import '../../domain/models/focus_session.dart';
import 'soundscape_service_stub.dart'
    if (dart.library.js_interop) 'soundscape_service_web.dart';

class SoundscapeService {
  static void playPreset(AcousticPreset preset) {
    if (preset == AcousticPreset.silent) {
      SoundscapePlatformService.stop();
    } else {
      SoundscapePlatformService.play(preset.name);
    }
  }

  static void stop() {
    SoundscapePlatformService.stop();
  }

  static void setVolume(double volume) {
    SoundscapePlatformService.setVolume(volume);
  }
}
