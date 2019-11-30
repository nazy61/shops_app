import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Loading...'),
                ],
              ),
            );
          } else {
            if (dataSnapshot.error != null) {
              //handle errors
              return Center(
                child: Text('An Error Occured!'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) {
                  return orderData.orders.length <= 0
                      ? Center(
                          child: Text(
                            'No Order Placed\nPlease Place a New Order',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx, i) =>
                              OrderItem(orderData.orders[i]),
                        );
                },
              );
            }
          }
        },
      ),
    );
  }
}
