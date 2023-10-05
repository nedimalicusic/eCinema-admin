import 'package:ecinema_admin/models/language.dart';
import 'base_provider.dart';

class LanguageProvider extends BaseProvider<Language> {
  LanguageProvider() : super('Language/GetPaged');

  @override
  Language fromJson(data) {
    return Language.fromJson(data);
  }
}
