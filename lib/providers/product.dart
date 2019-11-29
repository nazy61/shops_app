import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus() {
    isFavorite = !isFavorite;
    final url = 'https://shops-app-1a992.firebaseio.com/products/$id.json';
    http.patch(
      url,
      body: json.encode({
        'isFavorite' : isFavorite,
      }),
    );
    notifyListeners();
  }
}
