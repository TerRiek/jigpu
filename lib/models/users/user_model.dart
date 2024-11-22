
class UserModel {
  int? idx;
  String? identificationCode;
  String? accessCode;
  DateTime? accessCodeExpirationDate;
  String? userId;
  String? userPassword;
  String? userType;
  String? mobile;
  String? email;
  String? signUpDate;
  String? tagData;
  String? groupData;
  int? weight1;
  int? weight2;
  int? weight4;
  int? weight8;
  int? flags;
  String? flagData;
  String? badgeData;
  String? permissionData;
  String? statusData;
  String? accessData;
  AccessHistoryData? accessHistoryData;
  HistoryData? historyData;
  DateTime? registered;
  String? lastUpdated;
  String? image0;
  String? verificationCode;
  String? name;
  String? fullName;
  String? displayName;
  String? mobileIdentificationCode;
  String? verifyEmailCode;
  String? verifyMobileCode;
  String? userRegistered;
  String? ownerIdentificationCode;
  int? failCount;

  UserModel(
      {this.idx,
        this.identificationCode,
        this.accessCode,
        this.accessCodeExpirationDate,
        this.userId,
        this.userPassword,
        this.userType,
        this.mobile,
        this.email,
        this.signUpDate,
        this.tagData,
        this.groupData,
        this.weight1,
        this.weight2,
        this.weight4,
        this.weight8,
        this.flags,
        this.flagData,
        this.badgeData,
        this.permissionData,
        this.statusData,
        this.accessData,
        this.accessHistoryData,
        this.historyData,
        this.registered,
        this.lastUpdated,
        this.image0,
        this.verificationCode,
        this.name,
        this.fullName,
        this.displayName,
        this.mobileIdentificationCode,
        this.verifyEmailCode,
        this.verifyMobileCode,
        this.userRegistered,
        this.ownerIdentificationCode,
        this.failCount});

  UserModel.fromJson(Map<String, dynamic> json) {
    idx = json['idx'];
    identificationCode = json['identification_code'];
    accessCode = json['access_code'];
    if (json['access_code_expiration_date'] != null) {
      accessCodeExpirationDate = DateTime.parse(json['access_code_expiration_date']);
    }
    userId = json['user_id'];
    userPassword = json['user_password'];
    userType = json['user_type'];
    mobile = json['mobile'];
    email = json['email'];
    signUpDate = json['sign_up_date'];
    tagData = json['tag_data'];
    groupData = json['group_data'];
    weight1 = json['weight1'];
    weight2 = json['weight2'];
    weight4 = json['weight4'];
    weight8 = json['weight8'];
    flags = json['flags'];
    flagData = json['flag_data'];
    badgeData = json['badge_data'];
    permissionData = json['permission_data'];
    statusData = json['status_data'];
    accessData = json['access_data'];
    accessHistoryData = json['access_history_data'] != null ? AccessHistoryData.fromJson(json['access_history_data']) : null;
    historyData = json['history_data'] != null ? HistoryData.fromJson(json['history_data']) : null;
    if (json['registered'] != null) {
      registered = DateTime.parse(json['registered']);
    }
    lastUpdated = json['last_updated'];
    image0 = json['image0'];
    verificationCode = json['verification_code'];
    name = json['name'];
    fullName = json['full_name'];
    displayName = json['display_name'];
    mobileIdentificationCode = json['mobile_identification_code'];
    verifyEmailCode = json['verify_email_code'];
    verifyMobileCode = json['verify_mobile_code'];
    userRegistered = json['user_registered'];
    ownerIdentificationCode = json['owner_identification_code'];
    failCount = json['fail_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idx'] = idx;
    data['identification_code'] = identificationCode;
    data['access_code'] = accessCode;
    data['access_code_expiration_date'] = accessCodeExpirationDate.toString();
    data['user_id'] = userId;
    data['user_password'] = userPassword;
    data['user_type'] = userType;
    data['mobile'] = mobile;
    data['email'] = email;
    data['sign_up_date'] = signUpDate;
    data['tag_data'] = tagData;
    data['group_data'] = groupData;
    data['weight1'] = weight1;
    data['weight2'] = weight2;
    data['weight4'] = weight4;
    data['weight8'] = weight8;
    data['flags'] = flags;
    data['flag_data'] = flagData;
    data['badge_data'] = badgeData;
    data['permission_data'] = permissionData;
    data['status_data'] = statusData;
    data['access_data'] = accessData;
    if (accessHistoryData != null) {
      data['access_history_data'] = accessHistoryData!.toJson();
    }
    if (historyData != null) {
      data['history_data'] = historyData!.toJson();
    }
    data['registered'] = registered.toString();
    data['last_updated'] = lastUpdated;
    data['image0'] = image0;
    data['verification_code'] = verificationCode;
    data['name'] = name;
    data['full_name'] = fullName;
    data['display_name'] = displayName;
    data['mobile_identification_code'] = mobileIdentificationCode;
    data['verify_email_code'] = verifyEmailCode;
    data['verify_mobile_code'] = verifyMobileCode;
    data['user_registered'] = userRegistered;
    data['owner_identification_code'] = ownerIdentificationCode;
    data['fail_count'] = failCount;
    return data;
  }
}

class AccessHistoryData {
  String? signInType;
  String? lastSignInDate;
  String? lastSignInIp;

  AccessHistoryData({this.signInType, this.lastSignInDate, this.lastSignInIp});

  AccessHistoryData.fromJson(Map<String, dynamic> json) {
    signInType = json['sign_in_type'];
    lastSignInDate = json['last_sign_in_date'];
    lastSignInIp = json['last_sign_in_ip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sign_in_type'] = signInType;
    data['last_sign_in_date'] = lastSignInDate;
    data['last_sign_in_ip'] = lastSignInIp;
    return data;
  }
}

class HistoryData {
  String? queryType;
  String? summaryKo;
  String? executedDate;

  HistoryData({this.queryType, this.summaryKo, this.executedDate});

  HistoryData.fromJson(Map<String, dynamic> json) {
    queryType = json['query_type'];
    summaryKo = json['summary_ko'];
    executedDate = json['executed_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['query_type'] = queryType;
    data['summary_ko'] = summaryKo;
    data['executed_date'] = executedDate;
    return data;
  }
}
