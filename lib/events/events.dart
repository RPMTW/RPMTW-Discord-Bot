import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/message_create_event.dart';
import 'package:rpmtw_discord_bot/events/message_delete_event.dart';
import 'package:rpmtw_discord_bot/events/message_update_event.dart';
import 'package:rpmtw_discord_bot/events/ready_event.dart';
// import 'package:rpmtw_discord_bot/events/voice_state_update_event.dart';

class Events {
  static register(INyxxWebsocket client) {
    client.eventsWs.onReady
        .listen((event) => ReadyEvent().handler(client, event));
    client.eventsWs.onMessageReceived
        .listen((event) => MessageCreateEvent().handler(client, event));
    client.eventsWs.onMessageDelete
        .listen((event) => MessageDeleteEvent().handler(client, event));
    client.eventsWs.onMessageUpdate
        .listen((event) => MessageUpdateEvent().handler(client, event));

    /// 尚未完成動態語音
    // client.eventsWs.onVoiceStateUpdate
    //     .listen((event) => VoiceStateUpdateEvent().handler(client, event));
  }
}
