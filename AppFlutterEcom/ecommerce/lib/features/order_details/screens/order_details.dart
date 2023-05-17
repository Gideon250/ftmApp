import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mecommerce/api/pdf_receipt_api.dart';
import 'package:mecommerce/common/widgets/custom_button.dart';
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/features/admin/services/admin_services.dart';
import 'package:mecommerce/features/search/screens/search_screen.dart';
import 'package:mecommerce/map/userCurrentLocation.dart';
import 'package:mecommerce/models/order.dart';
import 'package:mecommerce/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../../../api/pdf_api.dart';
import '../../../api/pdf_report_api.dart';
import '../../../map/userMap.dart';
import '../../admin/model/user.dart';

class OrderDetailScreen extends StatefulWidget {
  static const String routeName = '/order-details';
  final Order order;
  const OrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isLoading = false;
  int currentStep = 0;
  final AdminServices adminServices = AdminServices();

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  User? selectedUser;
  User? clientUser;
  User? adminUser;

  List<User> usersList = <User>[];
  getUsers() async {
    setState(() {
      isLoading = true;
    });
    var request = http.Request('GET', Uri.parse('$uri/users'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = convert.jsonDecode(await response.stream.bytesToString());
      for (var item in data['users']) {
        User user = User.fromJson(item);
        setState(() {
          usersList.add(user);
        });
      }
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase);
      print("heelo");
    }
  }

  getUser(String id) async {
    setState(() {
      isLoading = true;
    });
    var request = http.Request('GET', Uri.parse('$uri/user/$id'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = convert.jsonDecode(await response.stream.bytesToString());
      User user = User.fromJson(data);

      setState(() {
        selectedUser = user;
      });

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase);
      print("heelo");
    }
  }

  getClient() async {
    setState(() {
      isLoading = true;
    });
    var request =
        http.Request('GET', Uri.parse('$uri/user/${widget.order.userId}'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = convert.jsonDecode(await response.stream.bytesToString());
      User user = User.fromJson(data);
      setState(() {
        clientUser = user;
      });
      print(data);

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase);
      print("heelo");
    }
  }

  adminInfo() async {
    setState(() {
      isLoading = true;
    });
    var request = http.Request('GET', Uri.parse('$uri/users/admin'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = convert.jsonDecode(await response.stream.bytesToString());
      print(data);
      User user = User.fromJson(data);
      setState(() {
        adminUser = user;
      });

      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase);
      print("heelo");
    }
  }

  assignuser(String id) async {
    print("hello user" + id);
    setState(() {
      isLoading = true;
    });
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('$uri/api/order/${widget.order.id}/assignUser'));
    request.body = json.encode({"assignedUserId": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      getUser(id);
    } else {
      setState(() {
        isLoading = false;
      });
      print(response.reasonPhrase);
      print("noo");
    }
  }

  @override
  void initState() {
    print("helllo ${widget.order.status} ");
    getUsers();
    getClient();
    getUser(widget.order.assignedUserId);
    adminInfo();
    super.initState();
    print(widget.order.status);
    currentStep = widget.order.status >= 3 ? 2 : widget.order.status;
  }

