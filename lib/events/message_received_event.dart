import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';
import 'package:rpmtw_discord_bot/handlers/scam_detection.dart';

class MessageReceivedEvent implements BaseEvent<IMessageReceivedEvent> {
  @override
  Future<void> handler(client, event) async {
    try {
      IMessage message = event.message;
      IGuild? guild = await message.guild?.getOrDownload();
      if (guild == null) return;
      await ScamDetection.detectionForDiscord(client, message);
      await _nsfwHandler(guild, message);
    } catch (error, stackTrace) {
      logger.error(error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _nsfwHandler(IGuild guild, IMessage message) async {
    Snowflake nsfwChannelID = 940533694697975849.toSnowflake();
    SnowflakeEntity nsfwRoleID = 945632168124751882.toSnowflakeEntity();

    if (message.channel.id == nsfwChannelID) {
      IMessageAuthor author = message.author;
      IMember member = await guild.fetchMember(author.id);

      // check if the member already has the role
      bool added = member.roles.any((r) => r.id == nsfwRoleID.id);
      if (!added) {
        // add "約瑟教" role
        await member.addRole(nsfwRoleID);
        String prefix = "約瑟．";
        String name = member.nickname ?? author.username;
        if (!name.contains(prefix)) {
          await member.edit(builder: MemberBuilder()..nick = prefix + name);
        }
      }
    }
  }
}
