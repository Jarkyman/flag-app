class CountryContinentModel {
  String? continent;
  String? country;

  CountryContinentModel({this.continent, this.country});

  CountryContinentModel.fromJson(Map<String, dynamic> json) {
    continent = json['Continent'];
    country = json['Country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Continent'] = this.continent;
    data['Country'] = this.country;
    return data;
  }
}
