import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_discord_bot/util/data.dart';

class UniverseChatHandler {
  static late Map<String, Snowflake> emojiData;

  static Future<void> init(INyxxWebsocket client) async {
    final apiClient = RPMTWApiClient.instance;
    final channel = await client
        .fetchChannel<ITextGuildChannel>(1033586182254231592.toSnowflake());
    final webhook = await channel.getWebhooks().first;
    emojiData = await _getEmojiData();

    await apiClient.universeChatResource
        .connect(token: apiClient.apiGlobalToken);

    await _listenMessages(webhook, channel);
  }

  static Future<void> _listenMessages(
      IWebhook webhook, ITextGuildChannel channel) async {
    final api = RPMTWApiClient.instance.universeChatResource;

    api.onMessageSent.listen((message) async {
      try {
        if (message.userType == UniverseChatUserType.discord) return;

        final dataBox = DataUtil.universeChatBox;
        String content = message.message;

        // Is a reply message
        if (message.replyMessageUUID != null) {
          final replyMessage = await api.getMessage(message.replyMessageUUID!);

          late final int? dcMessageId;
          try {
            dcMessageId = int.tryParse(dataBox.keys.firstWhere((dcMessageId) =>
                dataBox.get(dcMessageId) == replyMessage.uuid));
          } catch (e) {
            dcMessageId = null;
          }

          if (dcMessageId != null) {
            final dcMessage =
                await channel.fetchMessage(dcMessageId.toSnowflake());

            if (dcMessage.isByWebhook) {
              // a Minecraft user is replying to a Minecraft user.

              content =
                  '${_formatNickname(message)} 回覆了 ${_formatNickname(replyMessage)}：\n${replyMessage.message} -> $content';
            } else {
              // a Minecraft user is replying to a discord user.

              content =
                  '${_formatNickname(message)} 回覆了 <@${dcMessage.author.id}> 的訊息：\n${dcMessage.content} -> $content';
            }
          }
        }

        final discordMessage = await webhook.execute(
            MessageBuilder.content(_formatEmojiToDiscord(content)),
            avatarUrl: message.avatarUrl,
            username: _formatNickname(message));

        if (discordMessage != null) {
          // Store the discord message id and the universe chat message uuid.
          await dataBox.put(discordMessage.id.toString(), message.uuid);
        }
      } catch (e, stack) {
        await logger.error(
            error: 'Send cosmic chat message to discord failed: $e',
            stackTrace: stack);
      }
    });
  }

  static Future<void> onDiscordMessage(IGuild guild, IMessage message) async {
    if (message.author.bot) return;

    final api = RPMTWApiClient.instance.universeChatResource;
    final dataBox = DataUtil.universeChatBox;

    final referencedMessage = message.referencedMessage;
    String? replyMessageUUID;

    if (referencedMessage != null && referencedMessage.exists) {
      final replyMessage = referencedMessage.message;

      if (replyMessage != null) {
        // a discord user is replying to a Minecraft user.
        replyMessageUUID = dataBox.get(replyMessage.id.toString());
      }
    }

    String uuid = await api.sendDiscordMessage(
        message: _formatEmojiToMinecraft(message.content),
        username: message.author.tag,
        userId: message.author.id.toString(),
        nickname: guild.members[message.author.id]?.nickname,
        avatarUrl: message.author.avatarURL(format: 'png'),
        replyMessageUUID: replyMessageUUID);

    await dataBox.put(message.id.toString(), uuid);
  }

  static Future<Map<String, Snowflake>> _getEmojiData() async {
    final guildPreview = await dcClient.fetchGuildPreview(rpmtwDiscordServerID);

    final Map<String, Snowflake> emojiData = {};

    for (final emoji in guildPreview.emojis) {
      emojiData[emoji.name] = emoji.id;
    }

    return emojiData;
  }

  static String _formatNickname(UniverseChatMessage message) {
    return message.nickname != null
        ? '${message.username} (${message.nickname})'
        : message.username;
  }

  static String _formatEmojiToDiscord(
      String message) {
    return message.replaceAllMapped(RegExp(r':([a-zA-Z0-9_]+):'),
        (match) => '<:${match[1]}:${emojiData[match[1]]}>');
  }

  static String _formatEmojiToMinecraft(
      String message) {
    return message.replaceAllMapped(
        RegExp(r'<:([a-zA-Z0-9_]+):([0-9]+)>'),
        (match) =>
            ':${emojiData.keys.firstWhere((name) => emojiData[name] == int.parse(match[2]!).toSnowflake())}:');
  }
}
