import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_lavalink/nyxx_lavalink.dart';
import 'package:rpmtw_discord_bot/model/music_search_platform.dart';
import 'package:rpmtw_discord_bot/model/music_search_result.dart';
import 'package:rpmtw_discord_bot/utilities/data.dart';

class MusicHandler {
  static final Map<String, ITrack> _cacheTracks = {};

  static IVoiceGuildChannel? _playingChannel;
  static IMember? _playingMember;
  static IGuildPlayer? _player;
  static late final ICluster _cluster;

  static INode getNode() =>
      _cluster.getOrCreatePlayerNode(rpmtwDiscordServerID);

  static IGuildPlayer getOrCreatePlayer() {
    _player ??= getNode().createPlayer(rpmtwDiscordServerID);

    return _player!;
  }

  static Future<void> init() async {
    _cluster = ICluster.createCluster(dcClient, dcClient.self.id);

    try {
      /// Wait for the lavalink server to be ready
      await Future.delayed(Duration(seconds: 5));
      await _cluster.addNode(NodeOptions(host: 'lavalink'));
      await Future.delayed(Duration(seconds: 2));
      getOrCreatePlayer();
    } catch (e) {
      logger.warn('Failed to connect to Lavalink node');
    }
    eventHandler();
  }

  static void eventHandler() {
    IEventDispatcher dispatcher = _cluster.eventDispatcher;

    dispatcher.onTrackEnd.listen((ITrackEndEvent event) async {
      final List<IQueuedTrack> queue = getOrCreatePlayer().queue;

      /// If all tracks have ended, leave channel
      if (queue.isEmpty && event.reason == "FINISHED") {
        await leave();
      }
    });
  }

  static Future<IPlayParameters> playByIdentifier(String identifier) async {
    final ITrack? track = _cacheTracks[identifier];

    if (track != null) {
      return play(track);
    } else {
      throw Exception('Track not found in cache');
    }
  }

  static IPlayParameters play(ITrack track, {bool forces = false}) {
    final INode node = getNode();
    IPlayParameters parameters = node.play(
      rpmtwDiscordServerID,
      track,
      requester: _playingMember?.id,
      channelId: _playingChannel?.id,
    );

    if (forces) {
      node.stop(rpmtwDiscordServerID);
      parameters.startPlaying();
    } else {
      parameters.queue();
    }

    return parameters;
  }

  static bool isPlaying() {
    return _playingChannel != null && _playingMember != null;
  }

  static Future<bool> hasPermission(IMember member) async {
    bool isAdmin = (await member.effectivePermissions).administrator;
    IChannel? channel = await member.voiceState?.channel?.getOrDownload();

    return channel != null && (member.id == _playingMember?.id || isAdmin);
  }

  static void join(IVoiceGuildChannel channel, IMember member) {
    _playingChannel = channel;
    _playingMember = member;
    channel.connect(selfDeafen: true);
  }

  static Future<void> joinWithCommand(ISlashCommandInteractionEvent event,
      {bool onlyJoin = true}) async {
    IMember member = event.interaction.memberAuthor!;
    IVoiceGuildChannel? channel = await member.voiceState?.channel
        ?.getOrDownload() as IVoiceGuildChannel?;
    if (channel == null) {
      return await event.respond(MessageBuilder.content('請先連線語音頻道，才能使用此功能。'));
    }

    IMember selfMember = await event.interaction.guild!
        .getFromCache()!
        .fetchMember(dcClient.self.id);

    if (selfMember.voiceState?.channel != null) {
      return await event
          .respond(MessageBuilder.content('我正在為其他人服務中，抱歉造成您的困擾。'));
    }

    MusicHandler.join(channel, member);

    if (onlyJoin) {
      return await event.respond(MessageBuilder.content('成功加入您的語音頻道！'));
    }
  }

  static Future<void> leave() async {
    if (!isPlaying()) {
      return;
    }

    final INode node = getNode();
    node.clearPlayers();

    _playingChannel?.disconnect();
    _playingChannel = null;
    _playingMember = null;
  }

  static void pause() {
    getNode().pause(rpmtwDiscordServerID);
  }

  static void resume() {
    getNode().resume(rpmtwDiscordServerID);
  }

  /// Skip a track
  static void skip() {
    getNode().skip(rpmtwDiscordServerID);
  }

  static void setVolume(int volume) {
    getNode().volume(rpmtwDiscordServerID, volume);
  }

  static void shutdown() async {
    getNode().shutdown();
  }

  static Future<MusicSearchResult> search(
      String query, MusicSearchPlatform platform) async {
    final INode node = getNode();
    final ITracks results =
        await node.autoSearch(query, platform: platform.platform);

    final List<ITrack> tracks = results.tracks
      ..retainWhere((e) => e.info != null);

    for (final ITrack track in tracks) {
      _cacheTracks[track.info!.identifier] = track;
    }

    final List<ITrackInfo> infos = tracks.map((e) => e.info!).take(25).toList();

    return MusicSearchResult(
        infos, results.playlistInfo.name != null ? results.playlistInfo : null);
  }
}
