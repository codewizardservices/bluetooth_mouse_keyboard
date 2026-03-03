class Notes {
  //todo put all the below code in Info.plist file (IOS => Runner => Info.plist)

  //todo app app ids for admob
  // <key>GADApplicationIdentifier</key>
  // <string>ca-app-pub-3940256099942544~3347511713</string>

  //todo GDPR consent
  // <key>GADDelayAppMeasurementInit</key>
  // <true/>
  // <key>GADIsAdManagerApp</key>
  // <true/>
  //
  // <key>NSUserTrackingUsageDescription</key>
  // <string>We use this identifier to facilitate the delivery of personalized advertising.</string>
  // <key>SKAdNetworkItems</key>
  // <array>
  // <dict>

  //todo sk ads network
  // <key>SKAdNetworkIdentifier</key>
  // <string>cstr6suwn9.skadnetwork</string>
  // </dict>
  // </array>

  //todo put all the below code in Manifest file (Android => App => src => main => AndroidManifest.xml)

  //todo manifest tag on top
  // <uses-permission android:name="com.google.android.gms.permission.AD_ID" />

  // todo in application tag
  // <meta-data
  // android:name="com.google.android.gms.ads.APPLICATION_ID"
  // android:value="ca-app-pub-3940256099942544~3347511713"/>
  //
  // <meta-data android:name="com.google.android.gms.ads.DELAY_APP_MEASUREMENT_INIT"
  // android:value="true" />
}

//todo no need
// void onPurchaseSuccess(BuildContext context) {
//   // ... your logic to save the purchase status to the database ...
//
//   // Now, tell the app about the change.
//   // The 'listen: false' is important because we are not rebuilding here, just calling a method.
//   Provider.of<SubscriptionProvider>(context, listen: false).checkSubscriptionStatus();
// }
