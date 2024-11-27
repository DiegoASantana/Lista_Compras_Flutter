import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final bool isPremiumUser;

  const BannerAdWidget({super.key, required this.isPremiumUser});

  @override
  BannerAdWidgetState createState() => BannerAdWidgetState();
}

class BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // Se o usuário não for premium, carregue o banner
    if (!widget.isPremiumUser) {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741', // Substitua pelo ID do bloco de anúncios do AdMob
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    // Se o banner foi carregado, descarte-o
    if (_isAdLoaded) {
      _bannerAd.dispose();
    }

    // Certifique-se de chamar super.dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se o usuário é premium ou o anúncio não carregou, não mostre nada
    if (widget.isPremiumUser || !_isAdLoaded) {
      return const SizedBox(); // Retorna um widget vazio
    }

    // Renderize o banner
    return Container(
      alignment: Alignment.center,
      width: _bannerAd.size.width.toDouble(),
      height: _bannerAd.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd),
    );
  }
}
