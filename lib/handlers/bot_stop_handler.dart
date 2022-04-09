import 'dart:async';

import 'package:hive/hive.dart';
import 'package:nyxx/nyxx.dart';
import 'package:logging/logging.dart';

class BotStopHandler extends BasePlugin {
  @override
  FutureOr<void> onBotStop(INyxx nyxx, Logger logger) async {
    logger.info('Closing database...');
    await Hive.close();
  }
}
