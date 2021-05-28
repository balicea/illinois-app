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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:illinois/service/Config.dart';
import 'package:illinois/service/Localization.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/service/Onboarding2.dart';
import 'package:illinois/ui/onboarding/onboarding2/Onboarding2PrivacyPanel.dart';
import 'package:illinois/ui/widgets/RibbonButton.dart';
import 'package:illinois/ui/widgets/ScalableWidgets.dart';
import 'package:illinois/ui/widgets/SwipeDetector.dart';
import 'package:illinois/service/Styles.dart';
import 'package:illinois/ui/widgets/TrianglePainter.dart';
import 'package:illinois/utils/Utils.dart';

import '../../WebPanel.dart';
import 'Onboarding2Widgets.dart';

class Onboarding2ImprovePanel extends StatefulWidget{

  Onboarding2ImprovePanel();
  _Onboarding2ImprovePanelState createState() => _Onboarding2ImprovePanelState();
}

class _Onboarding2ImprovePanelState extends State<Onboarding2ImprovePanel> {
  bool _toggled = false;

  @override
  void initState() {
    _toggled = Onboarding2().getImproveChoice;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles().colors.background,
        body: SafeArea(child:SwipeDetector(
            onSwipeLeft: () => _goNext(context),
            onSwipeRight: () => _goBack(context),
            child:
            ScalableScrollView(
              scrollableChild:
              Container(
                  color: Styles().colors.white,
                  child:Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            height: 8,
                            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                            child:Row(children: [
                              Expanded(
                                  flex:1,
                                  child: Container(color: Styles().colors.fillColorPrimary,)
                              ),
                              Container(width: 2,),
                              Expanded(
                                  flex:1,
                                  child: Container(color: Styles().colors.fillColorPrimary,)
                              ),
                              Container(width: 2,),
                              Expanded(
                                  flex:1,
                                  child: Container(color: Styles().colors.backgroundVariant,)
                              ),
                            ],)
                        ),
                        Row(children:[
                          Onboarding2BackButton(padding: const EdgeInsets.only(
                              left: 17, top: 19, right: 20, bottom: 15),
                              onTap: () {
                                Analytics.instance.logSelect(target: "Back");
                                _goBack(context);
                              }),
                        ],),
                        Semantics(
                            label: _title,
                            hint: Localization().getStringEx(
                                'panel.onboarding2.improve.label.title.hint', ''),
                            excludeSemantics: true,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 17, right: 17, top: 0, bottom: 12),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      _title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Styles().colors.fillColorPrimary,
                                          fontSize: 24,
                                          fontFamily: Styles().fontFamilies.bold,
                                          height: 1.2
                                      ))
                              ),
                            )),
                        Semantics(
                            label: _description,
                            excludeSemantics: true,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    _description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: Styles().fontFamilies.regular,
                                        fontSize: 16,
                                        color: Styles().colors.fillColorPrimary),
                                  )),
                            )),
                        Container(height: 10,),
                        GestureDetector(
                          onTap: _onTapLearnMore,
                          child:  Text(
                              Localization().getStringEx('panel.onboarding2.improve.button.title.learn_more', 'Learn More'),
                              style: TextStyle(color: Styles().colors.fillColorPrimary, fontSize: 14, decoration: TextDecoration.underline, decorationColor: Styles().colors.fillColorSecondary, fontFamily: Styles().fontFamilies.regular,)
                          ),
                        ),
                        Container(height: 18,),
                        Container(
                            height: 200,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 200,
                                    child:Column(
                                        children:[
                                          CustomPaint(
                                            painter: TrianglePainter(painterColor: Styles().colors.background, left: false),
                                            child: Container(
                                              height: 100,
                                            ),
                                          ),
                                          Container(height: 100, color: Styles().colors.background,)
                                        ]),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.center,
                                    child:Container(
                                      child: Image.asset("images/improve_illustration.png", excludeFromSemantics: true,fit: BoxFit.fitWidth, width: 300,),
                                    )
                                )
                              ],
                            )
                        )
                      ])),
              bottomNotScrollableWidget:
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child:
                      Onboarding2ToggleButton(
                        toggledTitle: _toggledButtonTitle,
                        unToggledTitle: _unToggledButtonTitle,
                        toggled: _toggled,
                        onTap: _onToggleTap,
                      ),
                    ),
                    ScalableRoundedButton(
                      label: Localization().getStringEx('panel.onboarding2.improve.button.continue.title', 'Continue'),
                      hint: Localization().getStringEx('panel.onboarding2.improve.button.continue.hint', ''),
                      fontSize: 16,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Styles().colors.white,
                      borderColor: Styles().colors.fillColorSecondaryVariant,
                      textColor: Styles().colors.fillColorPrimary,
                      onTap: () => _goNext(context),
                    )
                  ],
                ),
              ),
            ))));
  }

  void _onToggleTap(){
    setState(() {
      _toggled = !_toggled;
    });
  }

  void _goNext(BuildContext context) {
    Onboarding2().storeImproveChoice(_toggled);
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Onboarding2PrivacyPanel()));
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onTapLearnMore(){
    Onboarding2InfoDialog.show(
        context: context,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Localization().getStringEx('panel.onboarding2.improve.learn_more.title1',"Sharing Activity"),
              style: Onboarding2InfoDialog.titleStyle,),
            Container(height: 8,),
            Text(Localization().getStringEx('panel.onboarding2.improve.learn_more.location_services.content1',"Sharing your activity history sends your information to processing services. These services generate recommendations based on your interests."),
              style: Onboarding2InfoDialog.contentStyle,
            ),
            Container(height: 24,),
            Text(
              Localization().getStringEx('panel.onboarding2.improve.learn_more.title2',"Opting Out"),
              style: Onboarding2InfoDialog.titleStyle,),
            Container(height: 8,),
            Text(Localization().getStringEx('panel.onboarding2.improve.learn_more.location_services.content2',"The Privacy Center allows you to opt out of information collection at any time and provides the option to remove your data. "),
              style: Onboarding2InfoDialog.contentStyle,
            ),
          ]
        )
    );
  }

  String get _title{
    return Localization().getStringEx('panel.onboarding2.improve.label.title', 'Share your activity history to improve recommendations?');
  }

  String get _description{
    return Localization().getStringEx('panel.onboarding2.improve.label.description', 'The more you and others share, the more relevant info you get.');
  }
  
  String get _toggledButtonTitle{
    return Localization().getStringEx('panel.onboarding2.improve.button.toggle.title', "Share my activity.");
  }
  
  String get _unToggledButtonTitle{
    return Localization().getStringEx('panel.onboarding2.improve.button.untoggle.title', 'Don’t share my activity.');
  }
}