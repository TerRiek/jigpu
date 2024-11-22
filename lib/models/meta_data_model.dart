class MetaDataModel {
  int? totalRows;
  int? totalMatchingRows;
  int? numberOfRows;
  int? page;
  int? rowsPerPage;
  int? totalPages;
  int? totalNumberOfPages;
  String? orderBy;

  MetaDataModel(
      {this.totalRows,
        this.totalMatchingRows,
        this.numberOfRows,
        this.page = 0,
        this.rowsPerPage,
        this.totalPages,
        this.totalNumberOfPages,
        this.orderBy});

  MetaDataModel.fromJson(Map<String, dynamic> json) {
    totalRows = json['total_rows'];
    totalMatchingRows = json['total_matching_rows'];
    numberOfRows = json['number_of_rows'];
    page = json['page'];
    rowsPerPage = json['rows_per_page'];
    totalPages = json['total_pages'];
    totalNumberOfPages = json['total_number_of_pages'];
    orderBy = json['order_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_rows'] = totalRows;
    data['total_matching_rows'] = totalMatchingRows;
    data['number_of_rows'] = numberOfRows;
    data['page'] = page;
    data['rows_per_page'] = rowsPerPage;
    data['total_pages'] = totalPages;
    data['total_number_of_pages'] = totalNumberOfPages;
    data['order_by'] = orderBy;
    return data;
  }
}
