import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/changelog.dart';

class MessageUpdateEvent implements BaseEvent<IMessageUpdateEvent> {
  @override
  Future<void> handler(client, event) async {
    if (event.updatedMessage != null && event.updatedMessage?.content != null) {
      await Changelog(client).edit(event.updatedMessage!);
    }
  }
}
