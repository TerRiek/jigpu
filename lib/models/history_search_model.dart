class HistorySearchModel {
  String? text;
  late int count;

  HistorySearchModel({this.text, this.count = 0});

  HistorySearchModel.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['count'] = count;
    return data;
  }
}
