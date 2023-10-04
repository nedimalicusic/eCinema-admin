import '../models/movie.dart';
import 'base_provider.dart';

class MovieProvider extends BaseProvider<Movie> {
  MovieProvider() : super('Movie/GetPaged');

  @override
  Movie fromJson(data) {
    return Movie.fromJson(data);
  }
}