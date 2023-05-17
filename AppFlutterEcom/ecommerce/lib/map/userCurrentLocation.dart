import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/features/auth/services/auth_service.dart';
import 'package:mecommerce/models/order.dart';
import 'package:mecommerce/providers/location_provider.dart';
import 'package:mecommerce/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '../features/admin/model/user.dart';

class UserCurrentMapScreen extends StatefulWidget {
  Map<String, String> clientL;
  User admin;
  Order? order;
  UserCurrentMapScreen(
      {required this.clientL, required this.admin, required this.order});
  static const String id = 'map-screen';
  @override
  _UserCurrentMapScreenState createState() => _UserCurrentMapScreenState();
}

class _UserCurrentMapScreenState extends State<UserCurrentMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Geolocator? _geolocator;
  Position? _position;
  LatLng? currentLocation;
  LatLng? destination;
  LatLng? myLocation;
  LatLng? sourceLocation;
  late GoogleMapController _mapController;
  bool _locating = false;
  bool _loggedIn = false;
  bool isLoading = true;

  String? uid;
  String? phonep;
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then(
      (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/marker.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/marker.png")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  List<LatLng> polylineCoordinates = [];

  changeMapCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            zoom: 13.5,
            target: LatLng(
                currentLocation!.latitude, currentLocation!.longitude))));

    // updateUserLocation(currentLocation!);
  }

  void getPolyPoints() async {
    print("sorce");
    print(widget.admin.latitude!);
    var prefs = await SharedPreferences.getInstance();
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAvvUP1d_akP1lBpJyBR4ohLFtT3qwWnhE", // Your Google Map Key
      PointLatLng(sourceLocation!.latitude, sourceLocation!.longitude),
      PointLatLng(destination!.latitude, destination!.longitude),
    );
    print("testing");
    print(result.errorMessage);
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
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
      print(data);
      setState(() {
        currentLocation =
            LatLng(double.parse(user.latitude!), double.parse(user.longtude!));
      });
      changeMapCamera();

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

  @override
  void initState() {
    Timer.periodic(new Duration(seconds: 2), (timer) async {
      getUser(widget.order!.assignedUserId);
    });
    //check if user is logged in, while opening map screen
    // setState(() {
    sourceLocation = LatLng(double.parse(widget.admin.latitude!),
        double.parse(widget.admin.longtude!));
    destination = LatLng(double.parse(widget.clientL['latitude']!),
        double.parse(widget.clientL['longitude']!));
    // });
    getPolyPoints();
    // getData();
    // getCurrentUser();
    // setCustomMarkerIcon();

    // final LocationSettings locationSettings = LocationSettings(
    //   accuracy: LocationAccuracy.high,
    // );

    // StreamSubscription<Position> positionStream =
    //     Geolocator.getPositionStream(locationSettings: locationSettings)
    //         .listen((Position? position) {
    //   if (position != null) {
    //     print("my current addres ${position.latitude}");

    //     changeMapCamera();
    //   }
    // });
    super.initState();
  }

  Future<void> updateUserLocation(LatLng position) async {
    AuthService authService = AuthService();
    var userData = Provider.of<UserProvider>(context, listen: false).user;
    print(userData.email);
    final coordinates = new Coordinates(position.latitude, position.longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    authService.updateUserAddress(
        context: context,
        email: userData.email,
        longtude: "${position.longitude}",
        latitude: "${position.latitude}",
        address: addresses.first.addressLine);
  }

  getData() async {
    var prefs = await SharedPreferences.getInstance();
    print(prefs.getDouble("latitude"));
    setState(() {
      myLocation =
          LatLng(prefs.getDouble("latitude")!, prefs.getDouble("longitude")!);
      isLoading = false;
    });
  }

  void getCurrentUser() {
    setState(() {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    var userData = Provider.of<UserProvider>(context).user;
    print("address" + userData.address);
    // final _auth = Provider.of<AuthProvider>(context);
    print(sourceLocation);
    // setState(() {
    //   currentLocation = LatLng(locationData.latitude, locationData.longitude);
    // });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          currentLocation == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GoogleMap(
                  key: widget.key,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation!,
                    zoom: 14.4746,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId("currentLocation"),
                      icon: sourceIcon,
                      position: currentLocation!,
                    ),
                    Marker(
                      markerId: MarkerId("source"),
                      icon: sourceIcon,
                      position: sourceLocation!,
                    ),
                    Marker(
                      markerId: MarkerId("destination"),
                      icon: destinationIcon,
                      position: currentLocation!,
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: const Color(0xFF7B61FF),
                      width: 6,
                    ),
                  },
                  zoomControlsEnabled: false,
                  minMaxZoomPreference: MinMaxZoomPreference(1.5, 20.8),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  mapToolbarEnabled: true,
                  onCameraMove: (CameraPosition position) {
                    setState(() {
                      _locating = true;
                    });
                    locationData.onCameraMove(position);
                  },
                  onMapCreated: (mapController) {
                    _controller.complete(mapController);
                  },
                  onCameraIdle: () {
                    setState(() {
                      _locating = false;
                    });
                    locationData.getMoveCamera();
                  },
                ),
          // Center(
          //   child: Container(
          //     height: 50,
          //     margin: EdgeInsets.only(bottom: 40),
          //     child: Image.asset(
          //       'assets/images/marker.png',
          //       color: Colors.red,
          //     ),
          //   ),
          // ),
        ],
      ),
      // bottomNavigationBar: Container(
      //   height: 200,
      //   width: MediaQuery.of(context).size.width,
      //   color: Colors.white,
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       _locating
      //           ? LinearProgressIndicator(
      //               backgroundColor: Colors.transparent,
      //               valueColor: AlwaysStoppedAnimation<Color>(
      //                   Theme.of(context).primaryColor),
      //             )
      //           : Container(),
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Padding(
      //             padding: const EdgeInsets.only(left: 10, right: 20),
      //             child: TextButton.icon(
      //                 onPressed: () {},
      //                 icon: Icon(
      //                   Icons.location_searching,
      //                   color: Theme.of(context).primaryColor,
      //                 ),
      //                 label: Text(
      //                   _locating
      //                       ? 'Positioning....'
      //                       : locationData.selectedAddress == null
      //                           ? 'Locating...'
      //                           : locationData.selectedAddress.featureName,
      //                   overflow: TextOverflow.ellipsis,
      //                   style: TextStyle(
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 20,
      //                     color: Colors.black,
      //                   ),
      //                 )),
      //           ),
      //           Padding(
      //             padding: EdgeInsets.all(8.0),
      //             child: IconButton(
      //                 onPressed: (() {}), icon: Icon(Icons.image_outlined)),
      //           )
      //         ],
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.only(left: 20, right: 20),
      //         child: Text(
      //           _locating
      //               ? ''
      //               : locationData.selectedAddress == null
      //                   ? ''
      //                   : locationData.selectedAddress.addressLine,
      //           style: TextStyle(color: Colors.black54),
      //         ),
      //       ),
      //       Padding(
      //         padding: const EdgeInsets.all(20.0),
      //         child: SizedBox(
      //           width: MediaQuery.of(context).size.width - 40,
      //           child: AbsorbPointer(
      //             absorbing: _locating ? true : false,
      //             child: TextButton(
      //               style: ButtonStyle(
      //                   backgroundColor: MaterialStateProperty.all(
      //                       GlobalVariables.secondaryColor)),
      //               onPressed: () async {
      //                 AuthService authService = AuthService();
      //                 EasyLoading.show(status: 'Updating Location...');
      //                 await authService.updateUserAddress(
      //                     context: context,
      //                     email: userData.email,
      //                     longtude: "${locationData.longitude}",
      //                     latitude: "${locationData.latitude}",
      //                     address: locationData.selectedAddress.addressLine);

      //                 locationData.savePrefs();

      //                 // if (_loggedIn == false) {
      //                 //   Navigator.pop(context);
      //                 // } else {

      //                 setState(() {
      //                   // _auth.latitude = locationData.latitude;
      //                   // _auth.longitude=locationData.longitude;
      //                   // _auth.address = locationData.selectedAddress.addressLine;
      //                   // _auth.location =locationData.selectedAddress.featureName;
      //                 });
      //                 // FirebaseFirestore.instance.collection('users').doc('$uid').update({
      //                 //   'latitude' : _auth.latitude,
      //                 //   'longitude' : _auth.longitude,
      //                 //   'address' : _auth.address,
      //                 //   'location' : _auth.location,

      //                 // }).then((value){
      //                 EasyLoading.showSuccess('Location updated successfully');
      //                 Navigator.pop(context);
      //                 // });
      //                 // }
      //               },
      //               // color:_locating ? Colors.grey :Theme.of(context).primaryColor,
      //               child: Text(
      //                 'CONFIRM LOCATION',
      //                 style: TextStyle(color: Colors.white),
      //               ),
      //             ),
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
