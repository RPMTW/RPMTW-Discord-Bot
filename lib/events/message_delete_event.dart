import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/changelog.dart';

class MessageDeleteEvent implements BaseEvent<IMessageDeleteEvent> {
  @override
  Future<void> handler(client, event) async {
    if (event.message != null && event.message!.content != "null") {
     await Changelog(client).deleted(event.message!);
    }
  }
}
