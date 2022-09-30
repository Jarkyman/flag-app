import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:get/get.dart';

class SoundController extends GetxController implements GetxService {
  Soundpool? pool;
  int? _clickId;
  int? _completeId;
  int? _correctId;
  int? _disabledId;
  int? _wrongId;
  int? _windId;
  bool _soundOn = true;

  bool get getSoundOn => _soundOn;

  SoundController() {
    init();
  }

  Future init() async {
    pool = Soundpool.fromOptions();
    _clickId = await rootBundle
        .load('assets/sound/click.mp3')
        .then((ByteData soundData) {
      return pool!.load(soundData);
    });
    _completeId = await rootBundle
        .load('assets/sound/complete.mp3')
        .then((ByteData soundData) {
      return pool!.load(soundData);
    });
    _correctId = await rootBundle
        .load('assets/sound/correct.mp3')
        .then((ByteData soundData) {
      return pool!.load(soundData);
    });
    _disabledId = await rootBundle
        .load('assets/sound/disabled.mp3')
        .then((ByteData soundData) {
      return pool!.load(soundData);
    });
    _wrongId = await rootBundle
        .load('assets/sound/wrong.mp3')
        .then((ByteData soundData) {
      return pool!.load(soundData);
    });
    _windId = await rootBundle
        .load('assets/sound/wind.mp3')
        .then((ByteData soundData) {
      return pool!.load(soundData);
    });
  }

  clickSound() {
    if (_soundOn) {
      pool!.play(_clickId!);
    }
  }

  completeSound() {
    if (_soundOn) {
      pool!.play(_completeId!);
    }
  }

  correctSound() {
    if (_soundOn) {
      pool!.play(_correctId!);
    }
  }

  disabledSound() {
    if (_soundOn) {
      pool!.play(_disabledId!);
    }
  }

  wrongSound() {
    if (_soundOn) {
      pool!.play(_wrongId!);
    }
  }

  windSound() {
    if (_soundOn) {
      pool!.play(_windId!);
    }
  }
}
