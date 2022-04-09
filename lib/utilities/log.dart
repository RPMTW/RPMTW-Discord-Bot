import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/utilities/util.dart';

class Logger {
  final ITextChannel channel;

  Logger(this.channel);

  Future<void> info(String message) async {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Info';
    embed.description = message;
    embed.color = DiscordColor.green;
    embed.timestamp = Util.getUTCTime();
    print('[${Util.getUTCTime()}] [INFO] $message');
    try {
      await channel.sendMessage(MessageBuilder.embed(embed));
    } catch (e) {
      print(
          '[${Util.getUTCTime()}] [Error] Failed to send info message to discord\n${e.toString()}');
    }
  }

  Future<void> error(
      {required Object error, required StackTrace stackTrace}) async {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Error';
    embed.description = error.toString();
    embed.color = DiscordColor.red;
    embed.timestamp = Util.getUTCTime();
    print(
        '[${Util.getUTCTime()}] [Error] ${error.toString()}\n${stackTrace.toString()}');
    try {
      await channel.sendMessage(MessageBuilder.embed(embed));
    } catch (e) {
      print(
          '[${Util.getUTCTime()}] [Error] Failed to send error message to discord\n${e.toString()}');
    }
  }
}
