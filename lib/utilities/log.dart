import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class Logger {
  final INyxxWebsocket client;
  ITextChannel? channel;

  Logger(this.client);

  Future<void> init() async {
    channel = await client.fetchChannel<ITextChannel>(logChannelID);
  }

  Future<void> info(String message) async {
    if (channel == null) {
      await init();
    }
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Info';
    embed.description = message;
    embed.color = DiscordColor.green;
    embed.timestamp = DateTime.now();
    print("[${DateTime.now()}] [INFO] $message");
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
    print(
        "[${DateTime.now()}] [Error] ${error.toString()}\n${stackTrace.toString()}");
    await channel?.sendMessage(MessageBuilder.embed(embed));
  }
}
