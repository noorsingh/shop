import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';

import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: product.id,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, ch, ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) {
                  return ch;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes == null
                        ? null
                        : loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes,
                  ),
                );
              },
              errorBuilder: (ctx, exception, stackTrace) =>
                  Center(child: Text('Invalid Image')),
            ),
          ),
          onTap: () => Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: product.id,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: FavIcon(),
          title: Text(product.title),
          trailing: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added to Cart!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingle(product.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

//
//
//
//
//

class FavIcon extends StatefulWidget {
  @override
  _FavIconState createState() => _FavIconState();
}

class _FavIconState extends State<FavIcon> {
  var _isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    return Consumer<Product>(
      builder: (ctx, prod, ch) => _isLoading
          ? Center(child: CircularProgressIndicator())
          : IconButton(
              icon: Icon(
                prod.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await prod.toggleFavoriteStatus(
                  auth.userId,
                  auth.token,
                );
                setState(() {
                  _isLoading = false;
                });
              },
            ),
    );
  }
}
