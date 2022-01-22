import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/message_create_event.dart';
import 'package:rpmtw_discord_bot/events/message_delete_event.dart';
import 'package:rpmtw_discord_bot/events/message_update_event.dart';

class Events {
  static register(INyxxWebsocket client) {
    client.eventsWs.onReady.listen((e) {
      print("Ready!");
      client.shardManager.rawEvent.listen((event) {
        print("Raw event: ${event.rawData}");
      });
    });
    client.eventsWs.onMessageReceived
        .listen((event) => MessageCreateEvent.handler(event));
    client.eventsWs.onMessageDelete
        .listen((event) => MessageDeleteEvent.handler(event: event));
    client.eventsWs.onMessageUpdate
        .listen((event) => MessageUpdateEvent.handler(event: event));
  }
}
