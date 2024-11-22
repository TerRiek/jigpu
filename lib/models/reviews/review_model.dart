class ReviewModel {
  int? idx;
  String? identificationCode;
  DateTime? created;
  String? lastUpdated;
  int? score;
  String? comment;
  String? music0;
  String? image0;
  String? title;
  String? titleEn;
  String? albumTitle;
  String? albumTitleEn;
  String? artistTitle;
  String? artistTitleEn;
  String? registered;
  int? no;

  ReviewModel(
      {this.idx,
        this.identificationCode,
        this.created,
        this.lastUpdated,
        this.score,
        this.comment,
        this.music0,
        this.image0,
        this.title,
        this.titleEn,
        this.albumTitle,
        this.albumTitleEn,
        this.artistTitle,
        this.artistTitleEn,
        this.registered,
        this.no});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    idx = json['idx'];
    identificationCode = json['identification_code'];
    created = DateTime.parse(json['created']);
    lastUpdated = json['last_updated'];
    score = json['score'];
    comment = json['comment'];
    music0 = json['music0'];
    image0 = json['image0'];
    title = json['title'];
    titleEn = json['title_en'];
    albumTitle = json['album_title'];
    albumTitleEn = json['album_title_en'];
    artistTitle = json['artist_title'];
    artistTitleEn = json['artist_title_en'];
    registered = json['registered'];
    no = json['no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idx'] = idx;
    data['identification_code'] = identificationCode;
    data['created'] = created;
    data['last_updated'] = lastUpdated;
    data['score'] = score;
    data['comment'] = comment;
    data['music0'] = music0;
    data['image0'] = image0;
    data['title'] = title;
    data['title_en'] = titleEn;
    data['album_title'] = albumTitle;
    data['album_title_en'] = albumTitleEn;
    data['artist_title'] = artistTitle;
    data['artist_title_en'] = artistTitleEn;
    data['registered'] = registered;
    data['no'] = no;
    return data;
  }
}
