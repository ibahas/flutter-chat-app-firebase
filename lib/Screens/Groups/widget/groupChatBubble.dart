//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/chat_screen/chat.dart';
import 'package:fiberchat_web/Screens/profile_settings/profile_view.dart';
import 'package:fiberchat_web/Utils/formatStatusTime.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupChatBubble extends StatelessWidget {
  const GroupChatBubble(
      {required this.child,
      required this.isWideScreenMode,
      required this.isURLtext,
      required this.timestamp,
      required this.delivered,
      required this.isMe,
      required this.isContinuing,
      required this.messagetype,
      required this.postedbyname,
      required this.prefs,
      required this.postedbyphone,
      this.savednameifavailable,
      required this.model,
      required this.currentUserNo,
      required this.is24hrsFormat});
  final dynamic isURLtext;
  final dynamic messagetype;
  final int? timestamp;
  final Widget child;
  final dynamic delivered;
  final bool isWideScreenMode;
  final String postedbyname;
  final String postedbyphone;
  final String? savednameifavailable;
  final bool isMe, isContinuing;
  final DataModel model;
  final SharedPreferences prefs;
  final String currentUserNo;
  final bool is24hrsFormat;
  humanReadableTime() => DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp!));

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? fiberchatCHATBUBBLEcolor : fiberchatWhite;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    dynamic icon = Icons.done_all;
    final color = isMe
        ? fiberchatBlack.withOpacity(0.5)
        : fiberchatBlack.withOpacity(0.5);
    icon = Icon(icon, size: 14.0, color: color);
    if (delivered is Future) {
      icon = FutureBuilder(
          future: delivered,
          builder: (context, res) {
            switch (res.connectionState) {
              case ConnectionState.done:
                return Icon((Icons.done_all), size: 13.0, color: color);
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
              default:
                return Icon(Icons.access_time, size: 13.0, color: color);
            }
          });
    }
    dynamic radius = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    dynamic margin = isWideScreenMode
        ? const EdgeInsets.only(top: 20.0, bottom: 2)
        : const EdgeInsets.only(top: 20.0, bottom: 1.5);
    if (isContinuing) {
      if (isWideScreenMode) {
        radius = BorderRadius.all(Radius.circular(5.0));
        margin = const EdgeInsets.fromLTRB(10, 4, 10, 2);
      } else {
        radius = BorderRadius.all(Radius.circular(5.0));
        margin = const EdgeInsets.all(1.9);
      }
    }

    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Container(
          margin: margin,
          padding: const EdgeInsets.all(8.0),
          constraints: BoxConstraints(
              maxWidth:
                  getContentScreenWidth(MediaQuery.of(context).size.width) *
                      0.513),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: align,
                children: [
                  isMe
                      ? Container(
                          width: 110,
                        )
                      : Consumer<SmartContactProviderWithLocalStoreData>(
                          builder: (context, contactsProvider, _child) =>
                              FutureBuilder<LocalUserData?>(
                                  future: contactsProvider
                                      .fetchUserDataFromnLocalOrServer(
                                          prefs, postedbyphone),
                                  builder: (context,
                                      AsyncSnapshot<LocalUserData?> snapshot) {
                                    if (snapshot.hasData) {
                                      return InkWell(
                                        onTap: () async {
                                          await contactsProvider
                                              .fetchFromFiretsoreAndReturnData(
                                                  prefs, snapshot.data!.id,
                                                  (doc) {
                                            hidekeyboard(context);
                                            Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        new ProfileView(
                                                            doc.data()!,
                                                            currentUserNo,
                                                            model,
                                                            prefs,
                                                            [],
                                                            firestoreUserDoc:
                                                                null)));
                                          });
                                        },
                                        child: Container(
                                          width: getContentScreenWidth(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              0.513,
                                          child: Text(
                                            savednameifavailable ??
                                                snapshot.data!.name,
                                            style: TextStyle(
                                                color: randomColorgenrator(
                                                    int.tryParse(postedbyphone.substring(5, 6))!
                                                                .remainder(2) ==
                                                            0
                                                        ? int.tryParse(postedbyphone
                                                                .substring(
                                                                    5, 6))!
                                                            .remainder(2)
                                                        : int.tryParse(
                                                                postedbyphone
                                                                    .substring(
                                                                        7, 8))!
                                                            .remainder(2)),
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      width: getContentScreenWidth(
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          0.513,
                                      child: Text(
                                        savednameifavailable ?? postedbyphone,
                                        style: TextStyle(
                                            color: randomColorgenrator(
                                                int.tryParse(postedbyphone.substring(
                                                                5, 6))!
                                                            .remainder(2) ==
                                                        0
                                                    ? int.tryParse(postedbyphone
                                                            .substring(5, 6))!
                                                        .remainder(2)
                                                    : int.tryParse(postedbyphone
                                                            .substring(7, 8))!
                                                        .remainder(2)),
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    );
                                  })),
                  //------

                  isMe
                      ? Container(
                          height: 0,
                          width: 0,
                        )
                      : SizedBox(
                          height: 10,
                        ),
                  Padding(
                      padding: this.messagetype == null ||
                              this.messagetype == MessageType.location ||
                              this.messagetype == MessageType.image ||
                              this.messagetype == MessageType.video
                          ? child is Container
                              ? EdgeInsets.fromLTRB(0, 0, 0, 27)
                              : EdgeInsets.only(
                                  right:
                                      this.messagetype == MessageType.location
                                          ? 0
                                          : isMe
                                              ? is24hrsFormat == true
                                                  ? 50
                                                  : 65.0
                                              : is24hrsFormat == true
                                                  ? 36
                                                  : 50.0)
                          : child is Container
                              ? EdgeInsets.all(0.0)
                              : EdgeInsets.only(
                                  right: isMe ? 5.0 : 5.0, bottom: 25),
                      child: child),
                ],
              ),
              Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          getWhen(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      timestamp!),
                                  context) +
                              ', ',
                          style: TextStyle(
                            color: color,
                            fontSize: 11.0,
                          )),
                      Text(
                          ' ' +
                              humanReadableTime().toString() +
                              (isMe ? ' ' : ''),
                          style: TextStyle(
                            color: color,
                            fontSize: 11.0,
                          )),
                      isMe ? icon : SizedBox()
                      // ignore: unnecessary_null_comparison
                    ].where((o) => o != null).toList()),
              ),
            ],
          ),
        )
      ],
    ));
  }

  Color randomColorgenrator(int digit) {
    switch (digit) {
      case 1:
        {
          return Colors.red;
        }

      case 2:
        {
          return Colors.blue;
        }
      case 3:
        {
          return Colors.purple;
        }
      case 4:
        {
          return Colors.green;
        }
      case 5:
        {
          return Colors.orange;
        }
      case 6:
        {
          return Colors.cyan;
        }
      case 7:
        {
          return Colors.pink;
        }
      case 8:
        {
          return Colors.red;
        }
      case 9:
        {
          return Colors.red;
        }

      default:
        {
          return Colors.blue;
        }
    }
  }
}
