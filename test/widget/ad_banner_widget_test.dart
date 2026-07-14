import 'package:flag_app/widget/ads/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  testWidgets('reserves the standard banner height before an ad loads',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [AdBannerWidget(bannerAd: null)],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(AdBannerWidget)).height,
      AdSize.banner.height.toDouble(),
    );
  });
}
