import 'package:dio/dio.dart';
import 'package:bafia/models/item_model.dart';
import 'package:bafia/models/user_model.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Item>> fetchItems() async {
    final response = await _dio.get('https://api.example.com/items');
    return (response.data as List).map((item) => Item.fromJson(item)).toList();
  }

  Future<User> getUserProfile() async {
    final response = await _dio.get('https://api.example.com/user/profile');
    return User.fromJson(response.data);
  }
}
