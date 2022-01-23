import 'package:logger/logger.dart' as logger;
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class Logger {
  final INyxxWebsocket client;
  late final logger.Logger loggerNoStack;
  ITextChannel? channel;

  Logger(this.client);

  Future<void> init() async {
    channel = await client.fetchChannel<ITextChannel>(logChannelID);
    loggerNoStack = logger.Logger(
      printer: logger.PrettyPrinter(methodCount: 0, colors: false),
    );
  }

  Future<void> info(String message) async {
    if (channel == null) {
      await init();
    }
    String logMessage = '${DateTime.now()} [**INFO**] - $message';
    loggerNoStack.i(message);
    await channel?.sendMessage(MessageBuilder.content(logMessage));
  }
}
