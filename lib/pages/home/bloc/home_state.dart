part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeStateChangeIndexState extends HomeState {
  final int indexCurrent;
  final int? subIndexCurrent;

  HomeStateChangeIndexState({required this.indexCurrent, this.subIndexCurrent});
}

final class HomeStateInit extends HomeState {
  // final List<NewsModel>? listDataNews;

  // HomeStateInit({this.listDataNews});
}

final class HomeStateGetAllSongsState extends HomeState {
  final List<DataViewModel> listData;

  HomeStateGetAllSongsState({required this.listData});
}

final class HomeStateGetAllAlbumsState extends HomeState {
  final List<DataViewModel> listData;

  HomeStateGetAllAlbumsState({required this.listData});
}

final class HomeStateGetAllArtistsState extends HomeState {
  final List<DataViewModel> listData;

  HomeStateGetAllArtistsState({required this.listData});
}

final class HomeStateGetAllAlbumHome extends HomeState {
  final List<DataViewModel> listSmall;
  final List<DataViewModel> listMedium;
  final List<DataViewModel> listBiggest;

  HomeStateGetAllAlbumHome({
    this.listSmall = const [],
    this.listMedium = const [],
    this.listBiggest = const [],
  });

  HomeStateGetAllAlbumHome copyWith({
    List<DataViewModel>? listSmall,
    List<DataViewModel>? listMedium,
    List<DataViewModel>? listBiggest,
  }) {
    return HomeStateGetAllAlbumHome(
      listSmall: listSmall ?? this.listSmall,
      listMedium: listMedium ?? this.listMedium,
      listBiggest: listBiggest ?? this.listBiggest,
    );
  }
}
