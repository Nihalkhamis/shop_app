import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './product.dart';

class Products with ChangeNotifier {  //ChangeNotifier is a mixin

  final String? token;
  final String? userId;

  List<Product>? _items;
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  // ]; // we let it private cz we want only that any change occur here to trigger notifyListeners() to reflect on others who listens to it

  Products(this.token, this._items, this.userId);

  // bool _isFav = false;
  List<Product> get items {
    // ... => return a copy not a reference of _items to prevent editing in this list so when we add or delete item from it will reflect on all it's listeners
    // if(_isFav){
    //   return _items.where((product) => product.isFav).toList();
    // }
    return [...?_items];
  }

  // void showFavoritesOnly(){
  //   _isFav = true;
  //   notifyListeners();
  // }
  // void showAllProducts(){
  //   _isFav = false;
  //   notifyListeners();
  // }

  List<Product> get favProducts {
    return _items!.where((product) => product.isFav).toList();
  }

  Product getById(String id) {
    return _items!.firstWhere((product) => product.id == id);
  }


  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://shopapp-aa04e-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      if(json.decode(response.body) == null){
        return;
      }
      final extractData = json.decode(response.body) as Map<String, dynamic>;

      // for favorites
       url = Uri.parse(
          "https://shopapp-aa04e-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$token");
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData["title"],
          price: prodData["price"],
          description: prodData["description"],
          isFav: favoriteData == null ? false : favoriteData[prodId] ?? false,  // if data is null(user doesn't have any fav prod) or this id doesn't found so we set it with false
          imageUrl: prodData["imageUrl"],
        ));
      });
      _items = loadedProducts;
      // print("extractData.length} ${extractData.length}");
      // print("loadedProducts ${loadedProducts.length}");
      // print("items ${items.length}");
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addItem(Product product) async {
    final url = Uri.parse(
        "https://shopapp-aa04e-default-rtdb.firebaseio.com/products.json?auth=$token");
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "creatorId": userId,
          }));

      final newProduct = Product(
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price);
      _items!.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final prodIndex = _items!.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse("https://shopapp-aa04e-default-rtdb.firebaseio.com/products/$id.json?auth=$token");
      await http.patch(url, body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          }
      ));
      _items![prodIndex] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse("https://shopapp-aa04e-default-rtdb.firebaseio.com/products/$id.json?auth=$token");
    final existingIndex = _items!.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items![existingIndex];
    _items!.removeAt(existingIndex);    // this product will be deleted from list but still in memory cz there is a variable that reference to it
    notifyListeners();
    final response = await http.delete(url);
      print(response.statusCode);
      if(response.statusCode >= 400){
        _items!.insert(existingIndex, existingProduct);
        notifyListeners();
        throw const HttpException("Could not delete product !");   // throw like return it stops the execution
      }
      existingProduct = null;           // to remove this reference from memory if deletion was successful
  }
}
