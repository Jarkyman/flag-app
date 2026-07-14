import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({
    super.key,
    required BannerAd? bannerAd,
  }) : _bannerAd = bannerAd;

  final BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    return SizedBox(
      width: double.infinity,
      height: AdSize.banner.height.toDouble(),
      child: bannerAd == null
          ? null
          : Center(
              child: SizedBox(
                width: bannerAd.size.width.toDouble(),
                height: bannerAd.size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              ),
            ),
    );
  }
}
