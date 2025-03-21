//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/notifications/NotificationViewer.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/determine_screen.dart';

class AllNotifications extends StatefulWidget {
  final SharedPreferences prefs;
  const AllNotifications({Key? key, required this.prefs}) : super(key: key);

  @override
  _AllNotificationsState createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications> {
  List notificationList = [];
  bool isloading = true;
  String errormessage = '';
  @override
  void initState() {
    super.initState();
    getNotificationList();
  }

  getNotificationList() async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc('usersnotifications')
        .get()
        .then((doc) {
      if (doc.exists == true) {
        setState(() {
          List list = doc.data()?['list'];
          notificationList = list.reversed.toList();
          isloading = false;
        });
      } else {
        setState(() {
          errormessage = 'Error Occured: Notification Document does not exists';
        });
      }
    }).catchError((onError) {
      setState(() {
        errormessage =
            'Failed to load. Please try again later !\n\nCAPTURED ERROR: $onError';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(Scaffold(
            backgroundColor: fiberchatScaffold,
            appBar: AppBar(
              centerTitle: true,
              elevation: 0.4,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: fiberchatBlack,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: fiberchatWhite,
              title: Text(
                getTranslated(context, 'allnotifications'),
                style: TextStyle(
                  fontSize: 18,
                  color: fiberchatBlack,
                ),
              ),
            ),
            body: errormessage != ''
                ? Center(
                    child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Text(
                      errormessage,
                      textAlign: TextAlign.center,
                    ),
                  ))
                : isloading == true
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            fiberchatSECONDARYolor),
                      ))
                    : notificationList.length < 1
                        ? Center(
                            child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Text(
                              getTranslated(context, 'nonotifications'),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 19, color: fiberchatGrey),
                            ),
                          ))
                        : SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 20),
                                    color: Colors.white,
                                    width: getContentScreenWidth(
                                        MediaQuery.of(context).size.width),
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: notificationList.length,
                                        itemBuilder:
                                            (BuildContext context, int i) {
                                          return notificationcard(
                                              doc: notificationList[i]);
                                        })))))));
  }

  //widget to show name in card
  Widget notificationcard({
    var doc,
  }) {
    return doc.containsKey(Dbkeys.nOTIFICATIONxxtitle)
        ? Stack(
            children: [
              InkWell(
                onTap: () {
                  notificationViwer(
                    context,
                    doc[Dbkeys.nOTIFICATIONxxdesc],
                    doc[Dbkeys.nOTIFICATIONxxtitle],
                    doc[Dbkeys.nOTIFICATIONxximageurl],
                    formatTimeDateCOMLPETEString(
                        context: context,
                        isdateTime: false,
                        timestamptargetTime:
                            doc[Dbkeys.nOTIFICATIONxxlastupdate]),
                  );
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(8, 8, 8, 6),
                  decoration: boxDecoration(showShadow: true),
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(10, 13, 10, 13),
                  child: Container(
                      child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                doc[Dbkeys.nOTIFICATIONxxtitle] ??
                                    'Hello test notifcations title ',
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  fontSize: 15.9,
                                  color: fiberchatBlack,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                doc[Dbkeys.nOTIFICATIONxxdesc] ??
                                    'Hello test notifcations description',
                                maxLines: 2,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  height: 1.35,
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )),
                          SizedBox(
                            width: 12,
                          ),
                          doc[Dbkeys.nOTIFICATIONxximageurl] == null
                              ? SizedBox()
                              : Container(
                                  height: 60,
                                  width: 110,
                                  color: Colors.white.withOpacity(0.19),
                                  child: doc[Dbkeys.nOTIFICATIONxximageurl] ==
                                          null
                                      ? Center(
                                          child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '  NO IMAGE  ',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey
                                                    .withOpacity(0.5)),
                                          ),
                                        ))
                                      : Image.network(
                                          doc[Dbkeys.nOTIFICATIONxximageurl],
                                          height: 60,
                                          width: 110,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                        ],
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(3, 0, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTimeDateCOMLPETEString(
                                  context: context,
                                  isdateTime: false,
                                  timestamptargetTime:
                                      doc[Dbkeys.nOTIFICATIONxxlastupdate]),
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontStyle: FontStyle.normal,
                                height: 1.25,
                                fontSize: 12.4,
                                color: Colors.blueGrey.withOpacity(0.5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 0,
                              width: 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          )
        : SizedBox();
  }

  BoxDecoration boxDecoration(
      {double? radius,
      Color? color,
      Color bgColor = Colors.white,
      var showShadow = false}) {
    return BoxDecoration(
        color: bgColor,
        //gradient: LinearGradient(colors: [bgColor, whiteColor]),
        boxShadow: showShadow == true
            ? [
                BoxShadow(
                    color: Color(0xfff1f4fb).withOpacity(0.4),
                    blurRadius: 0.5,
                    spreadRadius: 1)
              ]
            : [BoxShadow(color: bgColor)],
        border: showShadow == true
            ? Border.all(
                color: Color(0xfff1f4fb).withOpacity(0.99),
                style: BorderStyle.solid,
                width: 0)
            : Border.all(
                color: color ?? Color(0xfff1f4fb).withOpacity(0.9),
                style: BorderStyle.solid,
                width: 1.2),
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 5)));
  }

  String formatTimeDateCOMLPETEString({
    required BuildContext context,
    Timestamp? timestamptargetTime,
    DateTime? datetimetargetTime,
    // int myTzoMinutes,
    bool? isdateTime,
    bool? isshowutc,
  }) {
    final observer = Provider.of<Observer>(context, listen: false);
    int myTzoMinutes = DateTime.now().timeZoneOffset.inMinutes;
    // var myTzoMinutes = 330;
    DateTime sortedTime = isdateTime == true || isdateTime == null
        ? datetimetargetTime!.add(Duration(
            minutes:
                myTzoMinutes - datetimetargetTime.timeZoneOffset.inMinutes))
        : timestamptargetTime!.toDate().add(Duration(
            minutes: myTzoMinutes -
                timestamptargetTime.toDate().timeZoneOffset.inMinutes));

    final df = new DateFormat(observer.is24hrsTimeformat == true
        ? 'dd MMM yyyy,  HH:mm'
        : 'dd MMM yyyy  hh:mm a');

    return isshowutc == true
        ? myTzoMinutes >= 0
            ? '${df.format(sortedTime)} (GMT+${minutesToHour(myTzoMinutes)})'
            : '${df.format(sortedTime)} (GMT${minutesToHour(myTzoMinutes)})'
        : '${df.format(sortedTime)}';
  }

//--------------------
  String minutesToHour(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2)}:${parts[1].padLeft(2, '0')}';
  }
}
