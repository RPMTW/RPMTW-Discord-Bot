import 'dart:typed_data';

import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class Interactions {
  static SlashCommandBuilder get hello {
    SlashCommandBuilder _cmd =
        SlashCommandBuilder("hello", "跟你打招呼", [], guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      String userTag = event.interaction.userAuthor!.tag;
      await event.respond(MessageBuilder.content("嗨，$userTag ！"));
    });
    return _cmd;
  }

  static SlashCommandBuilder get searchMods {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        "search-mods",
        "搜尋在 RPMWiki 上的模組",
        [
          CommandOptionBuilder(
              CommandOptionType.string, "filter", "模組名稱、模組譯名、模組 ID")
        ],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      await event.acknowledge();
      String? filter;
      try {
        filter = event.getArg("filter").value;
        if (filter == "" || filter == "null") filter = null;
      } catch (e) {
        filter = null;
      }
      RPMTWApiClient apiClient = RPMTWApiClient.lastInstance;
      List<MinecraftMod> mods =
          await apiClient.minecraftResource.search(filter: filter);
      mods = mods.take(5).toList();

      EmbedBuilder embed = EmbedBuilder();
      embed.title = "模組搜尋結果";
      embed.description = "共搜尋到 ${mods.length} 個模組，由於 Discord 技術限制最多只會顯示 5 個模組";
      embed.timestamp = DateTime.now();

      for (MinecraftMod mod in mods) {
        embed.addField(
          name: mod.name,
          content: mod.description,
        );
      }

      await event.respond(MessageBuilder.embed(embed));
    });
    return _cmd;
  }

  static SlashCommandBuilder get viewMod {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        "view-mod",
        "檢視在 RPMWiki 上的模組",
        [
          CommandOptionBuilder(
              CommandOptionType.string, "uuid", "模組在 RPMWIki 上的 UUID",
              required: true)
        ],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      await event.acknowledge();
      try {
        String uuid = event.getArg("uuid").value;

        RPMTWApiClient apiClient = RPMTWApiClient.lastInstance;
        MinecraftMod mod =
            await apiClient.minecraftResource.getMinecraftMod(uuid);

        ComponentMessageBuilder componentMessageBuilder =
            ComponentMessageBuilder();
        final row = ComponentRowBuilder()
          ..addComponent(LinkButtonBuilder(
              "在 RPMWiki 上檢視此模組", "https://wiki.rpmtw.com/#/mod/view/$uuid"));
        componentMessageBuilder.addComponentRow(row);

        if (mod.imageStorageUUID != null) {
          Uint8List bytes = await apiClient.storageResource
              .getStorageBytes(mod.imageStorageUUID!);
          componentMessageBuilder.addBytesAttachment(bytes, "mod_image.png");
        }

        EmbedBuilder embed = EmbedBuilder();
        embed.title = mod.name;
        embed.description = mod.description;
        if (mod.translatedName != null &&
            mod.translatedName != "") {
          embed.addField(name: "模組譯名", content: mod.translatedName);
        }
        if (mod.id != null && mod.id != "") {
          embed.addField(name: "模組 ID", content: mod.id);
        }
        embed.addField(
            name: "支援的遊戲版本",
            content: mod.supportVersions.map((e) => e.id).join("、"));
        embed.addField(
            name: "瀏覽次數", content: mod.viewCount, inline: true);

        embed.timestamp = DateTime.now();

        componentMessageBuilder.embeds = [embed];

        await event.respond(componentMessageBuilder);
      } catch (e) {
        print(e);
        await event.respond(
            MessageBuilder.content("找不到此模組或發生未知錯誤，請確認您輸入的 UUID 是否正確。"));
      }
    });
    return _cmd;
  }

  static void register(INyxxWebsocket client) {
    IInteractions interactions =
        IInteractions.create(WebsocketInteractionBackend(client));

    interactions.registerSlashCommand(hello);
    interactions.registerSlashCommand(searchMods);
    interactions.registerSlashCommand(viewMod);

    interactions.syncOnReady();
  }
}
