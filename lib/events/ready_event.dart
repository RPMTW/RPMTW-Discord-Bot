import 'dart:async';

import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class ReadyEvent implements BaseEvent<IReadyEvent> {
  @override
  Future<void> handler(client, event) async {
    // client.shardManager.rawEvent.listen((_event) {
    //   print("Raw event: ${_event.rawData}");
    // });

    await Data.initOnReady(client);
    logger.info('${client.self.tag} Ready!');
  }
}
