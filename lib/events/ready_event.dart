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

    Timer.periodic(Duration(hours: 1), (timer) {
      client.channels.values.whereType<ITextChannel>().forEach((channel) async {
        Map<Snowflake, IMessage> cache =
            Map<Snowflake, IMessage>.from(channel.messageCache);
        List<IMessage> toDelete = [];
        cache.forEach((key, msg) {
          if (msg.createdAt
              .isBefore(DateTime.now().subtract(Duration(hours: 2)))) {
            /// Delete message cache if older than 2 hour
            toDelete.add(msg);
          }
        });
        await channel.bulkRemoveMessages(toDelete);
      });
    });
  }
}
