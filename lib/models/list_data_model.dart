import 'meta_data_model.dart';

abstract class DataBasicModel {
  fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class ListDataModel<T extends DataBasicModel> {
  MetaDataModel? metadata;
  List<T>? list;

  ListDataModel({this.metadata, this.list}) {
    metadata ??= MetaDataModel();
  }

  ListDataModel.fromJson(Map<String, dynamic> json, T data) {
    metadata = json['metadata'] != null ? MetaDataModel.fromJson(json['metadata']) : MetaDataModel();
    if (json['list'] != null) {
      list = <T>[];
      json['list'].forEach((v) {
        list!.add(data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
