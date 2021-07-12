import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/main_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders-screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  @override
  void initState() {
    super.initState();
    // This here, so that if something else in any case call setState(),
    // which do not affetcs the orders,
    // so to then avoid the fetchOrders() http get request again.
    _ordersFuture = Provider.of<Orders>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: MainDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('An error occured'),
              );
            }
            return (Provider.of<Orders>(context, listen: false).itemCount == 0)
                ? Center(
                    child: Text(
                      'No orders yet !!',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  )
                : Consumer<Orders>(
                    builder: (ctx, orderData, child) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                    ),
                  );
          },
        ));
  }
}
