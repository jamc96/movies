import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Cast {
  final String name;
  final String character_name;
  final String url_small_image;
  final String imdb_code;

  Cast({
    this.name,
    this.character_name,
    this.url_small_image,
    this.imdb_code,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      name: json['name'],
      character_name: json['character_name'],
      url_small_image: json['url_small_image'],
      imdb_code: json['imdb_code'],
    );
  }
}

class MovieDetail extends ChangeNotifier {
  String large_screenshot_image1;
  String large_screenshot_image2;
  String large_screenshot_image3;
  List<Cast> cast;
  List<String> screenshots;
  String yt_trailer_code;

  MovieDetail({
    this.large_screenshot_image1,
    this.large_screenshot_image2,
    this.large_screenshot_image3,
    this.cast,
    this.screenshots,
    this.yt_trailer_code,
  });
}

class Movie extends ChangeNotifier {
  final int id;
  final String title;
  final String title_english;
  final String title_long;
  final int year;
  final int runtime;
  final String imdb_code;
  final String url;
  final List<dynamic> genres;
  final String summary;
  final String medium_cover_image;
  final String large_cover_image;
  final String background_image;
  final DateTime date_uploaded;
  final String rating;

  Movie({
    this.id,
    this.title,
    this.title_english,
    this.title_long,
    this.year,
    this.runtime,
    this.imdb_code,
    this.url,
    this.genres,
    this.summary,
    this.medium_cover_image,
    this.large_cover_image,
    this.background_image,
    this.date_uploaded,
    this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      title_english: json['title_english'],
      title_long: json['title_long'],
      year: json['year'],
      runtime: json['runtime'],
      imdb_code: json['imdb_code'],
      url: json['url'],
      genres: json['genres'] as List<dynamic>,
      summary: json['summary'],
      medium_cover_image: json['medium_cover_image'],
      large_cover_image: json['large_cover_image'],
      background_image: json['background_image'],
      date_uploaded: DateTime.parse(json['date_uploaded']),
      rating: json['rating'].toString(),
    );
  }
}

class Movies extends ChangeNotifier {
  List<Movie> _movies = [];
  List<Movie> _searchResults = [];
  MovieDetail _movieDetail;
  List<Movie> _moviesSuggested = [];
  List<int> _moviesIdList = [];

  List<Movie> get movies {
    return [..._movies];
  }

  List<Movie> get searchResults {
    return [..._searchResults];
  }

  MovieDetail get movieDetail {
    return _movieDetail;
  }

  List<Movie> get movieSuggested {
    return [..._moviesSuggested];
  }

  List<int> get moviesIdList {
    return [...moviesIdList];
  }

  int get previousMovieId {
    if (_moviesIdList.length > 0) {
      return _moviesIdList[_moviesIdList.length - 1];
    }
    return 0;
  }

  void addMovieIdToList(int movieId) {
    _moviesIdList.add(movieId);
  }

  void popMovieIdFromList() {
    if (_moviesIdList.length > 0) {
      _moviesIdList.removeLast();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  Movie findById(int id) {
    var movie = movies.firstWhere((movie) => movie.id == id, orElse: () {
      return searchResults.firstWhere((movie) => movie.id == id, orElse: () {
        return movieSuggested.firstWhere((movie) => movie.id == id);
      });
    });

    return movie;
    // return movies.firstWhere((movie) => movie.id == id);
  }

  Future<void> fectchAndSetMovies() async {
    final url =
        'https://yts.mx/api/v2/list_movies.json?limit=50&sort_by=like_count';

    try {
      final List<Movie> loadedMovies = [];

      final response = await http.get(url);
      final extratedData = json.decode(response.body) as Map<String, dynamic>;
      if (extratedData == null) {
        return;
      }

      var movies = jsonDecode(response.body)['data']['movies'] as List;
      movies.forEach((movieData) {
        Movie m = Movie.fromJson(movieData);
        loadedMovies.add(m);
      });

      _movies = loadedMovies;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> getMovieDetail(int movieId) async {
    final url =
        'https://yts.mx/api/v2/movie_details.json?movie_id=$movieId&with_images=true&with_cast=true';

    try {
      final response = await http.get(url);
      final extratedData = json.decode(response.body) as Map<String, dynamic>;
      if (extratedData == null) {
        return;
      }

      List<Cast> responseCast = [];

      var cast = jsonDecode(response.body)['data']['movie']['cast'] as List;
      if (cast != null) {
        cast.forEach((castData) {
          Cast c = Cast.fromJson(castData);
          responseCast.add(c);
        });
      }

      final img1 =
          extratedData['data']['movie']['large_screenshot_image1'] as String;
      final img2 =
          extratedData['data']['movie']['large_screenshot_image2'] as String;
      final img3 =
          extratedData['data']['movie']['large_screenshot_image3'] as String;
      final imgsList = [img1, img2, img3];

      final videoCode =
          extratedData['data']['movie']['yt_trailer_code'] as String;

      final movieDetail = MovieDetail(
        cast: responseCast,
        large_screenshot_image1: img1,
        large_screenshot_image2: img2,
        large_screenshot_image3: img3,
        screenshots: imgsList,
        yt_trailer_code: videoCode,
      );
      _movieDetail = movieDetail;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> searchMovies(String query_term) async {
    final url =
        'https://yts.mx/api/v2/list_movies.json?query_term=$query_term&sort_by=rating';

    try {
      final List<Movie> responseMovies = [];
      clearSearchResults();

      final response = await http.get(url);
      final extratedData = json.decode(response.body) as Map<String, dynamic>;
      if (extratedData == null) {
        return;
      }

      var movies = jsonDecode(response.body)['data']['movies'] as List;
      if (movies == null) {
        return;
      }
      movies.forEach((movieData) {
        Movie m = Movie.fromJson(movieData);
        responseMovies.add(m);
      });

      _searchResults = responseMovies;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> getMovieSuggestions(int movieId) async {
    final url =
        'https://yts.mx/api/v2/movie_suggestions.json?movie_id=$movieId';

    try {
      final List<Movie> responseMovies = [];
      clearSearchResults();

      final response = await http.get(url);
      final extratedData = json.decode(response.body) as Map<String, dynamic>;
      if (extratedData == null) {
        return;
      }

      var movies = jsonDecode(response.body)['data']['movies'] as List;
      if (movies == null) {
        return;
      }
      movies.forEach((movieData) {
        Movie m = Movie.fromJson(movieData);
        responseMovies.add(m);
      });

      _moviesSuggested = responseMovies;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
