import 'package:nyxx/nyxx.dart';

class Changelog {
  final INyxxWebsocket client;

  const Changelog(this.client);

  static Snowflake get channelId => 832849374395760660.toSnowflake();

  Future<void> edit(IMessage updated) async {
    final ITextChannel channel =
        await client.fetchChannel<ITextChannel>(channelId);

    final EmbedBuilder embed = EmbedBuilder();

    embed.title = "訊息修改紀錄";
    embed.description =
        "<@${updated.author.id}> 在 <#${updated.channel.id}> 編輯訊息";
    // embed.addField(name: "原始訊息", content: before.content);
    embed.addField(name: "修改後訊息", content: updated.content);
    embed.color = DiscordColor.fromHexString("#4deb87");
    embed.timestamp = DateTime.now();

    await channel.sendMessage(MessageBuilder.embed(embed));
  }

  Future<void> deleted(IMessage message) async {
    final ITextChannel channel =
        await client.fetchChannel<ITextChannel>(channelId);

    final EmbedBuilder embed = EmbedBuilder();

    embed.title = "訊息刪除紀錄";
    embed.description =
        "<@${message.author.id}> 在 <#${message.channel.id}> 刪除訊息";
    embed.addField(name: "刪除的訊息內容", content: message.content);
    embed.color = DiscordColor.fromHexString("#f51707");
    embed.timestamp = DateTime.now();

    await channel.sendMessage(MessageBuilder.embed(embed));
  }
}
