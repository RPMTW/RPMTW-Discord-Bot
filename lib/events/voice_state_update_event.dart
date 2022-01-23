import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class VoiceStateUpdateEvent implements BaseEvent<IVoiceStateUpdateEvent> {
  List<Snowflake> _joinedUsers = [];

  @override
  Future<void> handler(client, event) async {
    IVoiceState state = event.state;
    IChannel? channel = await state.channel?.getOrDownload();
    IGuild? guild = await state.guild?.getOrDownload();
    final Snowflake categoryID = 815819581440262145.toSnowflake();

    if (channel != null && guild != null && channel is IVoiceGuildChannel) {
      final IUser user = await state.user.getOrDownload();
      if (channel.id == voiceChannelID) {
        print("test1");

        final ChannelBuilder newVoiceChannel =
            _VoiceChannelBuilder.create("${user.username} 的頻道",
                permissionOverwrites: [
                  {"id": user.id.toString(), "allow": 871368465}
                ],
                parent: categoryID);

        final IVoiceGuildChannel guildChannel =
            await guild.createChannel(newVoiceChannel) as IVoiceGuildChannel;

        await guildChannel.editChannelPermissionOverrides(
            PermissionOverrideBuilder(1, user.id)..manageRoles = true);

        IInvite invite = await guildChannel.createInvite();

        await user.sendMessage(MessageBuilder.content(
            "<@${user.id}> 您好，請點選下方按鈕來加入您剛才建立的頻道 ${invite.url}"));

        logger.info("成功建立 <@${user.id}> 的動態語音頻道 (<#${guildChannel.id}>)");
      } else if (channel.parentChannel?.getFromCache()?.id == categoryID) {
        /// 如果該頻道內有管理權限的人退出頻道了，則將語音頻道刪除
        print("test2");

        if (_joinedUsers.contains(user.id) &&
            channel.permissionOverrides.any((permission) =>
                permission.id == user.id &&
                permission.permissions.hasPermission(
                    PermissionsConstants.manageRolesOrPermissions))) {
          _joinedUsers.remove(user.id);
          await channel.delete();
        } else {
          _joinedUsers.add(user.id);
        }
      }
    }
  }
}

class _VoiceChannelBuilder extends VoiceChannelBuilder {
  String name;

  /// category id
  Snowflake? parent;

  _VoiceChannelBuilder(this.name, {this.parent}) {
    type = ChannelType.voice;
  }

  _VoiceChannelBuilder.create(
    String name, {
    Snowflake? parent,
    List<Map>? permissionOverwrites,
  }) : this(name, parent: parent);

  @override
  RawApiMap build() => {
        ...super.build(),
        "name": name,
        if (parent != null) "parent_id": parent!.id.toString(),
        if (bitrate != null) "bitrate": bitrate,
        if (userLimit != null) "user_limit": userLimit,
        if (rateLimitPerUser != null) "rate_limit_per_user": rateLimitPerUser,
        if (rtcRegion != "") "rtc_region": rtcRegion,
      };
}
