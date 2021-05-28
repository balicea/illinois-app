/*
 * Copyright 2020 Board of Trustees of the University of Illinois.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:illinois/service/Config.dart';
import 'package:illinois/service/Localization.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/ui/WebPanel.dart';
import 'package:illinois/ui/onboarding/onboarding2/Onboarding2ExploreCampusPanel.dart';
import 'package:illinois/ui/widgets/ScalableWidgets.dart';
import 'package:illinois/ui/widgets/SwipeDetector.dart';
import 'package:illinois/service/Styles.dart';
import 'package:illinois/utils/Utils.dart';

import 'Onboarding2Widgets.dart';

class Onboarding2PrivacyStatementPanel extends StatefulWidget{

  Onboarding2PrivacyStatementPanel();
  _Onboarding2PrivacyStatementPanelState createState() => _Onboarding2PrivacyStatementPanelState();
}

class _Onboarding2PrivacyStatementPanelState extends State<Onboarding2PrivacyStatementPanel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleText = Localization().getStringEx('panel.onboarding2.privacy_statement.label.title', 'Control Your Data Privacy');
    String titleText2 = Localization().getStringEx('panel.onboarding2.privacy_statement.label.title2', '');
    String descriptionText = Localization().getStringEx('panel.onboarding2.privacy_statement.label.description1', 'Choose what information you want to store and share to get a recommended privacy level.');

    String descriptionText1 = Localization().getStringEx('panel.onboarding2.privacy_statement.label.description1', 'Please read the ');
    String descriptionText2 = Localization().getStringEx('panel.onboarding2.privacy_statement.label.description2', 'Privacy Policy ');
    String descriptionText3 = Localization().getStringEx('panel.onboarding2.privacy_statement.label.description3', '. Your continued use of the app assumes that you have read and agree with it.');

    return Scaffold(
        backgroundColor: Styles().colors.background,
        body: SwipeDetector(
            onSwipeLeft: () => _goNext(context),
            onSwipeRight: () => _goBack(context),
            child:
            ScalableScrollView(
              scrollableChild:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(children: [
                      Onboarding2BackButton( padding: const EdgeInsets.only(left: 17, top: 37, right: 20, bottom: 8),
                          onTap:() {
                            Analytics.instance.logSelect(target: "Back");
                            _goBack(context);
                          }),
                    ],),
                    Image.asset("images/lock_illustration.png", excludeFromSemantics: true, width: 130, fit: BoxFit.fitWidth, ),
                    Semantics(
                      label: titleText + titleText2,
                      hint: Localization().getStringEx('panel.onboarding2.privacy_statement.label.title.hint', ''),
                      excludeSemantics: true,
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 40, right: 40, top: 12, bottom: 12),
                          child: Align(
                            alignment: Alignment.center,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text:titleText , style: TextStyle(color: Styles().colors.fillColorPrimary, fontSize: 32, fontFamily: Styles().fontFamilies.bold, fontWeight: FontWeight.w700, height: 1.5)),
                                  TextSpan(text:titleText2, style: TextStyle(color: Styles().colors.fillColorPrimary, fontSize: 32, fontWeight: FontWeight.w400,)),
                                ]
                              )
                            ),
                          )),
                    ),
                    Semantics(
                        label: descriptionText,
                        excludeSemantics: true,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                            descriptionText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: Styles().fontFamilies.regular,
                                fontSize: 16,
                                color: Styles().colors.fillColorPrimary),
                          )),
                        )),
                  ]),
              bottomNotScrollableWidget:
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(height: 16,),
                    Semantics(
                        label: descriptionText1 + ", "+ descriptionText2+","+descriptionText3,
                        excludeSemantics: true,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: RichText(
                                textAlign: TextAlign.center,

                                text: TextSpan(
                                    style: TextStyle(
                                        fontFamily: Styles().fontFamilies.regular,
                                        fontSize: 14,
                                        color: Styles().colors.textSurface),
                                    children: <TextSpan>[
                                      TextSpan(text:descriptionText1),
                                      TextSpan(text:descriptionText2, style: TextStyle(color: Styles().colors.fillColorPrimary, fontSize: 14, decoration: TextDecoration.underline, decorationColor: Styles().colors.fillColorSecondary),
                                          recognizer: TapGestureRecognizer()..onTap = _openPrivacyPolicy, children: [
                                            WidgetSpan(child: Container(padding: EdgeInsets.only(bottom: 4), child: Image.asset("images/icon-external-link-blue.png")))
                                          ]),
                                      TextSpan(text:descriptionText3),
                                    ]
                                )
                            ),),
                        )),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 24, top: 16),
                      child: ScalableRoundedButton(
                        label: Localization().getStringEx('panel.onboarding2.privacy_statement.button.continue.title', 'Begin'),
                        hint: Localization().getStringEx('panel.onboarding2.privacy_statement.button.continue.hint', ''),
                        fontSize: 16,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Styles().colors.white,
                        borderColor: Styles().colors.fillColorSecondaryVariant,
                        textColor: Styles().colors.fillColorPrimary,
                        onTap: () => _goNext(context),
                      ),),
                  ],
                ),
              ),
            )));
  }

  void _openPrivacyPolicy(){
    Analytics.instance.logSelect(target: "Privacy Statement");
    if (Config().privacyPolicyUrl != null) {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => WebPanel(url: Config().privacyPolicyUrl, hideToolBar:true, title: Localization().getStringEx("panel.settings.privacy_statement.label.title", "Privacy Policy"),)));
    }
  }

  void _goNext(BuildContext context) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Onboarding2ExploreCampusPanel()));
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
