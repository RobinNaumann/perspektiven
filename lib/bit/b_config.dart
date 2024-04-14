import 'dart:ui';

import 'package:elbe/bit/bit/bit_control.dart';
import 'package:elbe/util/m_data.dart';
import 'package:flutter/scheduler.dart';

class Config extends DataModel {
  final bool dark;

  Config({required this.dark});

  @override
  get map => {"dark": dark};
}

class ConfigBit extends MapMsgBitControl<Config> {
  static const builder = MapMsgBitBuilder<Config, ConfigBit>.make;

  ConfigBit()
      : super.worker((_) async {
          final brightness =
              SchedulerBinding.instance.platformDispatcher.platformBrightness;
          return Config(dark: brightness == Brightness.dark);
        });
}
