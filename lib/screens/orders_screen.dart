import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/main_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "orders";

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // var _isLoading = false;
  late Future _ordersFuture;

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);   // here will occur an infinite loop cz build() will be called several time when fetchAndSetOrders() (when it existed inside builder() before calling _obtainOrdersFuture()) is calling cz of the notifyListeners() so Consumer will be the solution in case we are in statelessWidget
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(title: const Text("Orders")),
      body: FutureBuilder(future: _ordersFuture, builder:
      (ctx, dataSnapshot) {
        if(dataSnapshot.connectionState == ConnectionState.waiting){
         return const Center(
              child: CircularProgressIndicator());
        }
        else{
          if(dataSnapshot.error != null){
          return  const Center(child: Text("An error occur"),);
          }
          else{
           return Consumer<Orders>(
             builder: (ctx, ordersData, child) =>
             ListView.builder(
                itemBuilder: (ctx, index) =>
                    OrderItem(orderItem: ordersData.orders[index]),
                itemCount: ordersData.orders.length,
              ),
           );
          }
        }
      },)
    );
  }

  Future _obtainOrdersFuture(){
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();    // this will let fetchAndSetOrders() be called once
    super.initState();
    // Future.delayed(Duration.zero).then((_) async {
    //   setState(() {
        //_isLoading = true;
     // });
     //  Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) =>  setState(() {
     //    _isLoading = false;
     //  }));                       // listen must be false, instead an error occur

    // });
  }
}
