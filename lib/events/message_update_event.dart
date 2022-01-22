import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/utilities/changelog.dart';

class MessageUpdateEvent {
  static void handler({required IMessageUpdateEvent event}) {
    if (event.updatedMessage != null && event.updatedMessage?.content != null) {
      Changelog.edit(event.updatedMessage!);
    }
  }
}
