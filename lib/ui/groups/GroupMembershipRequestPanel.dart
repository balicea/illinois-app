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
import 'package:rokwire_plugin/model/group.dart';
import 'package:illinois/ext/Group.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:rokwire_plugin/service/groups.dart';
import 'package:rokwire_plugin/service/localization.dart';
import 'package:illinois/ui/widgets/HeaderBar.dart';
import 'package:rokwire_plugin/ui/widgets/rounded_button.dart';
import 'package:illinois/ui/widgets/TabBar.dart' as uiuc;
import 'package:illinois/utils/AppUtils.dart';
import 'package:rokwire_plugin/service/styles.dart';

class GroupMembershipRequestPanel extends StatefulWidget implements AnalyticsPageAttributes {
  final Group? group;

  GroupMembershipRequestPanel({this.group});

  @override
  _GroupMembershipRequestPanelState createState() =>
      _GroupMembershipRequestPanelState();

  @override
  Map<String, dynamic>? get analyticsPageAttributes =>
    group?.analyticsAttributes;
}

class _GroupMembershipRequestPanelState extends State<GroupMembershipRequestPanel> {
  late List<GroupMembershipQuestion> _questions;
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  bool? _submitting;

  @override
  void initState() {
    _focusNodes = [];
    _controllers = [];
    _questions = widget.group?.questions ?? [];
    for (int index = 0; index < _questions.length; index++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    super.initState();
  }

  @override
  void dispose() {
    for (int index = 0; index < _questions.length; index++) {
      _controllers[index].dispose();
      _focusNodes[index].dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [
      _buildHeading()
    ];

    content.addAll(_buildQuestions());

    return Scaffold(
      appBar: HeaderBar(
        title: Localization().getStringEx("panel.membership_request.label.request.title", 'Membership Questions'),
        leadingAsset: 'images/icon-circle-close.png',
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(padding: EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content,),
              ),
            ),
          ),
          _buildSubmit(),
        ],
      ),
      backgroundColor: Styles().colors!.background,
      bottomNavigationBar: uiuc.TabBar(),
    );
  }

  Widget _buildHeading() {
    return Text(Localization().getStringEx("panel.membership_request.label.description", 'This group asks you to answer the following question(s) for membership consideration.'), style: TextStyle(fontFamily: Styles().fontFamilies!.regular, fontSize: 16, color: Color(0xff494949)));
  }

  List<Widget> _buildQuestions() {
    List<Widget> content = [];
    for (int index = 0; index < _questions.length; index++) {
      content.add(_buildQuestion(question: _questions[index].question!, controller:_controllers[index], focusNode: _focusNodes[index]));
    }
    return content;
  }

  Widget _buildQuestion({required String question, TextEditingController? controller, FocusNode? focusNode}) {
    return Padding(padding: EdgeInsets.symmetric(vertical:16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(question, style: TextStyle(fontFamily: Styles().fontFamilies!.bold, fontSize: 16, color: Styles().colors!.fillColorPrimary),),
        Padding(padding: EdgeInsets.only(top: 8),
          child: TextField(
            maxLines: 6,
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1.0))),
            style: TextStyle(fontFamily: Styles().fontFamilies!.regular, fontSize: 16, color: Styles().colors!.textBackground,),
          ),
        ),
      ],)
    ,);
  }

  Widget _buildSubmit() {
    return Container(color: Colors.white,
      child: Padding(padding: EdgeInsets.all(16),
        child: Stack(children: <Widget>[
          Row(children: <Widget>[
            Expanded(child: Container(),),
            RoundedButton(label: Localization().getStringEx("panel.membership_request.button.submit.title", 'Submit request'),
              backgroundColor: Styles().colors!.white,
              textColor: Styles().colors!.fillColorPrimary,
              fontFamily: Styles().fontFamilies!.bold,
              fontSize: 16,
              borderColor: Styles().colors!.fillColorSecondary,
              borderWidth: 2,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              contentWeight: 0.0,
              onTap:() { _onSubmit();  }
            ),
            Expanded(child: Container(),),
          ],),
          Visibility(visible: (_submitting == true), child:
            Center(child:
              Padding(padding: EdgeInsets.only(top: 10.5), child:
               Container(width: 21, height:21, child:
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color?>(Styles().colors!.fillColorSecondary), strokeWidth: 2,)
                ),
              ),
            ),
          ),
        ],),
      ),
    );
  }

  void _onSubmit() {
    Analytics().logSelect(target: 'Submit request');
    if (_submitting != true) {
      List<GroupMembershipAnswer> answers = [];
      for (int index = 0; index < _questions.length; index++) {
        String? question = _questions[index].question;
        TextEditingController controller = _controllers[index];
        FocusNode focusNode = _focusNodes[index];
        String answer = controller.text;
        if (0 < answer.length) {
          answers.add(GroupMembershipAnswer(question: question, answer: answer));
        }
        else {
          AppAlert.showDialogResult(context,Localization().getStringEx("panel.membership_request.label.alert",  'Please answer ')+ question!).then((_){
            focusNode.requestFocus();
          });
          return;
        }
      }

      setState(() {
        _submitting = true;
      });

      Groups().requestMembership(widget.group, answers).then((_){
        if (mounted) {
          setState(() {
            _submitting = false;
          });
          Navigator.pop(context);
        }
      }).catchError((_){
        AppAlert.showDialogResult(context, Localization().getStringEx("panel.membership_request.label.fail", 'Failed to submit request'));
      });
    }
  }
}