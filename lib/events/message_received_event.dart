import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/handlers/universe_handler.dart';
import 'package:rpmtw_discord_bot/util/data.dart';
import 'package:rpmtw_discord_bot/handlers/scam_detection.dart';

class MessageReceivedEvent implements BaseEvent<IMessageReceivedEvent> {
  @override
  Future<void> handler(client, event) async {
    try {
      final IMessage message = event.message;
      final IGuild? guild = await message.guild?.getOrDownload();
      final ITextChannel channel = await message.channel.getOrDownload();
      if (guild == null || channel is! ITextGuildChannel) return;

      await ScamDetection.detectionForDiscord(client, message);

      final channelId = message.channel.id.id;

      switch (channelId) {
        case 940533694697975849:
          await _nsfwChannelHandler(guild, message);
          break;
        case 1033586182254231592:
          await UniverseChatHandler.onDiscordMessage(guild, message);
          break;
        default:
      }
    } catch (error, stackTrace) {
      logger.error(error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _nsfwChannelHandler(IGuild guild, IMessage message) async {
    final SnowflakeEntity nsfwRoleID = 945632168124751882.toSnowflakeEntity();

    final IMessageAuthor author = message.author;
    final IMember member = await guild.fetchMember(author.id);

    // check if the member already has the role
    final bool added = member.roles.any((r) => r.id == nsfwRoleID.id);
    if (!added) {
      // add '約瑟教' role
      await member.addRole(nsfwRoleID);
      final String prefix = '約瑟．';
      final String name = member.nickname ?? author.username;
      if (!name.contains(prefix)) {
        await member.edit(builder: MemberBuilder()..nick = prefix + name);
      }
    }
  }
}
