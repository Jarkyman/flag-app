import 'dart:ui';

import '../helper/app_constants.dart';

enum TrainingContinent {
  all(id: 'all', translationKey: 'All', shortCode: 'ALL'),
  africa(id: 'africa', translationKey: 'Africa', shortCode: 'AF'),
  asia(id: 'asia', translationKey: 'Asia', shortCode: 'AS'),
  europe(id: 'europe', translationKey: 'Europe', shortCode: 'EU'),
  northAmerica(
    id: 'north-america',
    translationKey: 'North America',
    shortCode: 'NA',
  ),
  oceania(id: 'oceania', translationKey: 'Oceania', shortCode: 'OC'),
  southAmerica(
    id: 'south-america',
    translationKey: 'South America',
    shortCode: 'SA',
  );

  final String id;
  final String translationKey;
  final String shortCode;

  const TrainingContinent({
    required this.id,
    required this.translationKey,
    required this.shortCode,
  });

  String? assetNameFor(Locale locale) {
    if (this == TrainingContinent.all) return null;
    final countryCode = locale.countryCode?.toLowerCase() ?? 'us';
    return _continentAssetNames[countryCode]?[id] ?? translationKey;
  }
}

const Map<String, Map<String, String>> _continentAssetNames = {
  'us': {
    'africa': 'Africa',
    'asia': 'Asia',
    'europe': 'Europe',
    'north-america': 'North America',
    'oceania': 'Oceania',
    'south-america': 'South America',
  },
  'dk': {
    'africa': 'Afrika',
    'asia': 'Asien',
    'europe': 'Europa',
    'north-america': 'Nordamerika',
    'oceania': 'Oceanien',
    'south-america': 'Sydamerika',
  },
  'de': {
    'africa': 'Afrika',
    'asia': 'Asien',
    'europe': 'Europa',
    'north-america': 'Nordamerika',
    'oceania': 'Ozeanien',
    'south-america': 'Südamerika',
  },
  'es': {
    'africa': 'África',
    'asia': 'Asia',
    'europe': 'Europa',
    'north-america': 'América del Norte',
    'oceania': 'Oceanía',
    'south-america': 'América del Sur',
  },
  'fr': {
    'africa': 'Afrique',
    'asia': 'Asie',
    'europe': 'Europe',
    'north-america': 'Amérique du Nord',
    'oceania': 'Océanie',
    'south-america': 'Amérique du Sud',
  },
  'no': {
    'africa': 'Africa',
    'asia': 'Asia',
    'europe': 'Europe',
    'north-america': 'Nord-Amerika',
    'oceania': 'Oceania',
    'south-america': 'Sør-Amerika',
  },
  'pt': {
    'africa': 'África',
    'asia': 'Ásia',
    'europe': 'Europa',
    'north-america': 'América Do Norte',
    'oceania': 'Oceania',
    'south-america': 'América Do Sul',
  },
  'br': {
    'africa': 'África',
    'asia': 'Ásia',
    'europe': 'Europa',
    'north-america': 'América Do Norte',
    'oceania': 'Oceania',
    'south-america': 'América Do Sul',
  },
  'se': {
    'africa': 'Afrika',
    'asia': 'Asien',
    'europe': 'Europa',
    'north-america': 'Nordamerika',
    'oceania': 'Oceanien',
    'south-america': 'Sydamerika',
  },
};

enum TrainingScoreGame {
  findFlag(AppConstants.FLAG_SCORE),
  matchFlags(AppConstants.FLAGS_SCORE),
  whichCountry(AppConstants.COUNTRIES_SCORE);

  final String storageKey;

  const TrainingScoreGame(this.storageKey);
}
