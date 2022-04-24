import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:rpmtw_api_client/rpmtw_api_client.dart';
import 'package:rpmtw_dart_common_library/rpmtw_dart_common_library.dart';
import 'package:rpmtw_discord_bot/extension/track_info_extension.dart';
import 'package:rpmtw_discord_bot/handlers/covid19_handler.dart';
import 'package:rpmtw_discord_bot/handlers/music_handler.dart';
import 'package:rpmtw_discord_bot/model/covid19_info.dart';
import 'package:rpmtw_discord_bot/model/music_queue_page.dart';
import 'package:rpmtw_discord_bot/model/music_search_platform.dart';
import 'package:rpmtw_discord_bot/model/music_result.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class Interactions {
  static final String _playMusicSelectId = 'query_music_result';

  static SlashCommandBuilder get hello {
    SlashCommandBuilder _cmd =
        SlashCommandBuilder('hello', '跟你打招呼', [], guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        final String userTag = event.interaction.userAuthor!.tag;
        await event.respond(MessageBuilder.content('嗨，$userTag ！'));
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get searchMods {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        'search-mods',
        '搜尋在 RPMWiki 上的模組',
        [
          CommandOptionBuilder(
              CommandOptionType.string, 'filter', '模組名稱、模組譯名、模組 ID')
        ],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();
        final String? filter = event.interaction.getArg('filter');

        RPMTWApiClient apiClient = RPMTWApiClient.instance;
        List<MinecraftMod> mods =
            await apiClient.minecraftResource.search(filter: filter);
        mods = mods.take(5).toList();

        EmbedBuilder embed = EmbedBuilder();
        embed.title = '模組搜尋結果';
        embed.description =
            '共搜尋到 ${mods.length} 個模組，由於 Discord 技術限制最多只會顯示 5 個模組';
        embed.timestamp = RPMTWUtil.getUTCTime();

        for (MinecraftMod mod in mods) {
          embed.addField(
            name: mod.name,
            content: mod.description,
          );
        }

        await event.respond(MessageBuilder.embed(embed));
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });

    return _cmd;
  }

  static SlashCommandBuilder get viewMod {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        'view-mod',
        '檢視在 RPMWiki 上的模組',
        [
          CommandOptionBuilder(
              CommandOptionType.string, 'uuid', '模組在 RPMWIki 上的 UUID',
              required: true)
        ],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      await event.acknowledge();
      try {
        final String uuid = event.interaction.getArg('uuid');

        final RPMTWApiClient apiClient = RPMTWApiClient.instance;
        final MinecraftMod mod =
            await apiClient.minecraftResource.getMinecraftMod(uuid);

        ComponentMessageBuilder componentMessageBuilder =
            ComponentMessageBuilder();
        final row = ComponentRowBuilder()
          ..addComponent(LinkButtonBuilder(
              '在 RPMWiki 上檢視此模組', 'https://wiki.rpmtw.com/mod/view/$uuid'));
        componentMessageBuilder.addComponentRow(row);

        if (mod.imageStorageUUID != null) {
          Uint8List bytes = await apiClient.storageResource
              .getStorageBytes(mod.imageStorageUUID!);
          componentMessageBuilder.addBytesAttachment(bytes, 'mod_image.png');
        }

        EmbedBuilder embed = EmbedBuilder();
        embed.title = mod.name;
        embed.description = mod.description;
        if (mod.translatedName != null && mod.translatedName != '') {
          embed.addField(name: '模組譯名', content: mod.translatedName);
        }
        if (mod.id != null && mod.id != '') {
          embed.addField(name: '模組 ID', content: mod.id);
        }
        embed.addField(
            name: '支援的遊戲版本',
            content: mod.supportVersions.map((e) => e.id).join('、'));
        embed.addField(name: '瀏覽次數', content: mod.viewCount, inline: true);

        embed.timestamp = RPMTWUtil.getUTCTime();

        componentMessageBuilder.embeds = [embed];

        await event.respond(componentMessageBuilder);
      } catch (e, stackTrace) {
        await event.respond(
            MessageBuilder.content('找不到此模組或發生未知錯誤，請確認您輸入的 UUID 是否正確。'));
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get info {
    SlashCommandBuilder _cmd = SlashCommandBuilder('info', '查看此機器人的資訊', [],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        String getMemoryUsage() {
          final current =
              (ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2);
          final rss = (ProcessInfo.maxRss / 1024 / 1024).toStringAsFixed(2);
          return '$current/${rss}MB';
        }

        final DateTime now = RPMTWUtil.getUTCTime();
        final DateTime start = dcClient.startTime;

        EmbedBuilder embed = EmbedBuilder();
        embed.addAuthor((author) {
          author.name = dcClient.self.tag;
          author.iconUrl = dcClient.self.avatarURL();
          author.url = 'https://github.com/RPMTW/RPMTW-Discord-Bot';
        });
        embed.addField(
            name: '正常運作時間', content: '${now.difference(start).inMinutes} 分鐘');
        embed.addField(
            name: '記憶體用量 (目前使用量/常駐記憶體大小)', content: getMemoryUsage());
        embed.addField(
            name: '使用者快取', content: dcClient.users.length, inline: true);
        embed.addField(
            name: '頻道快取', content: dcClient.channels.length, inline: true);
        embed.addField(
            name: '訊息快取',
            content: dcClient.channels.values
                .whereType<ITextChannel>()
                .map((e) => e.messageCache.length)
                .fold(0, (first, second) => (first as int) + second),
            inline: true);
        embed.addField(
            name: 'Shard 數量', content: dcClient.shards, inline: true);

        await event.respond(MessageBuilder.embed(embed));
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get chef {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        'chef',
        '廚別人，好電！',
        [
          CommandOptionBuilder(CommandOptionType.user, 'user', '想要廚的人',
              required: true),
          CommandOptionBuilder(
              CommandOptionType.string, 'message', '要向被廚的人發送的訊息內容 (預設為：好電！)',
              required: false)
        ],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        final IUser? author = event.interaction.userAuthor;
        if (author == null) return;
        await event.acknowledge();

        final INyxxWebsocket client = event.client as INyxxWebsocket;
        final Box box = Data.chefBox;
        final String userID = event.getArg('user').value;
        final IUser user = await client.fetchUser(userID.toSnowflake());

        if (user.bot) {
          await event.respond(MessageBuilder.content('您不能廚機器人。'));
          return;
        }

        if (user.id == author.id) {
          await event.respond(MessageBuilder.content('太電啦！您不能廚自己。'));
          return;
        }

        final String message =
            '好電！${event.interaction.getArg('message') ?? ''}';
        int count;
        if (box.containsKey(userID)) {
          int _count = box.get(userID);
          count = _count + 1;
        } else {
          count = 1;
        }
        await box.put(userID, count);

        await event.respond(
            MessageBuilder.content('<@!$userID> $message\n被廚了 $count 次'));
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get chefRank {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        'chef-rank', '看看誰最電！ (前 10 名)', [],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        final Box box = Data.chefBox;
        EmbedBuilder embed = EmbedBuilder();
        embed.title = '電神排名';
        embed.description = '看看誰最電！ (前 10 名)';

        Map<String, int> chefInfos = {};
        for (final key in box.keys) {
          chefInfos[key] = box.get(key);
        }
        List<MapEntry<String, int>> sorted = (chefInfos.entries
                .toList()
                .map((e) => MapEntry(e.key, e.value))
                .toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(10)
            .toList();

        for (final MapEntry<String, int> entry in sorted) {
          int index = sorted.indexOf(entry) + 1;

          embed.addField(
              name: '第 $index 名',
              content: '<@!${entry.key}> 被廚了 ${entry.value} 次');
        }

        embed.timestamp = RPMTWUtil.getUTCTime();

        return await event.respond(MessageBuilder.embed(embed));
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get covid_19 {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        'covid19', '查看今日台灣新冠肺炎疫情資訊', [],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();
        Covid19Info info = await Covid19Handler.getLatest();

        return await event.respond(MessageBuilder.embed(info.generateEmbed()));
      } catch (e, stackTrace) {
        await event.respond(MessageBuilder.content(
            '取得 Covid-19 疫情資訊失敗，請稍後再試，如仍然失敗請聯繫 <@!$siongsngUserID>。'));
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get join {
    SlashCommandBuilder _cmd = SlashCommandBuilder('join', '讓我進入您的語音頻道', [],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();
        return await MusicHandler.joinWithCommand(event);
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get play {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        'play',
        '播放來自 Youtube/Youtube Music/SoundCloud 等平台的歌曲並加入隊列',
        [
          CommandOptionBuilder(CommandOptionType.string, 'query', '歌曲名稱或網址',
              required: true),
          CommandOptionBuilder(
              CommandOptionType.string, 'platform', '平台 (預設為 Youtube)',
              choices: [
                ArgChoiceBuilder('Youtube', '0'),
                ArgChoiceBuilder('Youtube Music', '1'),
                ArgChoiceBuilder('SoundCloud', '3'),
              ]),
        ],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();

        final IMember member = event.interaction.memberAuthor!;
        final IChannel? channel =
            await member.voiceState?.channel?.getOrDownload();
        if (channel == null) {
          return await event
              .respond(MessageBuilder.content('請先連線語音頻道，才能使用此功能。'));
        }

        final bool hasPermission = await MusicHandler.hasPermission(member);
        if (!hasPermission) {
          return await event.respond(MessageBuilder.content('您沒有權限使用此功能。'));
        }

        if (!MusicHandler.isPlaying()) {
          await MusicHandler.joinWithCommand(event, onlyJoin: false);
        }

        final int _platformId =
            int.parse(event.interaction.getArg('platform') ?? '0');
        final MusicSearchPlatform platform =
            MusicSearchPlatform.values.firstWhere((e) => e.id == _platformId);
        final String query = event.interaction.getArg('query');

        final MusicResult result = await MusicHandler.search(query, platform);
        final List<ITrackInfo> infos = result.infos;

        if (result.isPlaylist) {
          infos.map((e) => e.identifier).forEach(MusicHandler.playByIdentifier);
          return await event.respond(MessageBuilder.content(
              '已將 `${result.playlistInfo!.name}` 播放清單加入隊列。'));
        } else if (infos.length > 1) {
          MultiselectBuilder selectBuilder =
              MultiselectBuilder(_playMusicSelectId)
                ..minValues = 1
                ..maxValues = infos.length;

          for (final ITrackInfo info in infos) {
            final List<int> titleCodeUnits = info.title.codeUnits;

            /// Title length must be less than 100.
            final String title = String.fromCharCodes(titleCodeUnits.take(96)) +
                (titleCodeUnits.length > 96 ? '...' : '');

            selectBuilder.addOption(
                MultiselectOptionBuilder(title, info.identifier)
                  ..description = info.uri);
          }

          /// Timeout
          Future.delayed(Duration(minutes: 1), () async {
            try {
              await event.deleteOriginalResponse();
            } catch (e) {
              // ignore
            }
          });

          return await event.respond(ComponentMessageBuilder()
            ..addComponentRow(
                ComponentRowBuilder()..addComponent(selectBuilder)));
        } else if (infos.length == 1) {
          await MusicHandler.playByIdentifier(infos.first.identifier);
          return await event.respond(
              MessageBuilder.content('已將 `${infos.first.title}` 加入隊列。'));
        } else {
          return await event.respond(MessageBuilder.content('搜尋不到任何歌曲。'));
        }
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get leave {
    SlashCommandBuilder _cmd = SlashCommandBuilder('leave', '離開語音頻道並結束播放歌曲', [],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();
        final IMember member = event.interaction.memberAuthor!;
        final bool hasPermission = await MusicHandler.hasPermission(member);

        if (hasPermission) {
          bool playing = MusicHandler.isPlaying();
          if (playing) {
            MusicHandler.leave();
            return await event.respond(MessageBuilder.content('已結束播放歌曲。'));
          } else {
            return await event
                .respond(MessageBuilder.content('請先播放歌曲才能使用此功能。'));
          }
        } else {
          return await event.respond(MessageBuilder.content('您沒有權限使用此功能。'));
        }
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get pause {
    SlashCommandBuilder _cmd =
        SlashCommandBuilder('pause', '暫停播放音樂', [], guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();
        final IMember member = event.interaction.memberAuthor!;
        final bool hasPermission = await MusicHandler.hasPermission(member);

        if (hasPermission) {
          MusicHandler.pause();
          return await event.respond(MessageBuilder.content('已暫停播放歌曲。'));
        } else {
          return await event.respond(MessageBuilder.content('您沒有權限使用此功能。'));
        }
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get resume {
    SlashCommandBuilder _cmd = SlashCommandBuilder('resume', '繼續播放音樂', [],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();
        final IMember member = event.interaction.memberAuthor!;
        final bool hasPermission = await MusicHandler.hasPermission(member);

        if (hasPermission) {
          MusicHandler.resume();
          return await event.respond(MessageBuilder.content('已繼續播放歌曲。'));
        } else {
          return await event.respond(MessageBuilder.content('您沒有權限使用此功能。'));
        }
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get volume {
    SlashCommandBuilder _cmd = SlashCommandBuilder(
        'volume',
        '調整歌曲的音量',
        [
          CommandOptionBuilder(
              CommandOptionType.integer, 'volume', '音量 (0-1000，預設 100)',
              min: 0, max: 1000, required: true)
        ],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        await event.acknowledge();

        final int volume = event.interaction.getArg('volume');
        final IMember member = event.interaction.memberAuthor!;
        final bool hasPermission = await MusicHandler.hasPermission(member);

        if (hasPermission) {
          bool playing = MusicHandler.isPlaying();
          if (playing) {
            MusicHandler.setVolume(volume);
            return await event
                .respond(MessageBuilder.content('已將歌曲音量調整至 $volume%。'));
          } else {
            return await event
                .respond(MessageBuilder.content('請先播放歌曲才能使用此功能。'));
          }
        } else {
          return await event.respond(MessageBuilder.content('您沒有權限使用此功能。'));
        }
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get nowPlaying {
    SlashCommandBuilder _cmd =
        SlashCommandBuilder('np', '查看正在播放的歌曲', [], guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        final IGuildPlayer player = MusicHandler.getOrCreatePlayer();
        final IQueuedTrack? queuedTrack = player.nowPlaying;
        final ITrackInfo? info = queuedTrack?.track.info;

        if (queuedTrack == null) {
          return await event.respond(MessageBuilder.content('請先播放歌曲才能使用此功能。'));
        } else if (info != null) {
          return await event.respond(
              MessageBuilder.embed(info.generateEmbed(progressBar: true)));
        } else {
          return await event.respond(MessageBuilder.content('沒有此歌曲的資訊'));
        }
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get queue {
    SlashCommandBuilder _cmd =
        SlashCommandBuilder('queue', '查看歌曲隊列', [], guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        final List<IQueuedTrack> queuedTracks =
            MusicHandler.getOrCreatePlayer().queue;

        if (queuedTracks.isEmpty) {
          return await event.respond(MessageBuilder.content('歌曲隊列為空。'));
        }

        final IUser user =
            await event.interaction.memberAuthor?.user.getOrDownload() ??
                event.interaction.userAuthor!;

        final List<ITrackInfo> tracks = (queuedTracks
              ..retainWhere((e) => e.track.info != null))
            .map((e) => e.track.info!)
            .toList();

        final MusicResult result = MusicResult(tracks, null);

        final paginator = MusicQueuePage(event.interactions, result, user);

        return await event.respond(paginator.initMessageBuilder());
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static SlashCommandBuilder get skip {
    SlashCommandBuilder _cmd = SlashCommandBuilder('skip', '跳過並播放下首歌曲', [],
        guild: rpmtwDiscordServerID);
    _cmd.registerHandler((event) async {
      try {
        final IMember member = event.interaction.memberAuthor!;
        final bool hasPermission = await MusicHandler.hasPermission(member);

        if (hasPermission) {
          bool playing = MusicHandler.isPlaying();
          if (playing) {
            MusicHandler.skip();
            return await event.respond(MessageBuilder.content('已跳過歌曲。'));
          } else {
            return await event
                .respond(MessageBuilder.content('請先播放歌曲才能使用此功能。'));
          }
        } else {
          return await event.respond(MessageBuilder.content('您沒有權限使用此功能。'));
        }
      } catch (e, stackTrace) {
        await logger.error(error: e, stackTrace: stackTrace);
      }
    });
    return _cmd;
  }

  static Future<void> _musicSearchSelectHandler(
      IMultiselectInteractionEvent event) async {
    await event.acknowledge();
    final IMember member = event.interaction.memberAuthor!;
    final bool hasPermission = await MusicHandler.hasPermission(member);

    if (!hasPermission) {
      return await event.respond(MessageBuilder.content('您沒有權限使用此功能。'));
    }

    final List<String> identifiers = event.interaction.values;
    identifiers.forEach(MusicHandler.playByIdentifier);
    await event.deleteOriginalResponse();

    await event.sendFollowup(
        MessageBuilder.content('已將 ${identifiers.length} 首歌曲加入隊列。'));
  }

  static void register(INyxxWebsocket client) {
    IInteractions interactions =
        IInteractions.create(WebsocketInteractionBackend(client));

    /// Base
    interactions.registerSlashCommand(hello);
    interactions.registerSlashCommand(info);

    /// RPMWiki
    interactions.registerSlashCommand(searchMods);
    interactions.registerSlashCommand(viewMod);

    /// Chef
    interactions.registerSlashCommand(chef);
    interactions.registerSlashCommand(chefRank);

    /// Music
    interactions.registerSlashCommand(join);
    interactions.registerSlashCommand(play);
    interactions.registerSlashCommand(leave);
    interactions.registerSlashCommand(pause);
    interactions.registerSlashCommand(resume);
    interactions.registerSlashCommand(volume);
    interactions.registerSlashCommand(nowPlaying);
    interactions.registerSlashCommand(queue);
    interactions.registerSlashCommand(skip);

    /// Other
    interactions.registerSlashCommand(covid_19);

    /// Handlers
    interactions.registerMultiselectHandler(
        _playMusicSelectId, _musicSearchSelectHandler);

    interactions.syncOnReady();
  }
}
