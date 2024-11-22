import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jigpu_1/models/song_model.dart';

import 'list_data_model.dart';

class DataViewModel implements DataBasicModel {
  int? idx;
  String? title;
  String? titleEn;
  String? name;
  String? nameEn;
  String? image0;
  String? artist;
  String? artistEn;
  String? artistImage;
  String? releaseDate;
  String? entertainment;
  int? no;
  int? length;
  SongModel? song;
  String? music0;
  String playlistName = "플레이리스트";
  String? albumKo;
  DateTime? publishDate;
  String? songTime;
  String? albumCode;
  String? songCode;

  DataViewModel({this.idx, this.title, this.titleEn, this.image0, this.artist, this.artistEn, this.no, this.song});

  DataViewModel copyWithSong(SongModel song) {
    return DataViewModel(
      idx: this.idx,
      title: this.title,
      titleEn: this.titleEn,
      image0: this.image0,
      artist: this.artist,
      no: this.no,
      song: song,
    );
  }

  DataViewModel.fromJson(Map<String, dynamic> json) {
    debugPrint('DataViewModel JSON Data: $json');
    try {
      idx = json['idx'];
      title = json['title'].toString();
      titleEn = json['title_en'].toString();
      name = json['name'];
      nameEn = json['name_en'];
      image0 = json['image0'] ?? json['music0'];
      artist = (json['artist'] ?? json['artist_title'])?.toString();
      artistEn = json['artist_en'] ?? json['artist_title_en'];
      artistImage = json['artist_image'];
      no = json['no'] as int?;
      length = json['length'];
      releaseDate = json['release_date'];
      entertainment = json['entertainment'];
      music0 = json['music0'];
      if (json['music0'] != null) {
        song = SongModel(
          idx: json['idx'],
          // id: 'https://drive.usercontent.google.com/u/0/uc?id=1hid36awUAxK5AxZbpNH0AaVXlKFQrAHR&export=download',
          id: json['music0'],
          title: title ?? titleEn ?? '업데이트하지 않음',
          artist: artist ?? artistEn ?? '업데이트하지 않음',
          duration: const Duration(minutes: 3, seconds: 36),
          artUri: Uri.parse(image0 ?? ''),
          playlistName: json['playlistName'],
        );
      }
      playlistName = json['playlistName'] ?? "최근";
    } catch (e, stackTrace) {
      debugPrint("Error parsing DataViewModel: $e");
      debugPrint("Stack Trace: $stackTrace");
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idx'] = idx;
    data['title'] = title;
    data['title_en'] = titleEn;
    data['name'] = name;
    data['name_en'] = nameEn;
    data['image0'] = image0;
    data['artist_en'] = artistEn;
    data['artist_image'] = artistImage;
    data['artist'] = artist;
    data['no'] = no;
    data['release_date'] = releaseDate.toString();
    data['entertainment'] = entertainment.toString();
    data['length'] = length;
    data['music0'] = music0;
    data['playlistName'] = playlistName;
    return data;
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return DataViewModel.fromJson(json);
  }

  @override
  String toString() {
    return 'DataViewModel{idx: $idx, title: $title, titleEn: $titleEn, name: $name, nameEn: $nameEn, image0: $image0, artist: $artist, artistEn: $artistEn, artistImage: $artistImage, releaseDate: $releaseDate, no: $no, length: $length, song: $song, music0: $music0, playlistName: $playlistName}';
  }

  static DataViewModel fromMap(Map<String, dynamic> map) {
    return DataViewModel(
      idx: map['idx'],
      title: map['title'],
      titleEn: map['title_en'],
      image0: map['image0'],
      artist: map['artist'],
      no: map['no'],
      song: map['music0'] != null
          ? SongModel(
        idx: map['idx'],
        id: map['music0'],
        title: map['title'],
        artist: map['artist'],
        duration: const Duration(minutes: 3, seconds: 36),
        artUri: Uri.parse(map['image0'] ?? ''),
        playlistName: map['playlistName'],
      )
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'idx': idx,
      'title': title,
      'title_en': titleEn,
      'image0': image0,
      'artist': artist,
      'artist_en': artistEn,
      'artist_image': artistImage,
      'release_date': releaseDate,
      'no': no,
      'length': length,
      'music0': music0,
      'playlistName': playlistName,
    };
  }

  ///sqflite 전용 메소드
  Map<String, dynamic> toMapForSqflite() {
    return {
      'idx': idx ?? -1,
      'title': title ?? '',
      'titleEn': titleEn ?? '',
      'name': name ?? '',
      'nameEn': nameEn ?? '',
      'image0': image0 ?? '',
      'artist': artist ?? '',
      'artistEn': artistEn ?? '',
      'artistImage': artistImage ?? '',
      'releaseDate': releaseDate ?? '',
      'entertainment': entertainment ?? '',
      'no': no ?? 0,
      'length': length ?? 0,
      'song': '',
      'music0': music0 ?? '',
      'playlistName': playlistName ?? '',
      'albumKo': albumKo ?? '',
      'publishDate': publishDate ?? '',
      'songTime': songTime ?? '',
      'albumCode': albumCode ?? '',
      'songCode': songCode ?? '',
    };
  }

  void setName(String name) {
    this.name = name;
  }

  void setAlbum(String albumData) {
    albumKo = albumData;
  }

  void setPublishDate(String date) {
    try {
      publishDate = DateTime.parse(date);
    } catch(e) {
    }
  }

  void setEntertainment(String entertainment) {
    this.entertainment = entertainment;
  }

  void setSongTime(String time) {
    songTime = time;
  }

  void setAlbumCode(String code) {
    albumCode = code;
  }

  void setSongCode(String code) {
    songCode = code;
  }

  void setPlaylistName(String name) {
    playlistName = name;
  }
}