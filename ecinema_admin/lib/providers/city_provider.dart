import 'package:ecinema_admin/models/city.dart';

import 'base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super('Cities/GetPaged');

  @override
  City fromJson(data) {
    return City.fromJson(data);
  }
}
