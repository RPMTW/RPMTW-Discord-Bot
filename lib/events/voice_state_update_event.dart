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
          final ChannelBuilder newVoiceChannel =
              _VoiceChannelBuilder.create('${user.username}的頻道',
                  permissionOverwrites: [
                    PermissionOverrideBuilder(1, user.id)
                      ..manageRoles = true
                      ..manageChannels = true
                  ],
                  parent: categoryID);

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

class _VoiceChannelBuilder extends VoiceChannelBuilder {
  String name;

  /// category id
  Snowflake? parent;

  List<PermissionOverrideBuilder>? permissionOverwrites;

  _VoiceChannelBuilder(this.name, {this.parent, this.permissionOverwrites}) {
    type = ChannelType.voice;
  }

  _VoiceChannelBuilder.create(
    String name, {
    Snowflake? parent,
    List<PermissionOverrideBuilder>? permissionOverwrites,
  }) : this(name, parent: parent, permissionOverwrites: permissionOverwrites);

  @override
  RawApiMap build() => {
        ...super.build(),
        'name': name,
        if (permissionOverwrites != null)
          'permission_overwrites':
              permissionOverwrites!.map((e) => e.build()).toList(),
        if (parent != null) 'parent_id': parent!.id.toString(),
        if (bitrate != null) 'bitrate': bitrate,
        if (userLimit != null) 'user_limit': userLimit,
        if (rateLimitPerUser != null) 'rate_limit_per_user': rateLimitPerUser,
        if (rtcRegion != '') 'rtc_region': rtcRegion,
      };
}
