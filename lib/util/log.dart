import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';

class BotLogger {
  final ITextChannel channel;

  const BotLogger(this.channel);

  Future<void> info(String message) async {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Info';
    embed.description = message;
    embed.color = DiscordColor.green;
    embed.timestamp = RPMTWUtil.getUTCTime();
    RPMTWLogger.info(message);
    try {
      await channel.sendMessage(MessageBuilder.embed(embed));
    } catch (e, stackTrace) {
      RPMTWLogger.error('Failed to send info message to discord',
          error: e, stackTrace: stackTrace);
    }
  }

  // Send warning message to discord channel and print to console
  Future<void> warn(String message) async {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Warning';
    embed.description = message;
    embed.color = DiscordColor.yellow;
    embed.timestamp = RPMTWUtil.getUTCTime();
    RPMTWLogger.warning(message);
    try {
      await channel.sendMessage(MessageBuilder.embed(embed));
    } catch (e, stackTrace) {
      RPMTWLogger.warning('Failed to send warning message to discord\n$e',
          stackTrace: stackTrace);
    }
  }

  Future<void> error(
      {required Object error, required StackTrace stackTrace}) async {
    EmbedBuilder embed = EmbedBuilder();
    embed.title = 'Error';
    embed.description = error.toString();
    if (!stackTrace.toString().isAllEmpty) {
      embed.addField(name: 'Stack Trace', content: stackTrace.toString());
    }
    embed.color = DiscordColor.red;
    embed.timestamp = RPMTWUtil.getUTCTime();

    RPMTWLogger.error(error.toString(), stackTrace: stackTrace);
    try {
      await channel.sendMessage(MessageBuilder.embed(embed));
    } catch (e, stackTrace) {
      RPMTWLogger.warning('Failed to send error message to discord\n$e',
          stackTrace: stackTrace);
    }
  }
}
