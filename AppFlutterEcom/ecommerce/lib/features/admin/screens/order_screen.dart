import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mecommerce/common/widgets/loader.dart';
import 'package:mecommerce/features/account/widgets/single_product.dart';
import 'package:mecommerce/features/admin/services/admin_services.dart';
import 'package:mecommerce/features/order_details/screens/order_details.dart';
import 'package:mecommerce/models/order.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order>? orders;
  List<Order>? newOrders;
  var loggedinUser;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    fetchOrders();
    super.initState();
  }

  void fetchOrders() async {
    orders = await adminServices.fetchAllOrders(context);
    loggedinUser = Provider.of<UserProvider>(context, listen: false).user;
    newOrders = orders!
        .where((element) => element.assignedUserId == loggedinUser.id)
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return orders == null || loggedinUser == null
        ? const Loader()
        : GridView.builder(
            itemCount: loggedinUser.type == "deliver"
                ? newOrders!.length
                : orders!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, index) {
              final orderData = loggedinUser.type == "deliver"
                  ? newOrders![index]
                  : orders![index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    OrderDetailScreen.routeName,
                    arguments: orderData,
                  );
                },
                child: SizedBox(
                  height: 140,
                  child: SingleProduct(
                    image: orderData.products[0].images[0],
                  ),
                ),
              );
            },
          );
  }
}
