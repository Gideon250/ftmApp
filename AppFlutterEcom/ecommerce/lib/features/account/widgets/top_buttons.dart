import 'package:flutter/material.dart';
import 'package:mecommerce/features/account/services/account_services.dart';
import 'package:mecommerce/features/account/widgets/account_button.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AccountButton(
              text: 'Log Out',
              onTap: () => AccountServices().logOut(context),
            ),
            // AccountButton(
            //   text: 'Your Wish List',
            //   onTap: () {},
            // ),
          ],
        ),
      ],
    );
  }
}
