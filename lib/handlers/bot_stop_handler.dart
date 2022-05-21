import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:nyxx/nyxx.dart';
// ignore: depend_on_referenced_packages
import 'package:logging/logging.dart';
import 'package:rpmtw_discord_bot/handlers/music_handler.dart';

class BotStopHandler extends BasePlugin {
  @override
  FutureOr<void> onRegister(INyxx nyxx, Logger logger) async {
    if (!Platform.isWindows) {
      ProcessSignal.sigterm.watch().forEach((event) async {
        await _dispose(logger);
      });
    }

    ProcessSignal.sigint.watch().forEach((event) async {
      await _dispose(logger);
    });
  }

  Future<void> _dispose(Logger logger) async {
    logger.info('Closing database...');
    await Hive.close();

    logger.info('Stopping lavalink...');
    await MusicHandler.leave();
    MusicHandler.disconnect();
    logger.info('Stopped lavalink.');
  }
}
