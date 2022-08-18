import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_discord_bot/util/data.dart';

class CosmicChatHandler {
  static Future<void> init(INyxxWebsocket client) async {
    RPMTWApiClient apiClient = RPMTWApiClient.instance;
    ITextGuildChannel cosmicChatChannel = await client
        .fetchChannel<ITextGuildChannel>(831494456913428501.toSnowflake());
    IWebhook webhook = await cosmicChatChannel.getWebhooks().first;

    await apiClient.cosmicChatResource.connect(onlyListenMessage: true);

    await _listenMessages(
        apiClient.cosmicChatResource, webhook, cosmicChatChannel);
  }

  static Future<void> _listenMessages(CosmicChatResource resource,
      IWebhook webhook, ITextGuildChannel channel) async {
    resource.onMessageSent.listen((msg) async {
      try {
        MessageBuilder baseBuilder = MessageBuilder()..content = msg.message;
        final MessageBuilder builder;

        if (msg.replyMessageUUID == null) {
          builder = baseBuilder;
        } else {
          // is reply message
          CosmicChatMessage replyMessage =
              await resource.getMessage(msg.replyMessageUUID!);

          late final IMessage? replyMessageInDiscord;
          try {
            replyMessageInDiscord = channel.messageCache.entries
                .firstWhere((m) =>
                    m.value.content == replyMessage.message &&
                    m.value.author.username == formatNickname(replyMessage))
                .value;
          } catch (e) {
            replyMessageInDiscord = null;
          }

          if (replyMessageInDiscord != null) {
            builder = baseBuilder
              ..replyBuilder = ReplyBuilder.fromMessage(replyMessageInDiscord);
          } else {
            builder = baseBuilder;
          }
        }

        String authorName = formatNickname(msg);

        await webhook.execute(builder,
            avatarUrl: msg.avatarUrl, username: authorName);
      } catch (e, stack) {
        await logger.error(
            error: 'Send cosmic chat message to discord failed: $e',
            stackTrace: stack);
      }
    });
  }

  static String formatNickname(CosmicChatMessage msg) {
    return msg.nickname != null
        ? '${msg.username} (${msg.nickname})'
        : msg.username;
  }
}
