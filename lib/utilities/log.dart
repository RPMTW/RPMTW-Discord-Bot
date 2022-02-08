import 'package:nyxx/nyxx.dart';

class Logger {
  final INyxxWebsocket client;
  final ITextChannel channel;

  Logger(this.client, this.channel);
  
  Future<void> info(String message) async {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Info';
    embed.description = message;
    embed.color = DiscordColor.green;
    embed.timestamp = DateTime.now();
    print("[${DateTime.now()}] [INFO] $message");
    try {
      await channel.sendMessage(MessageBuilder.embed(embed));
    } catch (e) {
      print(
          "[${DateTime.now()}] [Error] Failed to send info message to discord\n${e.toString()}");
    }
  }

  Future<void> error(
      {required Object error, required StackTrace stackTrace}) async {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Error';
    embed.description = error.toString();
    embed.color = DiscordColor.red;
    embed.timestamp = DateTime.now();
    print(
        "[${DateTime.now()}] [Error] ${error.toString()}\n${stackTrace.toString()}");
    try {
      await channel.sendMessage(MessageBuilder.embed(embed));
    } catch (e) {
      print(
          "[${DateTime.now()}] [Error] Failed to send error message to discord\n${e.toString()}");
    }
  }
}
