import 'package:nyxx/nyxx.dart';

abstract class BaseEvent<T> {
  Future<void> handler(INyxxWebsocket client, T event) async {
    throw UnimplementedError();
  }
}
