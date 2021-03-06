import 'package:flutter/material.dart';

class SimpleNews {
  final DateTime date;
  final String provider;
  final String message;

  const SimpleNews({
    @required this.date,
    @required this.provider,
    @required this.message,
  })  : assert(date != null),
        assert(provider != null),
        assert(message != null);

  static SimpleNews fromJson(Map<String, dynamic> json) {
    return SimpleNews(
      date: DateTime.fromMicrosecondsSinceEpoch(
        int.parse(json['timestamp']) * 1000,
      ),
      provider: json['user'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date.toIso8601String(),
      'provider': provider,
      'message': message,
    };
  }
}

class NewsModel {
  final List<SimpleNews> news;

  const NewsModel({@required this.news}) : assert(news != null);

  static NewsModel fromJson(Map<String, dynamic> json) {
    var newsList = new List<SimpleNews>();
    if (!json['success']) {
      return null;
    }
    for (var key in json['entries']) {
      newsList.add(SimpleNews.fromJson(key));
    }
    return NewsModel(news: newsList);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'news': news.map((i) => i.toJson()).toList(),
    };
  }
}
