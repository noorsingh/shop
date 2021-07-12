import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://qlonz.com/wp-content/uploads/2019/01/left-line-Red.jpeg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://contents.mediadecathlon.com/p1537814/0c2ea16bad027fec4f4d40daad436dd0/p1537814.jpg?f=1000x1000&format=auto',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://www.ikea.com/in/en/images/products/kavalkad-frying-pan-black__0710333_pe727481_s5.jpg',
    // ),
  ];

  final String _authToken;
  final String _userId;

  Products(this._authToken, this._userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  int get itemCount {
    return _items.length;
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    var url =
        'https://shop-74922-default-rtdb.firebaseio.com/products.json?auth=$_authToken&$filterString';
    try {
      final responseData = await http.get(Uri.parse(url));
      final response = json.decode(responseData.body) as Map<String, dynamic>;
      if (response == null) {
        _items = [];
        return;
      }
      url =
          'https://shop-74922-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken';
      final favoriteData = await http.get(Uri.parse(url));
      final favoriteResponse = json.decode(favoriteData.body);
      final List<Product> products = [];
      response.forEach((prodId, product) {
        products.add(Product(
          id: prodId,
          title: product['title'],
          description: product['description'],
          price: product['price'],
          imageUrl: product['imageUrl'],
          isFavorite: favoriteResponse == null
              ? false
              : favoriteResponse[prodId] ?? false,
          // ?? ==> favRes[id] == null ? false : favRes[id],
        ));
      });
      _items = products;
      notifyListeners();
    } catch (error) {
      print('$error in fetchProducts');
    }
  }

  Future<void> addProduct(
    String title,
    String des,
    String price,
    String imgUrl,
    bool isFav,
  ) async {
    final url =
        'https://shop-74922-default-rtdb.firebaseio.com/products.json?auth=$_authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'title': title,
          'description': des,
          'imageUrl': imgUrl,
          'price': num.parse(price),
          'creatorId': _userId,
        }),
      );
      _items.add(Product(
        id: json.decode(response.body)['name'],
        title: title,
        description: des,
        price: num.parse(price),
        imageUrl: imgUrl,
      ));
      notifyListeners();
    } catch (error) {
      print('$error in addProduct');
      // throw error
    }
  }

  Future<void> updateProduct(
    String id,
    String title,
    String des,
    String price,
    String imgUrl,
  ) async {
    final url =
        'https://shop-74922-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken';
    try {
      await http.patch(
        Uri.parse(url),
        body: json.encode({
          'title': title,
          'description': des,
          'imageUrl': imgUrl,
          'price': num.parse(price),
        }),
      );
      final index = _items.indexWhere((prod) => prod.id == id);
      _items[index] = Product(
        title: title,
        description: des,
        price: num.parse(price),
        imageUrl: imgUrl,
        id: id,
      );
      notifyListeners();
    } catch (error) {
      print('$error in updateProduct');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shop-74922-default-rtdb.firebaseio.com/products/$id.json?auth=$_authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      // throw HttpException('Could not delete product.');
      print('Error 400 in deleteProduct');
    }
    existingProduct = null;
  }
}
