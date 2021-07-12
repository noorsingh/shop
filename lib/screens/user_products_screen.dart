import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgets/main_drawer.dart';

import '../widgets/user_product_item.dart';
import '../providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routename = '/user-product-screen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => RefreshIndicator(
          onRefresh: () => _refreshProducts(context),
          child: snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Consumer<Products>(
                  builder: (ctx, prodData, _) {
                    final List<Product> products = prodData.items;
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: prodData.itemCount,
                        itemBuilder: (_, i) => Column(
                          children: [
                            UserProductItem(products[i]),
                            const Divider(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
