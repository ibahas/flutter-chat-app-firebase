import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/chat_screen/chat.dart';
import 'package:fiberchat_web/Screens/recent_chats/RecentsChats.dart';
import 'package:fiberchat_web/Screens/recent_chats/widgets/getLastMessageTime.dart';
import 'package:fiberchat_web/Screens/recent_chats/widgets/getMediaMessage.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/chat_controller.dart';
import 'package:fiberchat_web/Utils/unawaited.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/Utils/late_load.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget getPersonalMessageTile(
    {required BuildContext context,
    required bool isWideScreenMode,
    required String currentUserNo,
    required SharedPreferences prefs,
    required DataModel cachedModel,
    var lastMessage,
    required var peer,
    required int unRead,
    peerSeenStatus,
    required var isPeerChatMuted,
    readFunction,
    required double tilewidth}) {
  //-- New context menu with Set Alias & Delete Chat tile
  showMenuForOneToOneChat(
      contextForDialog, Map<String, dynamic> targetUser, bool isMuted) {
    List<Widget> tiles = List.from(<Widget>[]);

    if (IsShowDeleteChatOption == true) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.delete, size: 22),
              title: Text(
                getTranslated(popable, 'deletethischat'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                unawaited(showDialog(
                  builder: (BuildContext contextDialog) {
                    return Builder(
                        builder: (BuildContext popable2) => AlertDialog(
                              title: new Text(
                                  getTranslated(popable2, 'deletethischat')),
                              content: new Text(
                                  getTranslated(popable2, 'suredelete')),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: fiberchatWhite),
                                  child: Text(
                                    getTranslated(popable2, 'cancel'),
                                    style: TextStyle(
                                        color: fiberchatSECONDARYolor,
                                        fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.of(popable2).pop();
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: fiberchatWhite),
                                  child: Text(
                                    getTranslated(popable2, 'delete'),
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 18),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(popable2).pop();
                                    var currentpeer =
                                        Provider.of<CurrentChatPeer>(context,
                                            listen: false);
                                    currentpeer.removeCurrentWidget();
                                    String chatId = Fiberchat.getChatId(
                                        currentUserNo,
                                        targetUser[Dbkeys.phone]);

                                    if (peer[Dbkeys.phone] != null) {
                                      Fiberchat.toast(getTranslated(
                                          contextDialog, 'plswait'));
                                      await FirebaseFirestore.instance
                                          .collection(
                                              DbPaths.collectionmessages)
                                          .doc(chatId)
                                          .delete()
                                          .then((v) async {
                                        await FirebaseFirestore.instance
                                            .collection(DbPaths.collectionusers)
                                            .doc(currentUserNo)
                                            .collection(Dbkeys.chatsWith)
                                            .doc(Dbkeys.chatsWith)
                                            .set({
                                          targetUser[Dbkeys.phone]:
                                              FieldValue.delete(),
                                        }, SetOptions(merge: true));
                                        // print('DELETED CHAT DOC 1');

                                        await FirebaseFirestore.instance
                                            .collection(DbPaths.collectionusers)
                                            .doc(targetUser[Dbkeys.phone])
                                            .collection(Dbkeys.chatsWith)
                                            .doc(Dbkeys.chatsWith)
                                            .set({
                                          currentUserNo: FieldValue.delete(),
                                        }, SetOptions(merge: true));
                                      }).then((value) {
                                        // Navigator.of(context).pushAndRemoveUntil(
                                        //   // the new route
                                        //   MaterialPageRoute(
                                        //     builder: (BuildContext context) =>
                                        //         FiberchatWrapper(),
                                        //   ),

                                        //   (Route route) => false,
                                        // );
                                        // unawaited(Navigator.pushReplacement(
                                        //     this.context,
                                        //     MaterialPageRoute(
                                        //         builder: (newContext) =>
                                        //             Homepage(
                                        //               currentUserNo:
                                        //                   currentUserNo,
                                        //               isSecuritySetupDone: true,
                                        //               prefs: widget.prefs,
                                        //             ))));
                                      });
                                    } else {
                                      Fiberchat.toast(
                                          'Error Occured. Could not delete !');
                                    }
                                  },
                                )
                              ],
                            ));
                  },
                  context: context,
                ));
              })));
    }
    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(children: tiles);
        });
  }

  return Theme(
      data: ThemeData(
          fontFamily: FONTFAMILY_NAME == '' ? null : FONTFAMILY_NAME,
          splashColor: fiberchatGrey.withOpacity(0.2),
          highlightColor: Colors.transparent),
      child: Column(
        children: [
          ListTile(
              contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              onLongPress: () {
                showMenuForOneToOneChat(context, peer, isPeerChatMuted);
              },
              leading: Stack(
                children: [
                  customCircleAvatar(url: peer[Dbkeys.photoUrl], radius: 42),
                  peer[Dbkeys.lastSeen] == true ||
                          peer[Dbkeys.lastSeen] == currentUserNo
                      ? Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 8,
                            child: CircleAvatar(
                              backgroundColor: Color(0xff08cc8a),
                              radius: 6,
                            ),
                          ))
                      : SizedBox()
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  peer[Dbkeys.lastSeen] == currentUserNo
                      ? Text(
                          getTranslated(context, "typing"),
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: lightGrey,
                              fontSize: 12),
                        )
                      : lastMessage == null || lastMessage == {}
                          ? SizedBox(
                              width: 0,
                            )
                          : lastMessage![Dbkeys.from] != currentUserNo
                              ? SizedBox()
                              : lastMessage![Dbkeys.messageType] ==
                                      MessageType.text.index
                                  ? readFunction == "" || readFunction == null
                                      ? SizedBox(
                                          width: 0,
                                        )
                                      : futureLoadString(
                                          future: readFunction,
                                          placeholder: SizedBox(
                                            width: 0,
                                          ),
                                          onfetchdone: (message) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 6),
                                              child: Icon(
                                                Icons.done_all,
                                                size: 12,
                                                color: peerSeenStatus == null
                                                    ? lightGrey
                                                    : lastMessage == null ||
                                                            lastMessage == {}
                                                        ? lightGrey
                                                        : peerSeenStatus is bool
                                                            ? Colors.lightBlue
                                                            : peerSeenStatus >
                                                                    lastMessage[
                                                                        Dbkeys
                                                                            .timestamp]
                                                                ? Colors
                                                                    .lightBlue
                                                                : lightGrey,
                                              ),
                                            );
                                          })
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: Icon(
                                        Icons.done_all,
                                        size: 12,
                                        color: peerSeenStatus == null
                                            ? lightGrey
                                            : lastMessage == null ||
                                                    lastMessage == {}
                                                ? lightGrey
                                                : peerSeenStatus is bool
                                                    ? Colors.lightBlue
                                                    : peerSeenStatus >
                                                            lastMessage[Dbkeys
                                                                .timestamp]
                                                        ? Colors.lightBlue
                                                        : lightGrey,
                                      ),
                                    ),
                  peer[Dbkeys.lastSeen] == currentUserNo
                      ? SizedBox()
                      : lastMessage == null || lastMessage == {}
                          ? SizedBox()
                          : (currentUserNo == lastMessage[Dbkeys.from] &&
                                          lastMessage![
                                              Dbkeys.hasSenderDeleted]) ==
                                      true ||
                                  (currentUserNo != lastMessage[Dbkeys.from] &&
                                      lastMessage![Dbkeys.hasRecipientDeleted])
                              ? Text(getTranslated(context, "msgdeleted"),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: unRead > 0
                                          ? darkGrey.withOpacity(0.4)
                                          : lightGrey.withOpacity(0.4),
                                      fontStyle: FontStyle.italic))
                              : lastMessage![Dbkeys.messageType] ==
                                      MessageType.text.index
                                  ? readFunction == "" || readFunction == null
                                      ? SizedBox()
                                      : SizedBox(
                                          width: tilewidth / 3,
                                          child: futureLoadString(
                                              future: readFunction,
                                              placeholder: Text(""),
                                              onfetchdone: (message) {
                                                return Text(message,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: unRead > 0
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                        color: unRead > 0
                                                            ? darkGrey
                                                            : lightGrey));
                                              }),
                                        )
                                  : getMediaMessage(
                                      context, unRead > 0, lastMessage),
                ],
              ),
              title: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Consumer<SmartContactProviderWithLocalStoreData>(
                      builder: (context, availableContacts, _child) {
                    // _filtered = availableContacts.filtered;
                    return FutureBuilder<LocalUserData?>(
                        future:
                            availableContacts.fetchUserDataFromnLocalOrServer(
                                prefs, peer[Dbkeys.phone]),
                        builder: (BuildContext context,
                            AsyncSnapshot<LocalUserData?> snapshot3) {
                          if (snapshot3.hasData && snapshot3.data != null) {
                            return Text(
                              snapshot3.data!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fiberchatBlack,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.4,
                              ),
                            );
                          }
                          return Text(
                            Fiberchat.getNickname(peer) ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fiberchatBlack,
                              fontWeight: FontWeight.w500,
                              fontSize: 16.4,
                            ),
                          );
                        });
                  })),
              onTap: () {
                if (isWideScreenMode) {
                  final currentpeer =
                      Provider.of<CurrentChatPeer>(context, listen: false);
                  currentpeer.setCurrentWidget(
                      ChatScreen(
                          isWideScreenMode: isWideScreenMode,
                          isSharingIntentForwarded: false,
                          prefs: prefs,
                          unread: unRead,
                          model: cachedModel,
                          currentUserNo: currentUserNo,
                          peerNo: peer[Dbkeys.phone] as String?),
                      currentUserNo,
                      peer[Dbkeys.phone],
                      personalchatID: Fiberchat.getChatId(
                          currentUserNo, peer[Dbkeys.phone]));
                } else {
                  if (cachedModel.currentUser![Dbkeys.locked] != null &&
                      cachedModel.currentUser![Dbkeys.locked]
                          .contains(peer[Dbkeys.phone])) {
                    if (prefs.getString(Dbkeys.isPINsetDone) != currentUserNo ||
                        prefs.getString(Dbkeys.isPINsetDone) == null) {
                      ChatController.unlockChat(
                          currentUserNo, peer[Dbkeys.phone] as String?);
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new ChatScreen(
                                  isWideScreenMode: isWideScreenMode,
                                  isSharingIntentForwarded: false,
                                  prefs: prefs,
                                  unread: unRead,
                                  model: cachedModel,
                                  currentUserNo: currentUserNo,
                                  peerNo: peer[Dbkeys.phone] as String?)));
                    } else {
                      NavigatorState state = Navigator.of(context);
                      ChatController.authenticate(cachedModel,
                          getTranslated(context, 'auth_neededchat'),
                          state: state,
                          shouldPop: false,
                          type: Fiberchat.getAuthenticationType(
                              false, cachedModel),
                          prefs: prefs, onSuccess: () {
                        state.pushReplacement(new MaterialPageRoute(
                            builder: (context) => new ChatScreen(
                                isWideScreenMode: isWideScreenMode,
                                isSharingIntentForwarded: false,
                                prefs: prefs,
                                unread: unRead,
                                model: cachedModel,
                                currentUserNo: currentUserNo,
                                peerNo: peer[Dbkeys.phone] as String?)));
                      });
                    }
                  } else {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new ChatScreen(
                                isWideScreenMode: isWideScreenMode,
                                isSharingIntentForwarded: false,
                                prefs: prefs,
                                unread: unRead,
                                model: cachedModel,
                                currentUserNo: currentUserNo,
                                peerNo: peer[Dbkeys.phone] as String?)));
                  }
                }
              },
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  lastMessage == {} || lastMessage == null
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            getLastMessageTime(context, currentUserNo,
                                lastMessage[Dbkeys.timestamp]),
                            style: TextStyle(
                                color: unRead != 0 ? Colors.green : lightGrey,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                        ),
                  SizedBox(
                    height: 1,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isPeerChatMuted
                          ? Icon(
                              Icons.volume_off,
                              size: 20,
                              color: lightGrey.withOpacity(0.5),
                            )
                          : Icon(
                              Icons.volume_up,
                              size: 20,
                              color: Colors.transparent,
                            ),
                      unRead == 0
                          ? SizedBox()
                          : Container(
                              margin: EdgeInsets.only(
                                  left: isPeerChatMuted ? 7 : 0),
                              child: Text(unRead.toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              padding: const EdgeInsets.all(7.0),
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[400],
                              ),
                            ),
                    ],
                  ),
                ],
              )),
          myDivider()
        ],
      ));
}

myDivider() {
  return Divider(
    height: 1,
    thickness: 1,
    color: Color(0xffededf0),
  );
}
