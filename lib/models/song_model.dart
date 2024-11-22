import 'package:audio_service/audio_service.dart';

class SongModel extends MediaItem {
  int idx;
  late int songRating;
  final String? playlistName;
  String? image0;
  String? songCode;
  int favorite = 0;

  SongModel({
    required this.idx,
    this.songRating = 0,
    required String id,
    required String title,
    this.playlistName,
    this.songCode,
    Uri? artUri,
    String? artist,
    Duration? duration,
  }) : super(
    idx: idx,
    id: id,
    title: title,
    artist: artist,
    artUri: artUri,
    duration: duration,
  );

  SongModel copyWithIdxIdAndArtUri(int idx, String id, String artUri) {
    return SongModel(
      idx: idx,
      id: id,
      title : this.title,
      playlistName : this.playlistName ?? "Unknown Album",
      artUri : Uri.parse(artUri),
      artist : this.artist,
      duration : this.duration,
    );
  }

  SongModel copyWithId(String id) {
    return SongModel(
      idx: this.idx,
      id: id,
      title : this.title,
      playlistName : this.playlistName ?? "Unknown Album",
      artUri : this.artUri,
      artist : this.artist,
      duration : this.duration,
    );
  }


  // SongModel을 MediaItem으로 변환하는 메서드
  MediaItem toMediaItem() {
    return MediaItem(
      idx: idx,
      id: id,
      album: playlistName ?? 'Unknown Album',
      title: title,
      artist: artist,
      duration: duration,
      artUri: artUri,
    );
  }

  copyWithModel(MediaItem mediaItem) {
    return SongModel(
      idx: this.idx,
      id: mediaItem.id,
      title: mediaItem.title,
      artist: mediaItem.artist,
      artUri: mediaItem.artUri,
      duration: mediaItem.duration,
      playlistName: playlistName,
      songRating: songRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idx': idx,  // idx 필드를 JSON에 추가
      'id': id,
      'title': title,
      'artist': artist,
      'artUri': artUri?.toString(),
      'duration': duration?.inMilliseconds,
      'playlistName': playlistName,
      'songRating': songRating,
    };
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      idx: json['idx'] ?? 0,
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      artUri: json['artUri'] != null ? Uri.tryParse(json['artUri']) : null,
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
      playlistName: json['playlistName'],
      songRating: json['songRating'] ?? 0,
    );
  }

  ///sqflite 전용 메소드
  Map<String, dynamic> toMapForSqflite() {
    return {
      'songCode': songCode,
      'id': id,
      'title': title,
      'artist': artist,
      'artUri': artUri.toString(),
      'duration': duration,
      'playlistName': playlistName,
      'songRating': songRating,
      'favorite': 0,
      'noteReview': "",
      'rating': rating,
      'userEmail': "",
      'createdAt': "",
      'updatedAt': "",
    };
  }

  void setImageLocal(String path) {
    image0 = path;
  }

  void setIdx(int idx) {
    this.idx = idx;
  }

  void setSongCode(String songCode) {
    this.songCode = songCode;
  }

  void setFavorite(int favorite) {
    this.favorite = favorite;
  }
}
