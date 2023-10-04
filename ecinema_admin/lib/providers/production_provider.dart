import 'package:ecinema_admin/models/production.dart';

import 'base_provider.dart';

class ProductionProvider extends BaseProvider<Production> {
  ProductionProvider() : super('Production/GetPaged');

  @override
  Production fromJson(data) {
    return Production.fromJson(data);
  }
}
