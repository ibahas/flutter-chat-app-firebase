//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'dart:async';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/aes_encryption.dart';
import 'package:fiberchat_web/Services/Providers/FirebaseAPIProvider.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fiberchat_web/Models/E2EE/e2ee.dart' as e2ee;
import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseBroadcastServices {
  Stream<List<BroadcastModel>> getBroadcastsList(String? phone) {
    return FirebaseFirestore.instance
        .collection(DbPaths.collectionbroadcasts)
        .where(Dbkeys.broadcastCREATEDBY, isEqualTo: phone)
        .orderBy(Dbkeys.broadcastCREATEDON, descending: true)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => BroadcastModel.fromJson(document.data()))
            .toList());
  }

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  sendMessageToBroadcastRecipients({
    required List<dynamic> recipientList,
    required BuildContext context,
    required String content,
    required String currentUserNo,
    required String broadcastId,
    required MessageType type,
    required DataModel cachedModel,
  }) async {
    String? privateKey = await storage.read(key: Dbkeys.privateKey);
    content = content.trim();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (content.trim() != '') {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionbroadcasts)
          .doc(broadcastId)
          .collection(DbPaths.collectionbroadcastsChats)
          .doc(timestamp.toString() + '--' + currentUserNo)
          .set({
        Dbkeys.broadcastmsgCONTENT: content,
        Dbkeys.broadcastmsgISDELETED: false,
        Dbkeys.broadcastmsgLISToptional: [],
        Dbkeys.broadcastmsgTIME: timestamp,
        Dbkeys.broadcastmsgSENDBY: currentUserNo,
        Dbkeys.broadcastmsgISDELETED: false,
        Dbkeys.broadcastmsgTYPE: type.index,
        Dbkeys.broadcastLocations: []
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionbroadcasts)
          .doc(broadcastId)
          .set({
        Dbkeys.broadcastLATESTMESSAGETIME: timestamp,
      }, SetOptions(merge: true));
      recipientList.forEach((peer) async {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(peer)
            .get()
            .then((userDoc) async {
          try {
            String? sharedSecret = (await e2ee.X25519().calculateSharedSecret(
                    e2ee.Key.fromBase64(privateKey!, false),
                    e2ee.Key.fromBase64(userDoc[Dbkeys.publicKey], true)))
                .toBase64();
            final key = encrypt.Key.fromBase64(sharedSecret);
            cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));

            final encrypted = AESEncryptData.encryptAES(content, sharedSecret);
            if (encrypted is String) {
              int timestamp2 = DateTime.now().millisecondsSinceEpoch;
              if (content.trim() != '') {
                var chatId = Fiberchat.getChatId(currentUserNo, peer);
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionbroadcasts)
                    .doc(broadcastId)
                    .collection(DbPaths.collectionbroadcastsChats)
                    .doc(timestamp.toString() + '--' + currentUserNo)
                    .set({
                  Dbkeys.broadcastLocations:
                      FieldValue.arrayUnion(['$chatId--BREAK--$timestamp2'])
                }, SetOptions(merge: true)).then((value) async {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .set({
                    currentUserNo: true,
                    peer: userDoc[Dbkeys.lastSeen],
                    Dbkeys.isbroadcast: true,
                  }, SetOptions(merge: true)).then((value) {
                    Future messaging = FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .doc(peer)
                        .collection(Dbkeys.chatsWith)
                        .doc(Dbkeys.chatsWith)
                        .set({
                      currentUserNo: 4,
                    }, SetOptions(merge: true));
                    cachedModel.addMessage(peer, timestamp2, messaging);
                  }).then((value) {
                    Future messaging = FirebaseFirestore.instance
                        .collection(DbPaths.collectionmessages)
                        .doc(chatId)
                        .collection(chatId)
                        .doc('$timestamp2')
                        .set({
                      Dbkeys.from: currentUserNo,
                      Dbkeys.to: peer,
                      Dbkeys.timestamp: timestamp2,
                      Dbkeys.content: encrypted,
                      Dbkeys.messageType: type.index,
                      Dbkeys.isbroadcast: true,
                      Dbkeys.broadcastID: broadcastId,
                      Dbkeys.hasRecipientDeleted: false,
                      Dbkeys.hasSenderDeleted: false,
                      Dbkeys.latestEncrypted: true,
                      Dbkeys.isMuted: false,
                      Dbkeys.sendername:
                          cachedModel.currentUser![Dbkeys.nickname],
                      Dbkeys.isReply: false,
                      Dbkeys.replyToMsgDoc: null,
                      Dbkeys.isForward: false,
                    }, SetOptions(merge: true));
                    cachedModel.addMessage(peer, timestamp2, messaging);
                  });
                });
              }
            } else {
              Fiberchat.toast('Nothing to send');
            }
          } catch (e) {
            Fiberchat.toast('Failed to Send message. Error:$e');
          }
        }).catchError(((e) {
          Fiberchat.toast('Failed to Send message. Error:$e');
        }));
      });
    } else {
      Fiberchat.toast('Nothing to Send !');
    }
  }
}

class BroadcastModel {
  Map<String, dynamic> docmap = {};
  BroadcastModel.fromJson(Map<String, dynamic> parsedJSON)
      : docmap = parsedJSON;
}

//  _________ Broadcast Chat page Messages ____________
class FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE extends ChangeNotifier {
  var datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;
  String? parentid;
  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _hasNext = true;
    datalistSnapshot.clear();
    _isFetchingData = false;
    _errorMessage = '';
    recievedDocs.clear();
    notifyListeners();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading,
              startAfter:
                  datalistSnapshot.isNotEmpty ? datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        datalistSnapshot.clear();
        datalistSnapshot.addAll(snap.docs);
      } else {
        datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length <
          maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading) {
        _hasNext = false;
      }
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  addDoc(DocumentSnapshot newDoc) {
    int index = datalistSnapshot
        .indexWhere((doc) => doc[Dbkeys.timestamp] == newDoc[Dbkeys.timestamp]);
    if (index < 0) {
      List<DocumentSnapshot> list = datalistSnapshot.reversed.toList();
      list.add(newDoc);
      List<DocumentSnapshot> finallist = list.reversed.toList();
      datalistSnapshot = finallist;
      notifyListeners();
    }
  }

  bool checkIfDocAlreadyExits(
      {required DocumentSnapshot newDoc, int? timestamp}) {
    return timestamp != null
        ? datalistSnapshot.indexWhere(
                (doc) => doc[Dbkeys.timestamp] == newDoc[Dbkeys.timestamp]) >=
            0
        : datalistSnapshot.contains(newDoc);
  }

  int totalDocsLoadedLength() {
    return datalistSnapshot.length;
  }

  updateparticulardocinProvider({
    required DocumentSnapshot updatedDoc,
  }) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.timestamp] == updatedDoc[Dbkeys.timestamp]);

    datalistSnapshot.removeAt(index);
    datalistSnapshot.insert(index, updatedDoc);
    notifyListeners();
  }

  deleteparticulardocinProvider({required DocumentSnapshot deletedDoc}) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.timestamp] == deletedDoc[Dbkeys.timestamp]);

    if (index >= 0) {
      datalistSnapshot.removeAt(index);
      notifyListeners();
    }
  }
}
