import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobConsentService {
  static final AdmobConsentService _instance = AdmobConsentService._internal();

  factory AdmobConsentService() => _instance;

  AdmobConsentService._internal();

  Future<void> checkAndRequestConsent(Function onFinished) async {
    final params = ConsentRequestParameters(
      // consentDebugSettings: ConsentDebugSettings(
      //   debugGeography: DebugGeography.debugGeographyEea, // Force EU
      //   testIdentifiers: ["YOUR_TEST_DEVICE_ID"], // Add your device ID here
      // ),
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        print("✅ Consent info update success");
        final status = await ConsentInformation.instance.getConsentStatus();
        print("👉 Consent status after update: $status");

        final isFormAvailable =
            await ConsentInformation.instance.isConsentFormAvailable();

        if (isFormAvailable) {
          _loadForm(onFinished);
        } else {
          onFinished();
        }
      },
      (FormError error) {
        print("❌ Consent info update failed: ${error.message}");
        onFinished();
      },
    );
  }

  void _loadForm(Function onFinished) {
    ConsentForm.loadConsentForm((ConsentForm consentForm) async {
      var status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        _waitUntilObtained();
        consentForm.show((FormError? formError) {
          onFinished();
        });
      } else {
        onFinished();
      }
    }, (formError) => onFinished());
  }

  void _waitUntilObtained() async {
    var status = await ConsentInformation.instance.getConsentStatus();
    if (status != ConsentStatus.obtained) {
      await Future.delayed(const Duration(seconds: 2));
      _waitUntilObtained();
    }
  }
}
