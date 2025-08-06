import 'package:flag_app/repos/settings_repo.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundController extends GetxController implements GetxService {
  final SettingsRepo settingsRepo;
  late bool _soundOn;
  final AudioPlayer _player = AudioPlayer();
  bool get getSoundOn => _soundOn;

  SoundController({required this.settingsRepo}) {
    init();
  }

  Future<void> init() async {
    await soundSettingRead();
  }

  Future<void> soundSettingRead() async {
    _soundOn = await settingsRepo.soundSettingRead();
    update();
  }

  Future<void> soundSettingsSave(bool sound) async {
    _soundOn = sound;
    settingsRepo.soundSettingsSave(sound);
    update();
  }

  Future<void> _play(String fileName) async {
    if (_soundOn) {
      await _player.play(AssetSource('sound/$fileName'));
    }
  }

  void clickSound() => _play('click.mp3');
  void completeSound() => _play('complete.mp3');
  void correctSound() => _play('correct.mp3');
  void disabledSound() => _play('disabled.mp3');
  void wrongSound() => _play('wrong.mp3');
  void windSound() => _play('wind.mp3');
}
