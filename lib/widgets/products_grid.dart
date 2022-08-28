import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';


class ProductsGrid extends StatelessWidget {

  final bool isFav;

  const ProductsGrid({
    Key? key, required this.isFav
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = isFav? productsData.favProducts : productsData.items;
    log("productsData.favProducts ${productsData.favProducts.length}, productsData.items:${productsData.items.length}");
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10, // space between columns
        mainAxisSpacing: 10, // space between rows
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: products[index],
        child:  const ProductItem(
            // id: products[index].id,
            // title: products[index].title,
            // imageUrl: products[index].imageUrl
            ),
      ),
      itemCount: products.length,
    );
  }
}