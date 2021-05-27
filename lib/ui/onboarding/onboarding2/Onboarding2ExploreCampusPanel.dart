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
import 'package:illinois/service/Localization.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/service/Onboarding2.dart';
import 'package:illinois/ui/widgets/RibbonButton.dart';
import 'package:illinois/ui/widgets/ScalableWidgets.dart';
import 'package:illinois/ui/widgets/SwipeDetector.dart';
import 'package:illinois/service/Styles.dart';
import 'package:illinois/ui/widgets/TrianglePainter.dart';
import 'package:illinois/utils/Utils.dart';

import 'Onboarding2PersonalizePanel.dart';
import 'Onboarding2Widgets.dart';

class Onboarding2ExploreCampusPanel extends StatefulWidget{

  Onboarding2ExploreCampusPanel();
  _Onboarding2ExploreCampusPanelState createState() => _Onboarding2ExploreCampusPanelState();
}

class _Onboarding2ExploreCampusPanelState extends State<Onboarding2ExploreCampusPanel> {
  bool _toggled = false;

  @override
  void initState() {
    _toggled = Onboarding2().getExploreCampusChoice;
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
                            child: Container(color: Styles().colors.backgroundVariant,)
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
                          left: 17, top: 19, right: 20, bottom: 27),
                          onTap: () {
                            Analytics.instance.logSelect(target: "Back");
                            _goBack(context);
                          }),
                    ],),
                    Semantics(
                        label: _title,
                        hint: Localization().getStringEx(
                            'panel.onboarding2.explore_campus.label.title.hint', ''),
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
                                    height: 1.4
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
                          Localization().getStringEx('panel.onboarding2.explore_campus.button.title.learn_more', 'Learn More'),
                          style: TextStyle(color: Styles().colors.fillColorPrimary, fontSize: 14, decoration: TextDecoration.underline, decorationColor: Styles().colors.fillColorSecondary, fontFamily: Styles().fontFamilies.regular,)
                      ),
                    ),
                    Container(height: 24,),
                    Container(
                      height: 180,
                      child: Stack(
                        children: [
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 100,
                                  child:Column(
                                  children:[
                                    CustomPaint(
                                      painter: TrianglePainter(painterColor: Styles().colors.background,),
                                      child: Container(
                                        height: 80,
                                      ),
                                    ),
                                    Container(height: 20, color: Styles().colors.background,)
                                ]),
                              ),
                            ),
                          Align(
                            alignment: Alignment.center,
                            child:Container(
                              child: Image.asset("images/explore_illustration.png", excludeFromSemantics: true,width: 250, fit: BoxFit.fitWidth,),
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
                      label: Localization().getStringEx('panel.onboarding2.explore_campus.button.continue.title', 'Continue'),
                      hint: Localization().getStringEx('panel.onboarding2.explore_campus.button.continue.hint', ''),
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

  String get _toggleButtonLabel{
    return _toggled? "Yes." : "Not now.";
  }

  void _onToggleTap(){
    setState(() {
      _toggled = !_toggled;
    });
  }

  void _goNext(BuildContext context) {
    Onboarding2().storeExploreCampusChoice(_toggled);
    Navigator.push(context, CupertinoPageRoute(builder: (context) => Onboarding2PersonalizePanel()));
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _onTapLearnMore(){
    //TBD implement learn more
    AppToast.show("TBD");
  }

  String get _title{
    return Localization().getStringEx('panel.onboarding2.explore_campus.label.title', 'Enable location specific services?');
  }

  String get _description{
    return Localization().getStringEx('panel.onboarding2.explore_campus.label.description', 'Easily find events on campus and connect to nearby users.');
  }

  String get _toggledButtonTitle{
    return Localization().getStringEx('panel.onboarding2.explore_campus.button.toggle.title', 'Enable location services.');
  }

  String get _unToggledButtonTitle{
    return Localization().getStringEx('panel.onboarding2.explore_campus.button.untoggle.title', 'Do not enable location services.');
  }
}