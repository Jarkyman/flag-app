import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class adBannerWidget extends StatelessWidget {
  const adBannerWidget({
    Key? key,
    required BannerAd? bannerAd,
  })  : _bannerAd = bannerAd,
        super(key: key);

  final BannerAd? _bannerAd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
