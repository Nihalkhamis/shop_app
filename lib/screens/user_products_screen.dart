import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/Edit_product_screen.dart';
import '../widgets/main_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "user-products";

  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<Products>(context);   // to avoid infinite loop
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text("All Products"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, dataSnapshot) => dataSnapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator(),) : RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: Consumer<Products>(
            builder: (ctx, products, _) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemBuilder: (ctx, index) => Column(
                  children: [
                    UserProductItem(
                        id: products.items[index].id!,
                        title: products.items[index].title!,
                        imageUrl: products.items[index].imageUrl!),
                    const Divider(),
                  ],
                ),
                itemCount: products.items.length,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
