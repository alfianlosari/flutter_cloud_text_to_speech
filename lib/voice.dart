class Voice {
  final String name;
  final String gender;
  final List<String> languageCodes;

  Voice(this.name, this.gender, this.languageCodes);

  static List<Voice> mapJSONStringToList(List<dynamic> jsonList) {
    return jsonList.map((v) {
      return Voice(v['name'], v['ssmlGender'], List<String>.from(v['languageCodes']));
    }).toList();
  }

}