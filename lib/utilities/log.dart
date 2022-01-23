import 'package:logger/logger.dart' as logger;
import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class Logger {
  final INyxxWebsocket client;
  late final logger.Logger _loggerNoStack;
  late final logger.Logger _loggerStack;
  ITextChannel? channel;

  Logger(this.client);

  Future<void> init() async {
    channel = await client.fetchChannel<ITextChannel>(logChannelID);
    _loggerNoStack = logger.Logger(
      printer: logger.PrettyPrinter(methodCount: 0, colors: false),
    );
    _loggerStack = logger.Logger();
  }

  Future<void> info(String message) async {
    if (channel == null) {
      await init();
    }
    _loggerNoStack.i(message);
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Info';
    embed.description = message;
    embed.color = DiscordColor.green;
    embed.timestamp = DateTime.now();
    await channel?.sendMessage(MessageBuilder.embed(embed));
  }

  Future<void> error(
      {required Object error, required StackTrace stackTrace}) async {
    if (channel == null) {
      await init();
    }
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Error';
    embed.description = error.toString();
    embed.color = DiscordColor.red;
    embed.timestamp = DateTime.now();
    _loggerStack.e(error, null, stackTrace);
    await channel?.sendMessage(MessageBuilder.embed(embed));
  }
}
