import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {

  // final String title;

  static const routeName = "product-detail";

  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProduct = Provider.of<Products>(context, listen: false).getById(productId);   // listen here to rebuild build() when changes occur if we set it ture
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
            height: 300,
            width: double.infinity,
            child: Image.network(loadedProduct.imageUrl!, fit: BoxFit.cover),
          ),
            const SizedBox(height: 10,),
            Text("\$${loadedProduct.price}", style: const TextStyle(color: Colors.grey, fontSize: 20),),
            const SizedBox(height: 10,),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(loadedProduct.description!, textAlign: TextAlign.center, softWrap: true),
            ),
          ],
        ),
      ),

    );
  }
}
