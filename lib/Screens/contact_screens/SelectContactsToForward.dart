//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/contact_screens/syncedContacts.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectContactsToForward extends StatefulWidget {
  const SelectContactsToForward({
    required this.currentUserNo,
    required this.contentPeerNo,
    required this.model,
    required this.prefs,
    required this.onSelect,
    required this.messageOwnerPhone,
    this.groupID,
  });
  final String? groupID;
  final String? currentUserNo;
  final String? contentPeerNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final String messageOwnerPhone;
  final Function(List<dynamic> selectedList) onSelect;

  @override
  _SelectContactsToForwardState createState() =>
      new _SelectContactsToForwardState();
}

class _SelectContactsToForwardState extends State<SelectContactsToForward>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  bool isGroupsloading = true;
  List<Map<String, dynamic>> joinedGroupsList = [];
  List<LocalUserData> selectedDynamicListFORUSERS = [];
  List<Map<String, dynamic>> selectedDynamicListFORGROUPS = [];
  @override
  bool get wantKeepAlive => true;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    fetchJoinedGroups();
  }

  fetchJoinedGroups() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .where(Dbkeys.groupMEMBERSLIST, arrayContains: widget.currentUserNo)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .get()
        .then((groupsList) {
      if (groupsList.docs.length > 0) {
        groupsList.docs.forEach((group) {
          joinedGroupsList.add(group.data());
          if (groupsList.docs.last[Dbkeys.groupID] == group[Dbkeys.groupID]) {
            isGroupsloading = false;
            // print('isGroupsloading $isGroupsloading');
          }
          setState(() {});
        });
      } else {
        isGroupsloading = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor),
        )),
      )
    ]);
  }

  int currentUploadingIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Fiberchat.toast(widget.contentPeerNo.toString());
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<SmartContactProviderWithLocalStoreData>(
                  builder:
                      (context, contactsProvider, _child) =>
                          Consumer<List<GroupModel>>(
                              builder: (context, groupList, _child) => Scaffold(
                                  backgroundColor: fiberchatScaffold,
                                  bottomSheet:
                                      selectedDynamicListFORUSERS.length != 0 ||
                                              selectedDynamicListFORGROUPS.length !=
                                                  0
                                          ? Container(
                                              padding: EdgeInsets.only(top: 6),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 97,
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    AlwaysScrollableScrollPhysics(),
                                                children: [
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          selectedDynamicListFORGROUPS
                                                              .reversed
                                                              .toList()
                                                              .length,
                                                      itemBuilder:
                                                          (context, int i) {
                                                        var m =
                                                            selectedDynamicListFORGROUPS
                                                                .reversed
                                                                .toList()[i];
                                                        return Stack(
                                                          children: [
                                                            Container(
                                                              width: 80,
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      11,
                                                                      10,
                                                                      12,
                                                                      10),
                                                              child: Column(
                                                                children: [
                                                                  customCircleAvatarGroup(
                                                                      url: m.containsKey(Dbkeys
                                                                              .groupPHOTOURL)
                                                                          ? m[Dbkeys
                                                                              .groupPHOTOURL]
                                                                          : '',
                                                                      radius:
                                                                          42),
                                                                  SizedBox(
                                                                    height: 7,
                                                                  ),
                                                                  Text(
                                                                    selectedDynamicListFORGROUPS
                                                                            .reversed
                                                                            .toList()[i][Dbkeys.groupNAME] ??
                                                                        '',
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned(
                                                              right: 17,
                                                              top: 5,
                                                              child:
                                                                  new InkWell(
                                                                onTap: () {
                                                                  setStateIfMounted(
                                                                      () {
                                                                    selectedDynamicListFORGROUPS.remove(selectedDynamicListFORGROUPS
                                                                        .reversed
                                                                        .toList()[i]);
                                                                  });
                                                                },
                                                                child:
                                                                    new Container(
                                                                  width: 20.0,
                                                                  height: 20.0,
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  decoration:
                                                                      new BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons.close,
                                                                    size: 14,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ), //............
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      }),
                                                  ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          selectedDynamicListFORUSERS
                                                              .reversed
                                                              .toList()
                                                              .length,
                                                      itemBuilder:
                                                          (context, int i) {
                                                        return widget.contentPeerNo ==
                                                                    selectedDynamicListFORUSERS
                                                                        .reversed
                                                                        .toList()[
                                                                            i]
                                                                        .id ||
                                                                widget.currentUserNo ==
                                                                    selectedDynamicListFORUSERS
                                                                        .reversed
                                                                        .toList()[
                                                                            i]
                                                                        .id
                                                            ? SizedBox(
                                                                height: 0,
                                                                width: 0,
                                                              )
                                                            : Stack(
                                                                children: [
                                                                  Container(
                                                                    width: 80,
                                                                    padding:
                                                                        const EdgeInsets.fromLTRB(
                                                                            11,
                                                                            10,
                                                                            12,
                                                                            10),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        customCircleAvatar(
                                                                            url:
                                                                                selectedDynamicListFORUSERS.reversed.toList()[i].photoURL,
                                                                            radius: 42),
                                                                        SizedBox(
                                                                          height:
                                                                              7,
                                                                        ),
                                                                        Text(
                                                                          selectedDynamicListFORUSERS
                                                                              .reversed
                                                                              .toList()[i]
                                                                              .name,
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    right: 17,
                                                                    top: 5,
                                                                    child:
                                                                        new InkWell(
                                                                      onTap:
                                                                          () {
                                                                        setStateIfMounted(
                                                                            () {
                                                                          selectedDynamicListFORUSERS.remove(selectedDynamicListFORUSERS
                                                                              .reversed
                                                                              .toList()[i]);
                                                                        });
                                                                      },
                                                                      child:
                                                                          new Container(
                                                                        width:
                                                                            20.0,
                                                                        height:
                                                                            20.0,
                                                                        padding:
                                                                            const EdgeInsets.all(2.0),
                                                                        decoration:
                                                                            new BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .close,
                                                                          size:
                                                                              14,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ), //............
                                                                    ),
                                                                  )
                                                                ],
                                                              );
                                                      }),
                                                ],
                                              ),
                                            )
                                          : SizedBox(),
                                  key: _scaffold,
                                  appBar: AppBar(
                                    elevation: 0.4,
                                    actions: <Widget>[
                                      selectedDynamicListFORUSERS.length != 0 ||
                                              selectedDynamicListFORGROUPS
                                                      .length !=
                                                  0
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.check,
                                                color: fiberchatBlack,
                                              ),
                                              onPressed: () async {
                                                List<dynamic> finalList = [];
                                                selectedDynamicListFORGROUPS
                                                    .forEach((element) {
                                                  finalList.add(element);
                                                  setStateIfMounted(() {});
                                                });

                                                for (var element
                                                    in selectedDynamicListFORUSERS) {
                                                  await contactsProvider
                                                      .fetchFromFiretsoreAndReturnData(
                                                          widget.prefs,
                                                          element.id,
                                                          (peerDoc) async {
                                                    finalList
                                                        .add(peerDoc.data());
                                                    setStateIfMounted(() {});
                                                  });
                                                }
                                                widget.onSelect(finalList);
                                                Navigator.of(context).pop();
                                              })
                                          : SizedBox()
                                    ],
                                    titleSpacing: -5,
                                    leading: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: Icon(
                                        Icons.arrow_back,
                                        size: 24,
                                        color: fiberchatBlack,
                                      ),
                                    ),
                                    backgroundColor: fiberchatWhite,
                                    centerTitle: true,
                                    // leadingWidth: 40,
                                    title: Text(
                                      getTranslated(this.context,
                                          'selectcontactstoforward'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: fiberchatBlack,
                                      ),
                                    ),
                                  ),
                                  body: RefreshIndicator(
                                      onRefresh: () {
                                        return contactsProvider
                                            .syncContactsFromCloud(
                                                context,
                                                widget.currentUserNo!,
                                                widget.prefs);
                                      },
                                      child:
                                          contactsProvider.searchingcontactsindatabase ==
                                                      true ||
                                                  isGroupsloading == true
                                              ? loading()
                                              : contactsProvider
                                                          .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                          .length ==
                                                      0
                                                  ? SingleChildScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      padding: const EdgeInsets.all(
                                                          8.0),
                                                      child: Center(
                                                          child: Container(
                                                              margin: EdgeInsets.only(
                                                                  top: 20,
                                                                  bottom: 20),
                                                              color:
                                                                  Colors.white,
                                                              width: getContentScreenWidth(
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width),
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: noContactsWidget(context)))))
                                                  : SingleChildScrollView(
                                                      physics: BouncingScrollPhysics(),
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Center(
                                                          child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 20,
                                                            bottom: 20),
                                                        color: Colors.white,
                                                        width:
                                                            getContentScreenWidth(
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ListView.builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              itemCount:
                                                                  joinedGroupsList
                                                                      .length,
                                                              itemBuilder:
                                                                  (context, i) {
                                                                return Column(
                                                                  children: [
                                                                    ListTile(
                                                                      trailing:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border: Border.all(
                                                                              color: fiberchatGrey,
                                                                              width: 1),
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                        ),
                                                                        child: selectedDynamicListFORGROUPS.lastIndexWhere((element) => element[Dbkeys.groupID] == joinedGroupsList[i][Dbkeys.groupID]) >=
                                                                                0
                                                                            ? Icon(
                                                                                Icons.check,
                                                                                size: 19.0,
                                                                                color: fiberchatPRIMARYcolor,
                                                                              )
                                                                            : Icon(
                                                                                null,
                                                                                size: 19.0,
                                                                              ),
                                                                      ),
                                                                      leading: customCircleAvatarGroup(
                                                                          url: joinedGroupsList[i].containsKey(Dbkeys.groupPHOTOURL)
                                                                              ? joinedGroupsList[i][Dbkeys
                                                                                  .groupPHOTOURL]
                                                                              : '',
                                                                          radius:
                                                                              42),
                                                                      title:
                                                                          Text(
                                                                        joinedGroupsList[i]
                                                                            [
                                                                            Dbkeys.groupNAME],
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              fiberchatBlack,
                                                                          fontSize:
                                                                              16,
                                                                        ),
                                                                      ),
                                                                      subtitle:
                                                                          Text(
                                                                        '${joinedGroupsList[i][Dbkeys.groupMEMBERSLIST].length} ${getTranslated(context, 'participants')}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              fiberchatGrey,
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        final observer = Provider.of<Observer>(
                                                                            this
                                                                                .context,
                                                                            listen:
                                                                                false);
                                                                        setStateIfMounted(
                                                                            () {
                                                                          if (selectedDynamicListFORGROUPS.lastIndexWhere((element) => element[Dbkeys.groupID] == joinedGroupsList[i][Dbkeys.groupID]) >=
                                                                              0) {
                                                                            selectedDynamicListFORGROUPS.remove(joinedGroupsList[i]);
                                                                            setStateIfMounted(() {});
                                                                          } else {
                                                                            if (selectedDynamicListFORUSERS.length + selectedDynamicListFORGROUPS.length >
                                                                                observer.maxNoOfContactsSelectForForward - 1) {
                                                                              Fiberchat.toast(getTranslated(context, 'maxallowed') + ' : ${observer.maxNoOfContactsSelectForForward}');
                                                                            } else {
                                                                              selectedDynamicListFORGROUPS.add(joinedGroupsList[i]);
                                                                              setStateIfMounted(() {});
                                                                            }
                                                                          }
                                                                        });
                                                                      },
                                                                    ),
                                                                    Divider(
                                                                      height: 2,
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                            ListView.builder(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0),
                                                              shrinkWrap: true,
                                                              physics:
                                                                  NeverScrollableScrollPhysics(),
                                                              itemCount:
                                                                  contactsProvider
                                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      idx) {
                                                                String phone =
                                                                    contactsProvider
                                                                        .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                                            idx]
                                                                        .phone;
                                                                Widget?
                                                                    alreadyAddedUser;

                                                                return widget.contentPeerNo ==
                                                                            contactsProvider
                                                                                .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                                                    idx]
                                                                                .phone ||
                                                                        widget.currentUserNo ==
                                                                            contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer[idx].phone
                                                                    ? SizedBox(
                                                                        height:
                                                                            0,
                                                                        width:
                                                                            0,
                                                                      )
                                                                    : alreadyAddedUser ??
                                                                        FutureBuilder<LocalUserData?>(
                                                                            future: contactsProvider.fetchUserDataFromnLocalOrServer(widget.prefs, phone),
                                                                            builder: (BuildContext context, AsyncSnapshot<LocalUserData?> snapshot) {
                                                                              if (snapshot.hasData) {
                                                                                LocalUserData user = snapshot.data!;
                                                                                return Column(
                                                                                  children: [
                                                                                    ListTile(
                                                                                      trailing: Container(
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: fiberchatGrey, width: 1),
                                                                                          borderRadius: BorderRadius.circular(5),
                                                                                        ),
                                                                                        child: selectedDynamicListFORUSERS.lastIndexWhere((element) => element.id == user.id) >= 0
                                                                                            ? Icon(
                                                                                                Icons.check,
                                                                                                size: 19.0,
                                                                                                color: fiberchatPRIMARYcolor,
                                                                                              )
                                                                                            : Icon(
                                                                                                null,
                                                                                                size: 19.0,
                                                                                              ),
                                                                                      ),
                                                                                      leading: customCircleAvatar(
                                                                                        url: user.photoURL,
                                                                                        radius: 42,
                                                                                      ),
                                                                                      title: Text(user.name, style: TextStyle(color: fiberchatBlack)),
                                                                                      subtitle: Text(phone, style: TextStyle(color: fiberchatGrey)),
                                                                                      // contentPadding: EdgeInsets.symmetric(
                                                                                      //     horizontal:
                                                                                      //         10.0,
                                                                                      //     vertical:
                                                                                      // 0.0),
                                                                                      onTap: () {
                                                                                        final observer = Provider.of<Observer>(this.context, listen: false);
                                                                                        setStateIfMounted(() {
                                                                                          if (selectedDynamicListFORUSERS.lastIndexWhere((element) => element.id == user.id) >= 0) {
                                                                                            selectedDynamicListFORUSERS.remove(snapshot.data!);
                                                                                            setStateIfMounted(() {});
                                                                                          } else {
                                                                                            if (snapshot.data!.id == widget.messageOwnerPhone) {
                                                                                            } else {
                                                                                              if (selectedDynamicListFORUSERS.length + selectedDynamicListFORGROUPS.length > observer.maxNoOfContactsSelectForForward - 1) {
                                                                                                Fiberchat.toast(getTranslated(context, 'maxallowed') + ' : ${observer.maxNoOfContactsSelectForForward}');
                                                                                              } else {
                                                                                                selectedDynamicListFORUSERS.add(snapshot.data!);
                                                                                                setStateIfMounted(() {});
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                    Divider(
                                                                                      height: 2,
                                                                                    )
                                                                                  ],
                                                                                );
                                                                              }
                                                                              return SizedBox();
                                                                            });
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      )))))));
            }))));
  }
}
