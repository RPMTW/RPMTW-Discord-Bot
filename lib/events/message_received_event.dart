import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';
import 'package:rpmtw_discord_bot/utilities/fraud_detection.dart';

class MessageReceivedEvent implements BaseEvent<IMessageReceivedEvent> {
  @override
  Future<void> handler(client, event) async {
    try {
      IMessage message = event.message;
      await FraudDetection.detection(client, message);
    } catch (error, stackTrace) {
      logger.error(error: error, stackTrace: stackTrace);
    }
  }
}
