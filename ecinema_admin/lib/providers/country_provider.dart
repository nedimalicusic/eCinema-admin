import 'package:ecinema_admin/models/country.dart';

import 'base_provider.dart';

class CountryProvider extends BaseProvider<Country> {
  CountryProvider() : super('Countries/GetPaged');

  @override
  Country fromJson(data) {
    return Country.fromJson(data);
  }
}
