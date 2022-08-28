import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final DateTime date;
  final List<CartItem> products;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.date,
      required this.products});
}

class Orders with ChangeNotifier {

  final String? token;
  List<OrderItem>? _orders = [];

  final String? userId;

  List<OrderItem> get orders {
    return [..._orders?? []];
  }

  Orders(this.token, this._orders, this.userId);

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        "https://shopapp-aa04e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token");
    final response = await http.get(url);
    print("Response of fetching orders----> ${json.decode(response.body)}");
    final List<OrderItem> loadedData = [];
    if(json.decode(response.body) == null){
      return;
    }
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    extractedData.forEach((orderId, orderData) {
      loadedData.add(
        OrderItem(id: orderId, amount: orderData["amount"], date: DateTime.parse(orderData["date"]),
            products: (orderData["products"] as List<dynamic>).map((cartItem) =>
            CartItem(id: cartItem["id"], title: cartItem["title"], quantity: cartItem["quantity"], price: cartItem["price"])
            ).toList(),
        ),
      );
    });
    _orders = loadedData.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        "https://shopapp-aa04e-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token");
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: jsonEncode({
          "amount": total,
          "date": timeStamp.toIso8601String(),
          "products": cartProducts
              .map((cartProd) => {
                    "id": cartProd.id,
                    "title": cartProd.title,
                    "quantity": cartProd.quantity,
                    "price": cartProd.price,
                  })
              .toList(),
        }));
    // print(json.decode(response.body));
    _orders?? [].insert(
        0,
        OrderItem(
            id: json.decode(response.body)["name"],
            amount: total,
            date: timeStamp,
            products: cartProducts));
    notifyListeners();
  }
}
