class CountryModel {
  String? countryCode;
  String? countryName;
  String? capital;
  String? countryDemonym;
  String? currencyCode;
  String? currencyName;
  String? langCode;
  String? langName;

  CountryModel(
      {this.countryCode,
      this.countryName,
      this.capital,
      this.countryDemonym,
      this.currencyCode,
      this.currencyName,
      this.langCode,
      this.langName});

  CountryModel.fromJson(Map<String, dynamic> json) {
    countryCode = json['country_code'];
    countryName = json['country_name'];
    capital = json['capital'];
    countryDemonym = json['country_demonym'];
    currencyCode = json['currency_code'];
    currencyName = json['currency_name'];
    langCode = json['lang_code'];
    langName = json['lang_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country_code'] = countryCode;
    data['country_name'] = countryName;
    data['capital'] = capital;
    data['country_demonym'] = countryDemonym;
    data['currency_code'] = currencyCode;
    data['currency_name'] = currencyName;
    data['lang_code'] = langCode;
    data['lang_name'] = langName;
    return data;
  }
}
