class LevelModel {
  String? country;
  bool? guessed;
  int? level;

  LevelModel({this.country, this.guessed, this.level});

  LevelModel.fromJson(Map<String, dynamic> json) {
    country = json['Country'];
    guessed = json['guessed'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Country'] = this.country;
    data['guessed'] = this.guessed;
    data['level'] = this.level;
    return data;
  }
}
