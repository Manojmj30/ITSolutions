import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../Model/Pixabay_model.dart';



class PixabayProvider extends ChangeNotifier {
  List<PixabayImage> images = [];
  bool isLoading = false;
  String query = '';
  int page = 1;
  bool hasMore = true;

  Future<void> fetchImages({String? newQuery}) async {
    if (isLoading) return;
    isLoading = true;
    if (newQuery != null) {
      query = newQuery;
      page = 1;
      images = [];
      hasMore = true;
    }
    const apiKey = '45948798-97ac9d7e08e3ce6721df4cbfa';
    final response = await http.get(Uri.parse(
        'https://pixabay.com/api/?key=$apiKey&q=$query&image_type=photo&per_page=100&page=$page'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List newImages = (data['hits'] as List)
          .map((imageJson) => PixabayImage.fromJson(imageJson))
          .toList();
      if (newImages.isNotEmpty) {
        images.addAll(newImages as Iterable<PixabayImage>);
        page++;
      } else {
        hasMore = false;
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void reset() {
    images = [];
    page = 1;
    hasMore = true;
    notifyListeners();
  }
}