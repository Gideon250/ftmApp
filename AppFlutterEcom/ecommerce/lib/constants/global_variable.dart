import 'package:flutter/material.dart';

String uri = 'http://192.168.80.52:4000';

class GlobalVariables {
  // COLORS
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 204, 183, 172),
      Color.fromARGB(255, 159, 172, 139),
    ],
    stops: [0.5, 1.0],
  );

  static const secondaryColor = Color.fromRGBO(255, 153, 0, 1);
  static const backgroundColor = Colors.white;
  static const Color greyBackgroundCOlor = Color(0xffebecee);
  static var selectedNavBarColor = const Color.fromRGBO(255, 153, 0, 1);
  static const unselectedNavBarColor = Colors.black87;

  // STATIC IMAGES
  static const List<String> carouselImages = [
    'https://res.cloudinary.com/gigi-250/image/upload/v1682411546/plkk5roibdnxxth1npnu.jpg',
    'https://res.cloudinary.com/gigi-250/image/upload/v1678490753/aagoj9mrgibeytqgdnfd.jpg',
    'https://res.cloudinary.com/gigi-250/image/upload/v1682411666/t32en1v1okaj1bxiujgr.jpg',
    'https://res.cloudinary.com/gigi-250/image/upload/v1675684876/ivjkg3m50ylemyisvek0.jpg',
    'https://res.cloudinary.com/gigi-250/image/upload/v1682412148/wajnxxejfqrzzzugrcee.webp',
  ];

  static const List<Map<String, String>> categoryImages = [
    {
      'title': 'Exotic',
      'image': 'assets/images/CitrusIcon.png',
    },
    {
      'title': 'Vegets',
      'image': 'assets/images/veget.png',
    },
    {
      'title': 'Tomato',
      'image': 'assets/images/TomatoIcon.jpg',
    },
    {
      'title': 'Tropical',
      'image': 'assets/images/fruits.png',
    },
    {
      'title': 'LeafyGreen',
      'image': 'assets/images/leafgree.png',
    },
  ];
}
