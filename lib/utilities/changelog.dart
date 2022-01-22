import 'package:nyxx/nyxx.dart';

class Changelog {
  static Snowflake get logChannelId => 832849374395760660.toSnowflake();

  static late INyxxWebsocket _client;

  static void init(INyxxWebsocket client) {
    _client = client;
  }

  static Future<void> edit(IMessage updated) async {
    final ITextChannel channel =
        await _client.fetchChannel<ITextChannel>(logChannelId);

    final EmbedBuilder embed = EmbedBuilder();

    embed.title = "訊息修改紀錄";
    embed.description = "<@${updated.author.id}> 在 <#${updated.channel.id}> 編輯訊息";
    // embed.addField(name: "原始訊息", content: before.content);
    embed.addField(name: "修改後訊息", content: updated.content);
    embed.color = DiscordColor.fromHexString("#4deb87");
    embed.timestamp = DateTime.now();

    await channel.sendMessage(MessageBuilder.embed(embed));
  }

  static Future<void> deleted(IMessage message) async {
    final ITextChannel channel =
        await _client.fetchChannel<ITextChannel>(logChannelId);

    final EmbedBuilder embed = EmbedBuilder();

    embed.title = "訊息刪除紀錄";
    embed.description = "<@${message.author.id}> 在 <#${message.channel.id}> 刪除訊息";
    embed.addField(name: "刪除的訊息內容", content: message.content);
    embed.color = DiscordColor.fromHexString("#f51707");
    embed.timestamp = DateTime.now();

    await channel.sendMessage(MessageBuilder.embed(embed));
  }
}
