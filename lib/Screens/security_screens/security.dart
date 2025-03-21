//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:core';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:fiberchat_web/widgets/Passcode/passcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Security extends StatefulWidget {
  final String? phoneNo, answer, title;
  final bool setPasscode, shouldPop;
  final SharedPreferences prefs;
  final Function onSuccess;

  Security(this.phoneNo,
      {this.shouldPop = false,
      this.setPasscode = false,
      this.answer,
      required this.title,
      required this.prefs,
      required this.onSuccess});

  @override
  _SecurityState createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String? _passCode;

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(Stack(children: [
      Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: fiberchatBlack,
                )),
            elevation: 0.4,
            backgroundColor: fiberchatWhite,
            title: Text(
              widget.title!,
              style: TextStyle(color: fiberchatBlack),
            ),
          ),
          bottomSheet: Container(
            margin: EdgeInsets.only(bottom: 15),
            height: 67,
            width: MediaQuery.of(this.context).size.width,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: myElevatedButton(
                  color: fiberchatPRIMARYcolor,
                  child: Text(
                    getTranslated(this.context, 'done'),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (widget.setPasscode) {
                      if (_passCode == null)
                        Fiberchat.toast(
                            getTranslated(this.context, 'setpasscode'));
                      if (
                          // ignore: todo
                          //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                          // _formKey.currentState.validate() &&

                          _passCode != null) {
                        var data = {
                          // ignore: todo
                          //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                          // QUESTION: _question.text,
                          // ANSWER:
                          //     Fiberchat.getHashedAnswer(_answer.text),
                          Dbkeys.passcode: Fiberchat.getHashedString(_passCode!)
                        };
                        setState(() {
                          isLoading = true;
                        });
                        widget.prefs.setInt(Dbkeys.passcodeTries, 0);
                        widget.prefs.setInt(Dbkeys.answerTries, 0);
                        FirebaseFirestore.instance
                            .collection(DbPaths.collectionusers)
                            .doc(widget.phoneNo)
                            .set(data, SetOptions(merge: true))
                            .then((_) {
                          widget.onSuccess(this.context);
                        });
                      }
                      widget.prefs
                          .setString(Dbkeys.isPINsetDone, widget.phoneNo!);
                    } else {
                      if (_formKey.currentState!.validate()) {
                        var data = {
                          // ignore: todo
                          //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                          // QUESTION: _question.text,
                          // ANSWER:
                          //     Fiberchat.getHashedAnswer(_answer.text),
                        };
                        setState(() {
                          isLoading = true;
                        });
                        widget.prefs.setInt(Dbkeys.passcodeTries, 0);
                        widget.prefs.setInt(Dbkeys.answerTries, 0);
                        FirebaseFirestore.instance
                            .collection(DbPaths.collectionusers)
                            .doc(widget.phoneNo)
                            .set(data as Map<String, Object?>,
                                SetOptions(merge: true))
                            .then((_) {
                          widget.onSuccess(this.context);
                          widget.prefs
                              .setString(Dbkeys.isPINsetDone, widget.phoneNo!);
                        });
                      }
                    }
                  },
                )),
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  widget.setPasscode
                      ? ListTile(
                          trailing: Icon(Icons.check_circle,
                              color: _passCode == null
                                  ? fiberchatGrey
                                  : fiberchatPRIMARYcolor,
                              size: 35),
                          title: myElevatedButton(
                            color: fiberchatPRIMARYcolor,
                            child: Text(
                              getTranslated(this.context, 'setpass'),
                              style: TextStyle(
                                color: fiberchatWhite,
                              ),
                            ),
                            onPressed: _showLockScreen,
                          ))
                      : SizedBox(),
                  widget.setPasscode ? SizedBox(height: 20) : SizedBox(),
                  // ignore: todo
                  //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                  // ListTile(
                  //     subtitle: Text(
                  //   getTranslated(this.context, 'setpasslong'),
                  // )),
                  // ListTile(
                  //   leading: Icon(Icons.lock),
                  //   title: TextFormField(
                  //     decoration: InputDecoration(
                  //         labelText:
                  //             getTranslated(this.context, 'sques')),
                  //     controller: _question,
                  //     autovalidateMode: AutovalidateMode.always,
                  //     validator: (v) {
                  //       return v.trim().isEmpty
                  //           ? getTranslated(this.context, 'quesempty')
                  //           : null;
                  //     },
                  //   ),
                  // ),
                  // ListTile(
                  //   leading: Icon(Icons.lock_open),
                  //   title: TextFormField(
                  //     autovalidateMode: AutovalidateMode.always,
                  //     decoration: InputDecoration(
                  //         labelText:
                  //             getTranslated(this.context, 'sans')),
                  //     controller: _answer,
                  //     validator: (v) {
                  //       if (v.trim().isEmpty)
                  //         return getTranslated(
                  //             this.context, 'ansempty');
                  //       if (Fiberchat.getHashedAnswer(v) ==
                  //           widget.answer)
                  //         return getTranslated(this.context, 'newans');
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ))),
      Positioned(
        child: isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          fiberchatSECONDARYolor)),
                ),
                color: fiberchatWhite.withOpacity(0.8),
              )
            : Container(),
      )
    ]));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = enteredPasscode.length == 4;
    _verificationNotifier.add(isValid);
    _passCode = null;
    if (isValid)
      setState(() {
        _passCode = enteredPasscode;
      });
  }

  _showLockScreen() {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            prefs: widget.prefs,
            onSubmit: null,
            wait: true,
            authentication: false,
            passwordDigits: 4,
            title: (getTranslated(this.context, 'enterpass')),
            passwordEnteredCallback: _onPasscodeEntered,
            cancelLocalizedText: getTranslated(this.context, 'cancel'),
            deleteLocalizedText: getTranslated(this.context, 'delete'),
            shouldTriggerVerification: _verificationNotifier.stream,
          ),
        ));
  }
}
