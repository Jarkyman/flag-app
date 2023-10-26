class LevelModel {
  String? country;
  bool? guessed;
  int? level;
  bool? bombUsed;
  List<String>? allLetters;
  List<List<String>>? answerLetters;

  LevelModel({this.country, this.guessed, this.level});

  LevelModel.fromJson(Map<String, dynamic> json) {
    country = json['Country'];
    guessed = json['Guessed'] ?? false;
    level = json['Level'];
    bombUsed = json['BombUsed'] ?? false;
    if (json['AnswerLetters'] != null) {
      answerLetters = deConvertList(json['AnswerLetters'].cast<String>());
    } else {
      answerLetters = [];
    }
    if (json['AllLetters'] != null) {
      allLetters = json['AllLetters'].cast<String>();
    } else {
      allLetters = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Country'] = country;
    data['Guessed'] = guessed;
    data['Level'] = level;
    data['BombUsed'] = bombUsed;
    data['AnswerLetters'] = enConvertList(answerLetters!);
    data['AllLetters'] = allLetters;
    return data;
  }

  List<List<String>> deConvertList(var data) {
    List<String> temp = [];
    List<List<String>> result = [];
    for (var d in data) {
      if (d != '#') {
        temp.add(d);
      } else {
        result.add(temp);
        temp = [];
      }
    }
    return result;
  }

  List<String> enConvertList(List<List<String>> data) {
    List<String> result = [];
    for (int i = 0; i < data.length; i++) {
      result.addAll(data[i]);
      if (i < data.length) {
        result.add('#');
      }
    }
    return result;
  }
}
