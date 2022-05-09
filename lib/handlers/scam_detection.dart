// ignore_for_file: implementation_imports
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/internal/http_endpoints.dart';
import 'package:nyxx/src/internal/http/http_request.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtw_discord_bot/data/phishing_link.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

final String _pattern =
    r'(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';

final RegExp _urlRegex = RegExp(_pattern);

class ScamDetection {
  static Future<void> detection(String message,
      {required Future<void> Function(String message, String url) inBlackList,
      required Future<void> Function(String message, String url)
          unknownSuspiciousDomain}) async {
    if (message.contains('https://') || message.contains('http://')) {
      if (!_urlRegex.hasMatch(message)) return;

      /// 訊息內容包含網址

      List<RegExpMatch> matchList = _urlRegex.allMatches(message).toList();

      List<String> domainWhitelist = [
        // DC 官方域名
        'discord.gift',
        'discord.gg',
        'discord.com',
        'discordapp.com',
        'discordapp.net',
        'discordstatus.com',
        'discord.media',
        'cdn.discordapp.com',

        /// Discord 社群域名
        'discordresources.com',
        'discord.wiki',
        'discordservers.tw',
        'discord.st',

        // Steam 官方域名
        'steampowered.com',
        'steamcommunity.com',
        'steamdeck.com',
        'steamchina',

        // 在 Alexa 名列前茅的 .gift 和 .gifts 域名
        'crediter.gift',
        'packedwithpurpose.gifts',
        '123movies.gift',
        'admiralwin.gift',
        'gol.gift',
        'newhome.gifts'
      ];

      for (RegExpMatch match in matchList) {
        String matchString = message.substring(match.start, match.end);
        Uri? uri = Uri.tryParse(matchString);
        if (uri == null) continue;
        List<String> domainList = uri.host.split('.');
        List<String> keywords = ['disc', 'steam', 'gift'];

        String domain1 = domainList.length >= 3 ? domainList[1] : domainList[0];
        String domain2 = domainList.length >= 3 ? domainList[2] : domainList[1];
        String domain = '$domain1.$domain2';

        bool isWhitelisted = domainWhitelist.contains(domain);
        bool isBlacklisted = phishingLink.contains(domain);
        bool isUnknownSuspiciousLink =
            keywords.any((e) => domain1.contains(e) || domain2.contains(e));

        if (!isWhitelisted) {
          if (isBlacklisted) {
            await inBlackList(message, matchString);
            break;
          } else if (isUnknownSuspiciousLink) {
            await unknownSuspiciousDomain(message, matchString);
            break;
          }
        }
      }
    }
  }

  static Future<bool> detectionWithBool(String message) async {
    bool phishing = false;
    void onPhishing() {
      phishing = true;
    }

    await ScamDetection.detection(message,
        inBlackList: (message, url) async => onPhishing(),
        unknownSuspiciousDomain: (message, url) async => onPhishing());

    return phishing;
  }

  static Future<void> detectionForDiscord(
      INyxxWebsocket client, IMessage message) async {
    if (message.author.bot) return;
    final String messageContent = message.content;
    await detection(messageContent,
        inBlackList: (_message, url) => _onPhishing(message, client, false),
        unknownSuspiciousDomain: (_message, url) =>
            _onPhishing(message, client, true));

    /*
    else if (phishingTerms.any((e) => messageContent.contains(e))) {
      /// 詐騙關鍵字
      _onPhishing(message, client);
    }
    */
  }

  static Future<void> _onPhishing(
      IMessage message, INyxxWebsocket client, bool suspicious) async {
    final ReplyBuilder replyBuilder = ReplyBuilder.fromMessage(message);
    IMessageAuthor author = message.author;
    MessageBuilder messageBuilder = MessageBuilder.content(
        '偵測到 <@${author.id}> ${suspicious ? '疑似' : ''}發送了詐騙訊息，因此已立即${suspicious ? '禁言' : '停權'} <@${author.id}>，其他人請勿點選此詐騙訊息，如認為機器人有誤判請聯繫 <@645588343228334080>。');
    messageBuilder.replyBuilder = replyBuilder;

    await message.channel.sendMessage(messageBuilder);
    await message.delete();
    if (message.guild != null) {
      IGuild guild = message.guild!.getFromCache()!;
      String reason =
          '違反 RPMTW Discord 伺服器規範第一條，不得以任何形式騷擾他人，散布不實詐騙訊息，如認為有誤判，請使用 Email 聯絡 rrt46777@gmail.com，並附上您的 Discord ID。';

      if (suspicious) {
        IMember member = await guild.fetchMember(author.id);

        /// Timeout member for 7 days
        await member.edit(
            builder: MemberBuilder()
              ..timeoutUntil = RPMTWUtil.getUTCTime().add(Duration(days: 7)),
            auditReason: reason);
      } else {
        HttpEndpoints httpEndpoints = client.httpEndpoints as HttpEndpoints;

        await httpEndpoints.executeSafe(BasicRequest(
            '/guilds/${guild.id}/bans/${author.id}',
            method: 'PUT',
            body: {'delete-message-days': 1, 'reason': reason}));
      }
    }
    await logger.info(
        '偵測到 <@${author.id}> 在 <#${message.channel.id}> ${suspicious ? '疑似' : ''}發送詐騙訊息');
  }
}
