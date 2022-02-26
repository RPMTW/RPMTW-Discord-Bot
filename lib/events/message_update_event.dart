import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/changelog.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';
import 'package:rpmtw_discord_bot/utilities/fraud_detection.dart';

class MessageUpdateEvent implements BaseEvent<IMessageUpdateEvent> {
  @override
  Future<void> handler(client, event) async {
    try {
      IMessage? updatedMessage = event.updatedMessage;
      if (updatedMessage != null) {
        // IMessage? oldMessage = updatedMessage.channel
        //     .getFromCache()!
        //     .messageCache[updatedMessage.id];

        if (updatedMessage.content != "null") {
          await ScamDetection.detectionWithBan(client, updatedMessage);
          await Changelog(client).edit(updatedMessage);
        }
      }
    } catch (error, stackTrace) {
      logger.error(error: error, stackTrace: stackTrace);
    }
  }
}
