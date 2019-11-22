import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final product = productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: product.length,
      itemBuilder: (ctx, i) => ProductItem(
        product[i].id,
        product[i].title,
        product[i].imageUrl,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}