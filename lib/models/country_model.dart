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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country_code'] = this.countryCode;
    data['country_name'] = this.countryName;
    data['capital'] = this.capital;
    data['country_demonym'] = this.countryDemonym;
    data['currency_code'] = this.currencyCode;
    data['currency_name'] = this.currencyName;
    data['lang_code'] = this.langCode;
    data['lang_name'] = this.langName;
    return data;
  }
}