  // !!! ONLY FOR ADMIN!!!
  void changeOrderStatus(int status) {
    adminServices.changeOrderStatus(
      context: context,
      status: status + 1,
      order: widget.order,
      onSuccess: () {
        setState(() {
          currentStep += 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    print(currentStep);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      onFieldSubmitted: navigateToSearchScreen,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(
                              left: 6,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        hintText: 'Search product',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(Icons.mic, color: Colors.black, size: 25),
              ),
            ],
          ),
        ),
      ),
      body: isLoading == true
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'View order details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Date:      ${DateFormat().format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    widget.order.orderedAt),
                              )}'),
                              Text('Order ID:          ${widget.order.id}'),
                              Text(
                                  'Order Total:      ${widget.order.totalPrice}\Rwf'),
                            ],
                          ),
                          if (user.type.toString() == "user")
                            IconButton(
                                onPressed: () async {
                                  final pdfFile = await PdfReceiptApi.generate(
                                      widget.order);

                                  PdfApi.openFile(pdfFile);
                                },
                                icon: Icon(Icons.receipt))
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Purchase Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          for (int i = 0; i < widget.order.products.length; i++)
                            Row(
                              children: [
                                Image.network(
                                  widget.order.products[i].images[0],
                                  height: 120,
                                  width: 120,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.order.products[i].name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${widget.order.quantity[i]}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'User Location',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("${clientUser!.address!}"),
                              IconButton(
                                icon: Icon(Icons.location_on),
                                onPressed: () {
                                  if (user.type.toString() == "user") {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: ((context) {
                                      return UserCurrentMapScreen(
                                        clientL: {
                                          "latitude": clientUser!.latitude!,
                                          "longitude": clientUser!.longtude!
                                        },
                                        admin: adminUser!,
                                        order: widget.order,
                                      );
                                    })));
                                  } else {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: ((context) {
                                      return UserMapScreen(clientL: {
                                        "latitude": clientUser!.latitude!,
                                        "longitude": clientUser!.longtude!
                                      }, admin: adminUser!);
                                    })));
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (user.type.toString() != "deliver")
                            ListTile(
                              title: selectedUser == null ? Text("Selete Deliverer"): Text(selectedUser != null
                                  ? selectedUser!.name!
                                  : ""),
                              subtitle: Text(selectedUser != null
                                  ? selectedUser!.email!
                                  : ""),
                              trailing: user.type.toString() != "admin"
                                  ? Text('')
                                  : IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: ((context) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: const Text(
                                                      'Select the Deriverer',
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 400,
                                                    child: ListView.builder(
                                                        itemCount:
                                                            usersList.length,
                                                        itemBuilder:
                                                            ((context, index) {
                                                          return Card(
                                                            child: ListTile(
                                                              title: Text(
                                                                  usersList[
                                                                          index]
                                                                      .name!),
                                                              subtitle: Text(
                                                                  usersList[
                                                                          index]
                                                                      .email!),
                                                              leading: Icon(Icons
                                                                  .account_box),
                                                              trailing:
                                                                  IconButton(
                                                                icon: Icon(
                                                                    Icons.edit),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  assignuser(
                                                                      usersList[
                                                                              index]
                                                                          .sId!);
                                                                  // print(usersList[index]
                                                                  //     .sId);
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        })),
                                                  ),
                                                ],
                                              );
                                            }));
                                      },
                                    ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Tracking',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.type == 'user')
                          TextButton(
                              onPressed: () {
                                changeOrderStatus(2);
                              },
                              child: Text("Receive"))
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Column(
                        children: [
                          currentStep > 0
                              ? ListTile(
                                  leading: Icon(
                                    Icons.check,
                                    color: Colors.red,
                                  ),
                                  title: Text("Pending"),
                                )
                              : ListTile(
                                  title: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.amber)),
                                      onPressed: () {
                                        changeOrderStatus(0);
                                      },
                                      child: Text(
                                        "Start Delivery",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ),
                          if (user.type == 'admin' ||
                              (user.type == 'user' && currentStep > 2))
                            currentStep > 2
                                ? ListTile(
                                    leading: Icon(
                                      Icons.check,
                                      color: Colors.red,
                                    ),
                                    title: Text("Completed"),
                                  )
                                : ListTile(
                                    title: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.amber)),
                                        onPressed: () {
                                          changeOrderStatus(2);
                                        },
                                        child: Text(
                                          "Mark as Completed",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ),
                          if (user.type == 'user' ||
                              (user.type == 'admin' && currentStep > 1))
                            currentStep > 1
                                ? ListTile(
                                    leading: Icon(
                                      Icons.check,
                                      color: Colors.red,
                                    ),
                                    title: Text("Received"),
                                  )
                                : ListTile(
                                    title: TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.amber)),
                                        onPressed: () {
                                          changeOrderStatus(1);
                                        },
                                        child: Text(
                                          "Receive",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ),
                        ],
                      ),
                      // child: Stepper(
                      //   currentStep: user.type == 'user'
                      //       ? currentStep >= 3
                      //           ? 1
                      //           : currentStep
                      //       : currentStep >= 3
                      //           ? 1
                      //           : currentStep,
                      //   controlsBuilder: (context, details) {
                      //     if ((user.type == 'admin' && currentStep < 3)) {
                      //       return CustomButton(
                      //         text: 'Done',
                      //         onTap: () =>
                      //             changeOrderStatus(details.currentStep),
                      //       );
                      //     }
                      //     return const SizedBox();
                      //   },
                      //   steps: [
                      //     Step(
                      //       title: const Text('Pending'),
                      //       content: const Text(
                      //         'Your order is yet to be delivered',
                      //       ),
                      //       isActive: currentStep > 0,
                      //       state: currentStep > 0
                      //           ? StepState.complete
                      //           : StepState.indexed,
                      //     ),
                      //     Step(
                      //       title: const Text('Completed'),
                      //       content: const Text(
                      //         'Your order has been delivered, you are yet to sign.',
                      //       ),
                      //       isActive: currentStep > 1,
                      //       state: currentStep > 1
                      //           ? StepState.complete
                      //           : StepState.indexed,
                      //     ),
                      //     if (user.type == 'user')
                      //       Step(
                      //         title: const Text('Received'),
                      //         content: const Text(
                      //           'Your order has been delivered and signed by you.',
                      //         ),
                      //         isActive: currentStep > 2,
                      //         state: currentStep > 2
                      //             ? StepState.complete
                      //             : StepState.indexed,
                      //       )
                      //     // Step(
                      //     //   title: const Text('Delivered'),
                      //     //   content: const Text(
                      //     //     'Your order has been delivered and signed by you!',
                      //     //   ),
                      //     //   isActive: currentStep > 3,
                      //     //   state: currentStep > 3
                      //     //       ? StepState.complete
                      //     //       : StepState.indexed,
                      //     // ),
                      //   ],
                      // ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
