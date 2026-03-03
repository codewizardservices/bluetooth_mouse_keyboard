import 'dart:io';


import 'package:flutter/material.dart';
import 'package:bluetoothairmousekeyboard/extra/constants.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/constant_inapps.dart';

//=============================================================

//=============================================================

//=============================================================

const String subscriptionInfo =
    '''• Your payment will be charged to your iTunes Account as soon as you confirm your purchase.\n
• You can manage your subscriptions and turn off auto-renewal from your Account Settings after the purchase.\n
• Your subscription will renew automatically, unless you turn off auto-renew at least 24 hours before the end of the current period.\n
• The cost of renewal will be charged to your account in the 24 hours prior to the end of the current period.\n
• When cancelling a subscription, your subscription will stay active until the end of the period. Auto-renewal will be disabled, but the current subscription will not be refunded.\n
• Any unused portion of a free trial period, if offered, will be forfeited when purchasing a subscription.\n''';

const subscriptionLink =
    "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/";
const String termOfUse = 'Term of Use';

Widget getSubscriptionInfoView() {
  return const Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: InAppConstants.defaultPadding * 1.5,
    ),
    child: Text(
      subscriptionInfo,
      style: const TextStyle(fontSize: 14, height: 1.5),
    ),
  );
}

Widget getTermConditionView(context) {
  return Platform.isIOS
      ? Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
        child: InkWell(
          onTap: () {
            Constants.openUrlSite(context, subscriptionLink);
          },
          child: const Text(
            termOfUse,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      )
      : const SizedBox();
}

const boldStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 17);
