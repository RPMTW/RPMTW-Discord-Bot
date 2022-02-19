import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class MessageReceivedEvent implements BaseEvent<IMessageReceivedEvent> {
  @override
  Future<void> handler(client, event) async {
    try {
      IMessage message = event.message;
      if (message.author.bot) return;
      final String messageContent = message.content;

      final RegExp urlRegex = RegExp(
          r"(https?:\/\/)([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$");

      if (messageContent.contains("https://") || messageContent.contains("http://")) {
        logger.info("Message contains url");
        if (!urlRegex.hasMatch(messageContent)) return;

        /// 訊息內容包含網址

        List<RegExpMatch> matchList =
            urlRegex.allMatches(messageContent).toList();

        List<String> domainWhitelist = [
          // DC 官方域名
          "discord.gift",
          "discord.gg",
          "discord.com",
          "discordapp.com",
          "discordapp.net",

          /// 社群域名
          "discordresources.com",
          "discord.wiki",

          // Steam 官方域名
          "steampowered.com",
          "steamcommunity.com",

          // 在 Alexa 名列前茅的 .gift 和 .gifts 域名
          "crediter.gift",
          "packedwithpurpose.gifts",
          "123movies.gift",
          "admiralwin.gift",
          "gol.gift",
          "newhome.gifts"
        ];

        for (RegExpMatch match in matchList) {
          String domain1 = match.group(2)!.split(".").last;
          String domain2 = match.group(3)!;
          String domain = "$domain1.$domain2";

          bool isWhitelisted = domainWhitelist.contains(domain);
          bool isBlacklisted = phishingLinkList.contains(domain);
          bool isUnknownSuspiciousLink = domain1.contains("disc") ||
              domain1.contains("steam") ||
              domain2.contains("gift");

          bool phishing =
              !isWhitelisted && (isBlacklisted || isUnknownSuspiciousLink);

          if (phishing) {
            /// 符合詐騙連結條件
            _onPhishing(message, ban: true);
          }
        }
      }

      /*
      else if (phishingTermList.any((e) => messageContent.contains(e))) {
        /// 詐騙關鍵字
        _onPhishing(message, ban: false);
      }
      */
    } catch (error, stackTrace) {
      logger.error(error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _onPhishing(IMessage message, {required bool ban}) async {
    final ReplyBuilder replyBuilder = ReplyBuilder.fromMessage(message);
    IMessageAuthor author = message.author;
    MessageBuilder messageBuilder = MessageBuilder.content(
        "偵測到 <@${author.id}> 發送了詐騙訊息，因此已立即停權 <@${author.id}>，其他人請勿點選此詐騙訊息。");
    messageBuilder.replyBuilder = replyBuilder;

    await message.channel.sendMessage(messageBuilder);
    await message.delete();

    if (message.guild != null) {
      IGuild guild = message.guild!.getFromCache()!;
      String auditReason =
          "違反 RPMTW Discord 伺服器規範第一條，不得以任何形式騷擾他人，散布不實詐騙訊息，如認為有誤判，請使用 Email 聯絡 rrt46777@gmail.com，並附上您的 Discord ID。";

      if (ban) {
        await guild.ban(author, deleteMessageDays: 1, auditReason: auditReason);
      } else {
        await guild.kick(author, auditReason: auditReason);
      }
    }
    await logger.info("偵測到 <@${author.id}> 在 <#${message.channel.id}> 發送詐騙訊息");
  }
}
