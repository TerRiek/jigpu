// part of 'song_bloc.dart';
//
// @immutable
// sealed class SongEvent {}
//
// final class SongEventGetSongRecommend extends SongEvent {
//   final MediaItem data;
//
//   SongEventGetSongRecommend(this.data);
// }
//
// final class SongEventWriteReview extends SongEvent {
//   final String comment;
//   final int score;
//   final int idx;
//
//   SongEventWriteReview({required this.comment, required this.score, required this.idx});
// }
//
// enum TypeFavorite { delete, add }
//
// final class SongEventFavorite extends SongEvent {
//   final int idx;
//   final TypeFavorite type;
//
//   SongEventFavorite({
//     required this.idx,
//     required this.type,
//   });
// }
