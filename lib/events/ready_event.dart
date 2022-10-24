import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/handlers/covid19_handler.dart';
import 'package:rpmtw_discord_bot/handlers/music_handler.dart';
import 'package:rpmtw_discord_bot/handlers/universe_handler.dart';
import 'package:rpmtw_discord_bot/util/data.dart';

class ReadyEvent implements BaseEvent<IReadyEvent> {
  @override
  Future<void> handler(client, event) async {
    await DataUtil.initOnReady(client);
    await MusicHandler.init();
    Covid19Handler.timer();
    await UniverseChatHandler.init(client);
    logger.info('${client.self.tag} Ready!');
  }
}
