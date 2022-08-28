import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Container(
          //   color: Theme.of(context).accentColor,
          //   padding: const EdgeInsets.all(20),
          //   height: 120,
          //   width: double.infinity,
          //   child: Text("ShopApp", style: TextStyle(
          //     fontSize: 20,
          //     color: Theme.of(context).primaryColor,
          //     fontWeight: FontWeight.w900,
          //   )),
          // ),
          AppBar(
            title: const Text("ShopApp"),
            automaticallyImplyLeading: false,    // to not showing the back button
          ),
          const Divider(),
          ListTile(
            title: const Text("Shop"),
            leading: const Icon(Icons.shop),
            onTap: (){
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
         const Divider(),
          ListTile(
            title: const Text("Orders"),
             leading: const Icon(Icons.payment),
             onTap: (){
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
             },
          ),
          const Divider(),
          ListTile(
            title: const Text("Manage products"),
             leading: const Icon(Icons.edit),
             onTap: (){
              Navigator.of(context).pushReplacementNamed(UserProductsScreen.routeName);
             },
          ),
          const Divider(),
          ListTile(
            title: const Text("Logout"),
             leading: const Icon(Icons.exit_to_app),
             onTap: (){
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/");
             Provider.of<Auth>(context, listen: false).logout();
             },
          ),
        ],
      ),
    );
  }
}
