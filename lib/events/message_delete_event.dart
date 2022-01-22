import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/utilities/changelog.dart';

class MessageDeleteEvent {
  static void handler({required IMessageDeleteEvent event}) {
    if (event.message != null) {
      Changelog.deleted(event.message!);
    }
  }
}
