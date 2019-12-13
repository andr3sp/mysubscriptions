import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:subscriptions/data/entities/renewal.dart';
import 'package:subscriptions/presentations/create_subscription/create_subscription_screen.dart';
import 'package:subscriptions/presentations/home_tab_menu/home_tab_bar_screen.dart';
import 'package:subscriptions/presentations/renewal_detail/subscription_detail_screen.dart';

class NavigationManager {
  static void navigateToHomeScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeTabMenuScreen()),
    );
  }

  static Future<bool> navigateToAddSubscription(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateSubscriptionScreen()),
    );
  }

  static void navigateToRenewalDetail(BuildContext context, Renewal renewal) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SubscriptionDetail(
                renewal: renewal,
              )),
    );
  }

  static void popView(BuildContext context, {bool result = false}) {
    Navigator.pop(context, result);
  }
}
