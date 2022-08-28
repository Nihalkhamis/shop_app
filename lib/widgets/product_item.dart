import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   final product = Provider.of<Product>(context, listen: false);
   final cart = Provider.of<Cart>(context, listen: false);
   final auth = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: GridTile(
        footer: GridTileBar(
          title: Text(product.title?? "", textAlign: TextAlign.center),
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(     // consumer let only this widget rerun not the whole build
              builder:( ctx, product, child) =>     // child here to when we has widget inside Consumer but we do not want to change it(rerun it)
             IconButton(
                icon: Icon(product.isFav ? Icons.favorite : Icons.favorite_border,
                    color: Theme.of(context).accentColor),
                onPressed: () {
                  // await Provider.of<Products>(context, listen: false).favTheProduct(product.id!, product);
                  product.toggleFavStatus(auth.token!, auth.userId);
                }
            ),
          ),
          trailing: IconButton(
              icon: Icon(Icons.shopping_cart,
                  color: Theme.of(context).accentColor),
              onPressed: () {
                cart.addItem(product.id!, product.title!, product.price!);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content:
                  const Text("Item added to cart", textAlign: TextAlign.center,),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(label: "UNDO", onPressed: (){
                      cart.removeItem(product.id!);
                    }),
                  )

                );
              }
          ),
        ),
        child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
                  ProductDetailScreen.routeName,
                  arguments: product.id,
                ),
            child: Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}
