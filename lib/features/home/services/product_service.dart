import 'package:dio/dio.dart';

class ProductService {
  final Dio dio = Dio();

  Future<Response> getProducts() async {
    return await dio.get('https://dummyjson.com/products?limit=100');
  }

  Future<Response> getCategories() async {
    return await dio.get('https://dummyjson.com/products/categories');
  }
}
