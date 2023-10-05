import 'package:ecinema_admin/models/actor.dart';

import 'base_provider.dart';

class ActorProvider extends BaseProvider<Actor> {
  ActorProvider() : super('Actors/GetPaged');

  @override
  Actor fromJson(data) {
    return Actor.fromJson(data);
  }
}
