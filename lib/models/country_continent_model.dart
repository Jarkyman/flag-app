class CountryContinentModel {
  String? continent;
  String? country;

  CountryContinentModel({this.continent, this.country});

  CountryContinentModel.fromJson(Map<String, dynamic> json) {
    continent = json['Continent'];
    country = json['Country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Continent'] = continent;
    data['Country'] = country;
    return data;
  }
}
