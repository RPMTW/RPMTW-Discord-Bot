import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

Map<Snowflake, IVoiceGuildChannel> _createdChannel = {};

class VoiceStateUpdateEvent implements BaseEvent<IVoiceStateUpdateEvent> {
  @override
  Future<void> handler(client, event) async {
    try {
      IVoiceState state = event.state;
      IChannel? channel = await state.channel?.getOrDownload();
      IGuild? guild = await state.guild?.getOrDownload();
      final Snowflake categoryID = 815819581440262145.toSnowflake();

      if (guild != null) {
        final IUser user = await state.user.getOrDownload();

        if (_createdChannel.containsKey(user.id) &&
            (channel == null || channel.id == voiceChannelID)) {
          final IVoiceGuildChannel guildChannel = _createdChannel[user.id]!;

          _createdChannel.remove(user.id);
          await guildChannel.delete();
        } else if (channel != null &&
            channel.id == voiceChannelID &&
            !user.bot) {
          final ChannelBuilder newVoiceChannel = VoiceChannelBuilder()
            ..name = '${user.username}的頻道'
            ..permissionOverrides = [
              PermissionOverrideBuilder.of(user)
                ..manageRoles = true
                ..manageChannels = true,
              PermissionOverrideBuilder.of(guild.everyoneRole)
                ..prioritySpeaker = true,
              PermissionOverrideBuilder.of(dcClient.self)
                ..prioritySpeaker = false
            ]
            ..parentChannel = categoryID.toSnowflakeEntity();

          final IVoiceGuildChannel guildChannel =
              await guild.createChannel(newVoiceChannel) as IVoiceGuildChannel;
          IMember member = await guild.fetchMember(user.id);
          await member.edit(
              builder: MemberBuilder()..channel = guildChannel.id);

          logger.info('成功建立 <@${user.id}> 的動態語音頻道 (<#${guildChannel.id}>)');
          _createdChannel[user.id] = guildChannel;
        }
      }
    } catch (e, stackTrace) {
      logger.error(error: e, stackTrace: stackTrace);
    }
  }
}
