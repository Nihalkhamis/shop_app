import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../screens/cart_screen.dart';
import '../widgets/main_drawer.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isFav = false;
  var _isInit = true;
  var _isLoading = false;


  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<Products>(context, listen: false)
      //     .fetchAndSetProducts()
      //     .then((_) {
      //   log("-----------------------------");
      //   setState(() {
      //     _isLoading = false;
      //   });
      // });
   // });
    // Provider.of<Products>(context).fetchAndSetProducts();    // wont work
    // Future.delayed(Duration.zero).then((value) => Provider.of<Products>(context).fetchAndSetProducts());    // will work, this is workaround
  }

  @override
  void didChangeDependencies() {
    final products = Provider.of<Products>(context);
   if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      products.fetchAndSetProducts().then((value) {
      // Provider.of<Products>(context).fetchAndSetProducts().then((value) {
        // log("-----------------------------$value");
        // log("-----------------------------${Provider.of<Products>(context, listen: false).items}");
        setState(() {
          _isLoading = false;
        });
      });
   }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final products = Provider.of<Products>(context);
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text("ShopApp"),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value == FilterOptions.favorites) {
                  // products.showFavoritesOnly();
                  _isFav = true;
                } else {
                  // products.showAllProducts();
                  _isFav = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterOptions.favorites,
                child: Text("only favorites"),
              ),
              const PopupMenuItem(
                value: FilterOptions.all,
                child: Text("all products"),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cart, ch) => Badge(
              value: cart.getItemCount.toString(),
              child: ch,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(isFav: _isFav),
    );
  }
}
