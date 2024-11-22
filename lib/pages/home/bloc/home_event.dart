part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

class HomeEventChangeIndex extends HomeEvent {
  final int index;
  final int? subIndex;

  HomeEventChangeIndex(this.index, {this.subIndex});
}

class HomeEventInitData extends HomeEvent {
  HomeEventInitData();
}

class HomeEventGetAllSongs extends HomeEvent {
  final String? search;

  HomeEventGetAllSongs({this.search});
}

class HomeEventGetAllAlbum extends HomeEvent {
  final String? search;

  HomeEventGetAllAlbum({this.search});
}

class HomeEventGetAllArtist extends HomeEvent {
  final String? search;

  HomeEventGetAllArtist({this.search});
}

class HomeEventGetAllAlbumHome extends HomeEvent {
  HomeEventGetAllAlbumHome();
}


