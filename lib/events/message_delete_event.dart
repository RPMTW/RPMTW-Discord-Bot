import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/util/changelog.dart';
import 'package:rpmtw_discord_bot/util/data.dart';

class MessageDeleteEvent implements BaseEvent<IMessageDeleteEvent> {
  @override
  Future<void> handler(client, event) async {
    try {
      if (event.message != null && event.message!.content != 'null') {
        await Changelog(client).deleted(event.message!);
      }
    } catch (error, stackTrace) {
      logger.error(error: error, stackTrace: stackTrace);
    }
  }
}
