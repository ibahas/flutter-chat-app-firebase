//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fiberchat_web/Screens/homepage/Setupdata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Observer with ChangeNotifier {
  bool isOngoingCall = false;
  bool isshowerrorlog = true;
  bool isblocknewlogins = false;
  bool iscallsallowed = true;
  DocumentSnapshot<Map<String, dynamic>>? userAppSettingsDoc;
  bool istextmessagingallowed = true;
  bool ismediamessagingallowed = true;
  bool isadmobshow = false;
  String? privacypolicy;
  String? privacypolicyType;
  String? tnc;
  String? tncType;
  String? androidapplink;
  String? iosapplink;
  String? webapplink;
  bool is24hrsTimeformat = Is24hrsTimeformat;
  int groupMemberslimit = GroupMemberslimit;
  int broadcastMemberslimit = BroadcastMemberslimit;
  int statusDeleteAfterInHours = StatusDeleteAfterInHours;
  String feedbackEmail = FeedbackEmail;
  bool isLogoutButtonShowInSettingsPage = IsLogoutButtonShowInSettingsPage;
  bool isAllowCreatingGroups = IsAllowCreatingGroups;
  bool isAllowCreatingBroadcasts = IsAllowCreatingBroadcasts;
  bool isAllowCreatingStatus = IsAllowCreatingStatus;
  bool isPercentProgressShowWhileUploading =
      IsPercentProgressShowWhileUploading;
  int maxFileSizeAllowedInMB = MaxFileSizeAllowedInMB;
  //--
  int maxNoOfFilesInMultiSharing = MaxNoOfFilesInMultiSharing;
  int maxNoOfContactsSelectForForward = MaxNoOfContactsSelectForForward;
  String appShareMessageStringAndroid = '';
  String appShareMessageStringiOS = '';
  String appShareMessageStringWeb = '';
  bool isCustomAppShareLink = false;
  setisOngoingCall(bool v) {
    isOngoingCall = v;
    notifyListeners();
  }

  setObserver({
    bool? getisshowerrorlog,
    bool? getisblocknewlogins,
    bool? getiscallsallowed,
    bool? getistextmessagingallowed,
    bool? getismediamessagingallowed,
    bool? getisadmobshow,
    String? getprivacypolicy,
    DocumentSnapshot<Map<String, dynamic>>? getuserAppSettingsDoc,
    String? getprivacypolicyType,
    String? gettnc,
    String? gettncType,
    String? getandroidapplink,
    String? getiosapplink,
    String? getwebapplink,
    bool? getis24hrsTimeformat,
    int? getgroupMemberslimit,
    int? getbroadcastMemberslimit,
    int? getstatusDeleteAfterInHours,
    String? getfeedbackEmail,
    bool? getisLogoutButtonShowInSettingsPage,
    bool? getisCallFeatureTotallyHide,
    bool? getisAllowCreatingGroups,
    bool? getisAllowCreatingBroadcasts,
    bool? getisAllowCreatingStatus,
    bool? getisPercentProgressShowWhileUploading,
    int? getmaxFileSizeAllowedInMB,
    int? getmaxNoOfFilesInMultiSharing,
    int? getmaxNoOfContactsSelectForForward,
    String? getappShareMessageStringAndroid,
    String? getappShareMessageStringiOS,
    String? getappShareMessageStringWeb,
    bool? getisCustomAppShareLink,
  }) {
    this.userAppSettingsDoc = getuserAppSettingsDoc ?? this.userAppSettingsDoc;
    this.isshowerrorlog = getisshowerrorlog ?? this.isshowerrorlog;
    this.isblocknewlogins = getisblocknewlogins ?? this.isblocknewlogins;
    this.iscallsallowed = getiscallsallowed ?? this.iscallsallowed;

    this.istextmessagingallowed =
        getistextmessagingallowed ?? this.istextmessagingallowed;
    this.ismediamessagingallowed =
        getismediamessagingallowed ?? this.ismediamessagingallowed;
    this.isadmobshow = getisadmobshow ?? this.isadmobshow;
    this.privacypolicy = getprivacypolicy ?? this.privacypolicy;
    this.privacypolicyType = getprivacypolicyType ?? this.privacypolicyType;
    this.tnc = gettnc ?? this.tnc;
    this.tncType = gettncType ?? this.tncType;
    this.androidapplink = getandroidapplink ?? this.androidapplink;
    this.iosapplink = getiosapplink ?? this.iosapplink;

    this.is24hrsTimeformat = getis24hrsTimeformat ?? this.is24hrsTimeformat;
    this.groupMemberslimit = getgroupMemberslimit ?? this.groupMemberslimit;
    this.broadcastMemberslimit =
        getbroadcastMemberslimit ?? this.broadcastMemberslimit;
    this.statusDeleteAfterInHours =
        getstatusDeleteAfterInHours ?? this.statusDeleteAfterInHours;
    this.feedbackEmail = getfeedbackEmail ?? this.feedbackEmail;
    this.isLogoutButtonShowInSettingsPage =
        getisLogoutButtonShowInSettingsPage ??
            this.isLogoutButtonShowInSettingsPage;

    this.isAllowCreatingGroups =
        getisAllowCreatingGroups ?? this.isAllowCreatingGroups;
    this.isAllowCreatingBroadcasts =
        getisAllowCreatingBroadcasts ?? this.isAllowCreatingBroadcasts;
    this.isAllowCreatingStatus =
        getisAllowCreatingStatus ?? this.isAllowCreatingStatus;
    this.isPercentProgressShowWhileUploading =
        getisPercentProgressShowWhileUploading ??
            this.isPercentProgressShowWhileUploading;
    this.maxFileSizeAllowedInMB =
        getmaxFileSizeAllowedInMB ?? this.maxFileSizeAllowedInMB;
    this.maxNoOfFilesInMultiSharing =
        getmaxNoOfFilesInMultiSharing ?? this.maxNoOfFilesInMultiSharing;
    this.maxNoOfContactsSelectForForward = getmaxNoOfContactsSelectForForward ??
        this.maxNoOfContactsSelectForForward;
    this.appShareMessageStringAndroid =
        getappShareMessageStringAndroid ?? this.appShareMessageStringAndroid;
    this.appShareMessageStringiOS =
        getappShareMessageStringiOS ?? this.appShareMessageStringiOS;
    this.isCustomAppShareLink =
        getisCustomAppShareLink ?? this.isCustomAppShareLink;
    notifyListeners();
  }
}
