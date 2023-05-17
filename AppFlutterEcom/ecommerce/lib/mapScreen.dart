import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mecommerce/common/widgets/loader.dart';
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/features/auth/services/auth_service.dart';
import 'package:mecommerce/providers/location_provider.dart';
import 'package:mecommerce/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MapScreen extends StatefulWidget {
  static const String id = 'map-screen';
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng currentLocation = LatLng(-1.9367, 30.0535);
  late GoogleMapController _mapController;
  bool _locating = false;
  bool _loggedIn = false;
  bool isLoading = true;

  String? uid;
  String? phonep;
  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCfMLKy2k3ToMLF-PBSt-snpfjSOR8efMM", // Your Google Map Key
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  // changeMapCamera() async {
  //   GoogleMapController googleMapController = await _mapController.future;
  //   googleMapController.animateCamera(CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //           zoom: 13.5,
  //           target: LatLng(
  //               currentLocation!.latitude, currentLocation!.longitude))));

  //   // updateUserLocation(currentLocation!);
  // }

  @override
  void initState() {
    //check if user is logged in, while opening map screen
    getData();
    getCurrentUser();

    super.initState();
  }

  getData() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (position != null) {
      final locationData =
          Provider.of<LocationProvider>(context, listen: false);
      locationData.latitude = position.latitude;
      locationData.longitude = position.longitude;
      setState(() {
        currentLocation =
            LatLng(locationData.latitude!, locationData.longitude!);
      });

      final coordinates =
          new Coordinates(locationData.latitude, locationData.longitude);
      final addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      locationData.selectedAddress = addresses.first;
      print(addresses.first.addressLine);
    }
  }

  void getCurrentUser() {
    setState(() {
      // getData();
    });
    // if (user != null) {
    //   setState(() {
    //     _loggedIn = true;
    //   });
    // }
  }

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    print(locationData);
    // locationData.getCurrentPosition();
    var userData = Provider.of<UserProvider>(context).user;
    // final _auth = Provider.of<AuthProvider>(context);

    setState(() {
      // currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    void onCreated(GoogleMapController controller) {
      setState(() {
        _mapController = controller;
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          locationData == null || currentLocation == null
              ? Loader()
              : GoogleMap(
                  key: widget.key,
                  initialCameraPosition: CameraPosition(
                    target: currentLocation,
                    zoom: 14.4746,
                  ),
                  // markers: {
                  //   const Marker(
                  //     markerId: MarkerId("source"),
                  //     position: sourceLocation,
                  //   ),
                  //   const Marker(
                  //     markerId: MarkerId("destination"),
                  //     position: destination,
                  //   ),
                  // },
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
                  onMapCreated: onCreated,
                  onCameraIdle: () {
                    setState(() {
                      _locating = false;
                    });
                    locationData.getMoveCamera();
                  },
                ),
          Center(
            child: Container(
              height: 50,
              margin: EdgeInsets.only(bottom: 40),
              child: Image.asset(
                'assets/images/marker.png',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _locating
                ? LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 20),
                  child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.location_searching,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        _locating
                            ? 'Positioning....'
                            : locationData.selectedAddress == null
                                ? 'Locating...'
                                : locationData.selectedAddress.featureName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: (() {}), icon: Icon(Icons.image_outlined)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                _locating
                    ? ''
                    : locationData.selectedAddress == null
                        ? ''
                        : locationData.selectedAddress.addressLine,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: AbsorbPointer(
                  absorbing: _locating ? true : false,
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            GlobalVariables.secondaryColor)),
                    onPressed: () async {
                      AuthService authService = AuthService();
                      EasyLoading.show(status: 'Updating Location...');
                      await authService.updateUserAddress(
                          context: context,
                          email: userData.email,
                          longtude: "${locationData.longitude}",
                          latitude: "${locationData.latitude}",
                          address: locationData.selectedAddress.addressLine);

                      locationData.savePrefs();

                      // if (_loggedIn == false) {
                      //   Navigator.pop(context);
                      // } else {

                      setState(() {
                        // _auth.latitude = locationData.latitude;
                        // _auth.longitude=locationData.longitude;
                        // _auth.address = locationData.selectedAddress.addressLine;
                        // _auth.location =locationData.selectedAddress.featureName;
                      });
                      // FirebaseFirestore.instance.collection('users').doc('$uid').update({
                      //   'latitude' : _auth.latitude,
                      //   'longitude' : _auth.longitude,
                      //   'address' : _auth.address,
                      //   'location' : _auth.location,

                      // }).then((value){
                      EasyLoading.showSuccess('Location updated successfully');
                      Navigator.pop(context);
                      // });
                      // }
                    },
                    // color:_locating ? Colors.grey :Theme.of(context).primaryColor,
                    child: Text(
                      'CONFIRM LOCATION',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}