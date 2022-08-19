import 'package:nyxx/nyxx.dart';
import 'package:rpmtw_discord_bot/events/base_event.dart';
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
        case 852389500733751337:
          await _issuesChannelHandler(guild, message);
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

  Future<void> _issuesChannelHandler(IGuild guild, IMessage message) async {
    if (message.author.bot) return;

    final String name = '${message.author.username} 詢問的問題討論串';
    final ThreadBuilder builder = ThreadBuilder(name)
      ..archiveAfter = ThreadArchiveTime.day
      ..private = false;

    final IThreadChannel thread = await message.createAndGetThread(builder);

    final String initMessage = '''
<@${message.author.id}>
**如何在 RPMTW 詢問問題**
▎詢問問題前，建議依照此模板詢問，才能讓其他人更快速**了解問題**並幫助您解決

> **問題簡述**
簡單敘述您想詢問的問題。

> **補充說明**
如果有更詳細的問題資訊請寫在這裡。

> **截圖**
如果要附上畫面建議使用截圖不要用手機等裝置翻拍效果比較好 (Windows 上可使用 窗戶按鍵 + Shift + S 截圖)。

> **系統資訊**
如果是詢問崩潰之類的問題，記得附上像是崩潰報告 (crash-reports/崩潰時間.txt)、遊戲日誌 (logs/latest.log)、作業系統版本等資訊，請不要只給一張錯誤代碼 XX 的圖片。

請問 ***有意義*** 的問題，發問前請記得先**搜尋**過問題，或者查看**釘選訊息**有沒有相關內容 (Google 是你的好幫手)。

▎備註

RPMTW 社群的夥伴們都是很友善的 .w.

PS: RPMTW 社群使用 Discord 的討論串機制，目的是可以區分話題，避免多個問題同時進行的時候被忽略或很亂。
PS: 如果問題只是偏向討論性質，可以轉至其他頻道。
''';

    await thread.sendMessage(MessageBuilder.content(initMessage));
    await thread.sendMessage(MessageBuilder.embed(EmbedBuilder()
      ..title = '提問的藝術'
      ..imageUrl =
          'https://media.discordapp.net/attachments/852389500733751337/906135583204720670/unknown.png'));
  }
}
