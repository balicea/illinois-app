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

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:illinois/model/Groups.dart';
import 'package:illinois/model/ImageType.dart';
import 'package:illinois/service/AppDateTime.dart';
import 'package:illinois/service/ExploreService.dart';
import 'package:illinois/service/Groups.dart';
import 'package:illinois/service/ImageService.dart';
import 'package:illinois/service/NativeCommunicator.dart';
import 'package:illinois/service/Localization.dart';
import 'package:illinois/model/Event.dart';
import 'package:illinois/model/Location.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/ui/WebPanel.dart';
import 'package:illinois/ui/groups/GroupsEventDetailPanel.dart';
import 'package:illinois/ui/widgets/ScalableWidgets.dart';
import 'package:illinois/ui/widgets/TrianglePainter.dart';
import 'package:illinois/ui/explore/ExploreEventDetailPanel.dart';
import 'package:illinois/ui/widgets/HeaderBar.dart';
import 'package:illinois/ui/widgets/TabBarWidget.dart';
import 'package:illinois/ui/widgets/RoundedButton.dart';
import 'package:illinois/ui/widgets/RibbonButton.dart';
import 'package:illinois/utils/Utils.dart';
import 'package:illinois/service/Styles.dart';
import 'package:intl/intl.dart';


class CreateEventPanel extends StatefulWidget {
  final GroupEvent editEvent;
  final Function onEditTap;
  final Group group;

  const CreateEventPanel({Key key, this.editEvent, this.onEditTap, this.group}) : super(key: key);

  @override
  _CreateEventPanelState createState() => _CreateEventPanelState();
}

class _CreateEventPanelState extends State<CreateEventPanel> {
  final double _imageHeight = 208;

  List<dynamic> _eventCategories;

  dynamic _selectedCategory;
  String _imageUrl;
  DateTime startDate;
  DateTime endDate;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool _allDay = false;
  Location _location;
  bool _isOnline = false;

  bool _loading = false;

  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventPurchaseUrlController = TextEditingController();
  final _eventWebsiteController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _eventCallUrlController = TextEditingController();

  @override
  void initState() {
    _loadEventCategories();
    _prepopulateWithUpdateEvent();
    super.initState();
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _eventPurchaseUrlController.dispose();
    _eventWebsiteController.dispose();
    _eventLocationController.dispose();
    _eventCallUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SimpleHeaderBarWithBack(
          context: context,
          titleWidget: Text(Localization().getStringEx("panel.create_event.header.title", "Create An Event"),
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0),
          ),
        ),
        body: _buildContent(),
        backgroundColor: Styles().colors.background,
        bottomNavigationBar: TabBarWidget(),
    );
}

  Widget _buildContent() {
    bool isEdit = widget.editEvent!=null;

    return Stack(children: <Widget>[
          Container(
            color: Colors.white,
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[

                        Semantics(label:Localization().getStringEx("panel.create_event.title","Create an Event"),
                        hint: Localization().getStringEx("panel.create_event.hint", ""), header: true, excludeSemantics: true, child:
                          Container(
                            color: Styles().colors.fillColorPrimaryVariant,
                            height: 56,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('images/icon-create-event.png'),
                                  Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: Text(
                                      Localization().getStringEx("panel.create_event.title","Create an Event"),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: Styles().fontFamilies.extraBold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            Container(
                              color: Styles().colors.lightGray,
                              height: _imageHeight,
                            ),
                            CustomPaint(
                                painter: TrianglePainter(
                                    painterColor: Styles().colors.fillColorSecondary,
                                    left: false),
                                child: Container(
                                  height: 48,
                                )),
                            CustomPaint(
                              painter:
                                  TrianglePainter(painterColor: Colors.white),
                              child: Container(
                                height: 25,
                              ),
                            ),
                            Container(
                              height: _imageHeight,
                              child: Center(
                                child:
                                Semantics(label:Localization().getStringEx("panel.create_event.add_image","Add event image"),
                                  hint: Localization().getStringEx("panel.create_event.add_image.hint",""), button: true, excludeSemantics: true, child:
                                  ScalableSmallRoundedButton(
                                    label: Localization().getStringEx("panel.create_event.add_image","Add event image"),
                                    onTap: _onTapAddImage,
                                    backgroundColor: Styles().colors.white,
                                    textColor: Styles().colors.fillColorPrimary,
                                    borderColor: Styles().colors.fillColorSecondary,
                                    showChevron: false,
                                  )
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 24, right: 24, top: 16, bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Semantics(label:Localization().getStringEx("panel.create_event.category.title","EVENT CATEGORY"),
                          hint: Localization().getStringEx("panel.create_event.category.title.hint","Choose the category your event may be filtered by."), header: true, excludeSemantics: true, child:
                              Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      Localization().getStringEx("panel.create_event.category.title","EVENT CATEGORY"),
                                      style: TextStyle(
                                          color: Styles().colors.fillColorPrimary,
                                          fontSize: 14,
                                          fontFamily: Styles().fontFamilies.bold,
                                          letterSpacing: 1),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 2),
                                      child: Text(
                                        '*',
                                        style: TextStyle(
                                            color: Styles().colors.fillColorSecondary,
                                            fontSize: 14,
                                            fontFamily: Styles().fontFamilies.bold),
                                      ),
                                    )
                                  ],
                                ),
                              Padding(
                                padding: EdgeInsets.only(top: 2, bottom: 8),
                                child: Text(
                                  Localization().getStringEx("panel.create_event.category.description",'Choose the category your event may be filtered by.'),
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Styles().colors.textBackground,
                                      fontSize: 14,
                                      fontFamily: Styles().fontFamilies.regular),
                                ),
                              ),
                              ])),
                              Padding(
                                padding: EdgeInsets.only(bottom: 24),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Styles().colors.surfaceAccent,
                                          width: 1),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4))),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 12, right: 8),
                                    child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                            icon: Image.asset(
                                                'images/icon-down-orange.png'),
                                            isExpanded: true,
                                            style: TextStyle(
                                                color: Styles().colors.mediumGray,
                                                fontSize: 16,
                                                fontFamily:
                                                    Styles().fontFamilies.regular),
                                            hint: Text(
                                              (_selectedCategory != null)
                                                  ? _selectedCategory[
                                                      'category']
                                                  : Localization().getStringEx("panel.create_event.category.default","Category"),
                                            ),
                                            items: _buildDropDownItems(),
                                            onChanged:
                                                _onDropDownValueChanged)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child:
                                Semantics(label:Localization().getStringEx("panel.create_event.title.title","EVENT TITLE"),
                                  hint: Localization().getStringEx("panel.create_event.title.title.hint",""), header: true, excludeSemantics: true, child:
                                  Row(
                                    children: <Widget>[
                                      Text(
                                      Localization().getStringEx("panel.create_event.title.title","EVENT TITLE"),
                                        style: TextStyle(
                                            color: Styles().colors.fillColorPrimary,
                                            fontSize: 14,
                                            fontFamily: Styles().fontFamilies.bold,
                                            letterSpacing: 1),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 2),
                                        child: Text(
                                          '*',
                                          style: TextStyle(
                                              color: Styles().colors.fillColorSecondary,
                                              fontSize: 14,
                                              fontFamily: Styles().fontFamilies.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Styles().colors.fillColorPrimary,
                                        width: 1)),
                                height: 90,
                                child:
                                Semantics(label:Localization().getStringEx("panel.create_event.title.field","EVENT TITLE FIELD"),
                                  hint: Localization().getStringEx("panel.create_event.title.title.hint",""), textField: true, excludeSemantics: true, child:
                                  TextField(
                                    controller: _eventTitleController,
                                    decoration:
                                        InputDecoration(border: InputBorder.none),
                                    maxLength: 64,
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    style: TextStyle(
                                        color: Styles().colors.fillColorPrimary,
                                        fontSize: 32,
                                        fontFamily: Styles().fontFamilies.extraBold),
                                  )
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Container(
                            color: Styles().colors.surfaceAccent,
                            height: 1,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 24),
                                    child:
                                    Semantics(label:Localization().getStringEx("panel.create_event.date_time.title","Date and time"),
                                      hint: Localization().getStringEx("panel.create_event.date_time.hint",""), header: true, excludeSemantics: true, child:
                                      Row(
                                        children: <Widget>[
                                          Image.asset('images/icon-calendar.png'),
                                          Padding(
                                            padding: EdgeInsets.only(left: 3),
                                            child: Text(
                                              Localization().getStringEx("panel.create_event.date_time.title","Date and time"),
                                              style: TextStyle(
                                                  color:
                                                      Styles().colors.fillColorPrimary,
                                                  fontSize: 16,
                                                  fontFamily: Styles().fontFamilies.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                       Expanded(
                                         flex:2,
                                         child: Semantics(label:Localization().getStringEx("panel.create_event.date_time.start_date.title","START DATE"),
                                             hint: Localization().getStringEx("panel.create_event.date_time.start_date.hint",""), button: true, excludeSemantics: true, child:
                                             Column(
                                               crossAxisAlignment:
                                               CrossAxisAlignment.start,
                                               children: <Widget>[
                                                 Padding(
                                                   padding:
                                                   EdgeInsets.only(bottom: 8),
                                                   child:
                                                   Row(
                                                     children: <Widget>[
                                                       Text(
                                                         Localization().getStringEx("panel.create_event.date_time.start_date.title","START DATE"),
                                                         style: TextStyle(
                                                             color: Styles().colors.fillColorPrimary,
                                                             fontSize: 14,
                                                             fontFamily:
                                                             Styles().fontFamilies.bold,
                                                             letterSpacing: 1),
                                                       ),
                                                       Padding(
                                                         padding: EdgeInsets.only(
                                                             left: 2),
                                                         child: Text(
                                                           '*',
                                                           style: TextStyle(
                                                               color: Styles().colors.fillColorSecondary,
                                                               fontSize: 14,
                                                               fontFamily:
                                                               Styles().fontFamilies.bold),
                                                         ),
                                                       )
                                                     ],
                                                   ),
                                                 ),
                                                 _EventDateDisplayView(
                                                   label: startDate != null
                                                       ? AppDateTime()
                                                       .formatDateTime(
                                                       startDate,
                                                       format: "EEE, MMM dd, yyyy")
                                                       : "-",
                                                   onTap: _onTapStartDate,
                                                 )
                                               ],
                                             )
                                         ),
                                       ),
                                    Container(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: Semantics(label:Localization().getStringEx("panel.create_event.date_time.start_time.title",'START TIME'),
                                          hint: Localization().getStringEx("panel.create_event.date_time.start_time.hint",""), button: true, excludeSemantics: true, child:
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                EdgeInsets.only(bottom: 8),
                                                child:
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(child:
                                                      Text(
                                                        Localization().getStringEx("panel.create_event.date_time.start_time.title","START TIME"),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            color: Styles().colors.fillColorPrimary,
                                                            fontSize: 14,
                                                            fontFamily:
                                                            Styles().fontFamilies.bold,
                                                            letterSpacing: 1),
                                                      )
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 2),
                                                      child: Text(
                                                        '*',
                                                        style: TextStyle(
                                                            color: Styles().colors.fillColorSecondary,
                                                            fontSize: 14,
                                                            fontFamily:
                                                            Styles().fontFamilies.bold),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              _EventDateDisplayView(
                                                label: startTime != null &&
                                                    !_allDay
                                                    ? DateFormat("h:mma").format(
                                                    _populateDateTimeWithTimeOfDay(
                                                        startDate,
                                                        startTime) ??
                                                        (_populateDateTimeWithTimeOfDay(
                                                            DateTime.now(),
                                                            startTime)))
                                                    : "-",
                                                onTap: _onTapStartTime,
                                              )
                                            ],
                                          )
                                      ),
                                    ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Semantics(label:Localization().getStringEx("panel.create_event.date_time.end_date.title",'END DATE'),
                                              hint: Localization().getStringEx("panel.create_event.date_time.end_date.hint",""), button: true, excludeSemantics: true, child:
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                    EdgeInsets.only(bottom: 8),
                                                    child:
                                                    Row(
                                                      children: <Widget>[
                                                        Text(
                                                          Localization().getStringEx("panel.create_event.date_time.end_date.title",'END DATE'),
                                                          style: TextStyle(
                                                              color: Styles().colors.fillColorPrimary,
                                                              fontSize: 14,
                                                              fontFamily:
                                                              Styles().fontFamilies.bold,
                                                              letterSpacing: 1),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                              left: 2),
                                                          child: Text(
                                                            '*',
                                                            style: TextStyle(
                                                                color: Styles().colors.fillColorSecondary,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                Styles().fontFamilies.bold),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  _EventDateDisplayView(
                                                    label: endDate != null
                                                        ? AppDateTime()
                                                        .formatDateTime(
                                                        endDate,
                                                        format: "EEE, MMM dd, yyyy")
                                                        : "-",
                                                    onTap: _onTapEndDate,
                                                  )
                                                ],
                                              )
                                          ),
                                        ),
                                        Container(width: 10,),
                                        Expanded(
                                          flex: 1,
                                          child: Semantics(label:Localization().getStringEx("panel.create_event.date_time.end_time.title",'END TIME'),
                                              hint: Localization().getStringEx("panel.create_event.date_time.end_time.hint",""), button: true, excludeSemantics: true, child:
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                    EdgeInsets.only(bottom: 8),
                                                    child:
                                                    Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            Localization().getStringEx("panel.create_event.date_time.end_time.title","END TIME"),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: Styles().colors.fillColorPrimary,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                Styles().fontFamilies.bold,
                                                                letterSpacing: 1),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                              left: 2),
                                                          child: Text(
                                                            '*',
                                                            style: TextStyle(
                                                                color: Styles().colors.fillColorSecondary,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                Styles().fontFamilies.bold),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  _EventDateDisplayView(
                                                    label: endTime != null && !_allDay
                                                        ? DateFormat("h:mma").format(
                                                        _populateDateTimeWithTimeOfDay(
                                                            endDate,
                                                            endTime) ??
                                                            (_populateDateTimeWithTimeOfDay(
                                                                startDate,
                                                                endTime) ??
                                                                _populateDateTimeWithTimeOfDay(
                                                                    DateTime
                                                                        .now(),
                                                                    endTime)))
                                                        : "-",
                                                    onTap: _onTapEndTime,
                                                  )
                                                ],
                                              )
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                  Semantics(label:Localization().getStringEx("panel.create_event.date_time.all_day","All Day"),
                                      hint: Localization().getStringEx("panel.create_event.date_time.all_day.hint",""), toggled: true, excludeSemantics: true, child:
                                  ToggleRibbonButton(
                                    height: null,
                                    label: Localization().getStringEx("panel.create_event.date_time.all_day","All Day"),
                                    toggled: _allDay,
                                    onTap: _onAllDayToggled,
                                    context: context,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ))
                                ])),
                        Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Container(
                            color: Styles().colors.surfaceAccent,
                            height: 1,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 24),
                                    child:
                                    Semantics(label:Localization().getStringEx("panel.create_event.location.button_title","Location"),
                                         header: true, excludeSemantics: true, child:
                                    Row(
                                      children: <Widget>[
                                        Image.asset('images/icon-location.png'),
                                        Padding(
                                          padding: EdgeInsets.only(left: 3),
                                          child: Text(
                                            Localization().getStringEx("panel.create_event.location.button_title","Location"),
                                            style: TextStyle(
                                                color:
                                                    Styles().colors.fillColorPrimary,
                                                fontSize: 16,
                                                fontFamily: Styles().fontFamilies.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                  ),
                                  (_isOnline) ? Container():
                                  Column(
                                      children: [
                                        Semantics(label:Localization().getStringEx("panel.create_event.location.adress.title",'EVENT ADDRESS'),
                                            header: true, excludeSemantics: true, child:
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                    Localization().getStringEx("panel.create_event.location.adress.title",'EVENT ADDRESS'),
                                                    style: TextStyle(
                                                        color: Styles().colors.fillColorPrimary,
                                                        fontSize: 14,
                                                        fontFamily: Styles().fontFamilies.bold,
                                                        letterSpacing: 1),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 2),
                                                    child: Text(
                                                      '*',
                                                      style: TextStyle(
                                                          color: Styles().colors.fillColorSecondary,
                                                          fontSize: 14,
                                                          fontFamily: Styles().fontFamilies.bold),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                        ),
                                        Semantics(label:Localization().getStringEx("panel.create_event.location.adress.title",'EVENT ADDRESS'),
                                            hint: Localization().getStringEx("panel.create_event.location.adress.title.hint",''), textField: true, excludeSemantics: true, child:
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 16),
                                              child: Container(
                                                padding:
                                                EdgeInsets.symmetric(horizontal: 12),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Styles().colors.fillColorPrimary,
                                                        width: 1)),
                                                height: 48,
                                                child: TextField(
                                                  controller: _eventLocationController,
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none),
                                                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                                  style: TextStyle(
                                                      color: Styles().colors.fillColorPrimary,
                                                      fontSize: 20,
                                                      fontFamily: Styles().fontFamilies.medium),
                                                ),
                                              ),
                                            )
                                        ),
                                        Semantics(label:Localization().getStringEx("panel.create_event.location.button.select_location.title","Select location on a map"),
                                            hint: Localization().getStringEx("panel.create_event.location.button.select_location.button.hint",""), button: true, excludeSemantics: true, child:
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                    child: ScalableRoundedButton(
                                                      backgroundColor: Styles().colors.white,
                                                      textColor: Styles().colors.fillColorPrimary,
                                                      borderColor: Styles().colors.fillColorSecondary,
                                                      fontSize: 16,
                                                      onTap: _onTapSelectLocation,
                                                      label: Localization().getStringEx("panel.create_event.location.button.select_location.title","Select location on a map"),
                                                      showChevron: false,
                                                    ))
                                              ],
                                            )),
                                      ]),
                                      (!_isOnline) ? Container():
                                      Column(
                                        children: [
                                          Semantics(label:Localization().getStringEx("panel.create_event.additional_info.call_url.title","LINK TO VIDEO CALL"),
                                              hint: Localization().getStringEx("panel.create_event.additional_info.call_url.hint",""), textField: true, excludeSemantics: true, child:
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: 8),
                                                      child: Text(
                                                        Localization().getStringEx("panel.create_event.additional_info.call_url.title","LINK TO VIDEO CALL"),
                                                        style: TextStyle(
                                                            color: Styles().colors.fillColorPrimary,
                                                            fontSize: 14,
                                                            fontFamily: Styles().fontFamilies.bold,
                                                            letterSpacing: 1),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: 12),
                                                      child: Container(
                                                        padding:
                                                        EdgeInsets.symmetric(horizontal: 12),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                color: Styles().colors.fillColorPrimary,
                                                                width: 1)),
                                                        height: 48,
                                                        child: TextField(
                                                          controller: _eventCallUrlController,
                                                          decoration: InputDecoration(
                                                              border: InputBorder.none),
                                                          style: TextStyle(
                                                              color: Styles().colors.fillColorPrimary,
                                                              fontSize: 16,
                                                              fontFamily: Styles().fontFamilies.regular),
                                                        ),
                                                      ),
                                                    ),
                                                  ])),
                                          Semantics(label:Localization().getStringEx("panel.create_event.additional_info.button.confirm.call_url",'Confirm video call URL'),
                                            hint: Localization().getStringEx("panel.create_event.additional_info.button.confirm.hint",""), button: true, excludeSemantics: true, child:
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 24),
                                              child: GestureDetector(
                                                onTap: _onTapConfirmCallUrl,
                                                child: Text(
                                                  Localization().getStringEx("panel.create_event.additional_info.button.confirm.title",'Confirm URL'),
                                                  style: TextStyle(
                                                      color: Styles().colors.fillColorPrimary,
                                                      fontSize: 16,
                                                      fontFamily: Styles().fontFamilies.medium,
                                                      decoration: TextDecoration.underline,
                                                      decorationThickness: 1,
                                                      decorationColor:
                                                      Styles().colors.fillColorSecondary),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  Container(height: 18,),
                                  Semantics(label:Localization().getStringEx("panel.create_event.date_time.online","Make this an online event"),
                                      hint: Localization().getStringEx("panel.create_event.date_time.all_day.hint",""), toggled: true, excludeSemantics: true, child:
                                      ToggleRibbonButton(
                                        height: null,
                                        label: Localization().getStringEx("panel.create_event.date_time.online","Make this an online event"),
                                        toggled: _isOnline,
                                        onTap: _onOnlineToggled,
                                        context: context,
                                        border: Border.all(color: Styles().colors.fillColorPrimary),
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                      ))
                                ])),
                        Container(
                          color: Styles().colors.background,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 24, right: 24, top: 25, bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Semantics(label:Localization().getStringEx("panel.create_event.additional_info.title","Additional event information"),
                                    header: true, excludeSemantics: true, child:
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 24),
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset(
                                              'images/icon-campus-tools.png'),
                                          Expanded(child:
                                            Padding(
                                              padding: EdgeInsets.only(left: 3),
                                              child: Text(
                                                Localization().getStringEx("panel.create_event.additional_info.title","Additional event information"),
                                                style: TextStyle(
                                                    color: Styles().colors.fillColorPrimary,
                                                    fontSize: 16,
                                                    fontFamily: Styles().fontFamilies.bold),
                                              ),
                                            )
                                          )
                                        ],
                                      ),
                                    )
                                ),
                                Semantics(label:Localization().getStringEx("panel.create_event.additional_info.description.title","DESCRIPTION"),
                                    header: true, excludeSemantics: true, child:
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          Localization().getStringEx("panel.create_event.additional_info.description.title","DESCRIPTION"),
                                          style: TextStyle(
                                              color: Styles().colors.fillColorPrimary,
                                              fontSize: 14,
                                              fontFamily: Styles().fontFamilies.bold,
                                              letterSpacing: 1),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 2),
                                          child: Text(
                                            '*',
                                            style: TextStyle(
                                                color: Styles().colors.fillColorSecondary,
                                                fontSize: 14,
                                                fontFamily: Styles().fontFamilies.bold),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ),
                                Semantics(label:Localization().getStringEx("panel.create_event.additional_info.event.description","Tell the campus what your event is about."),
                                  hint: Localization().getStringEx("panel.create_event.additional_info.event.description.hint","Type something"), textField: true, excludeSemantics: true, child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          Localization().getStringEx("panel.create_event.additional_info.event.description","Tell the campus what your event is about."),
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Styles().colors.textBackground,
                                              fontSize: 14,
                                              fontFamily: Styles().fontFamilies.regular),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 24),
                                        child: Container(
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Styles().colors.fillColorPrimary,
                                                  width: 1)),
                                          height: 120,
                                          child: TextField(
                                            controller: _eventDescriptionController,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: Localization().getStringEx("panel.create_event.additional_info.event.description.hint","Type something"),
                                                hintStyle: TextStyle(
                                                    color: Styles().colors.textBackground,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        Styles().fontFamilies.regular)),
                                            style: TextStyle(
                                                color: Styles().colors.fillColorPrimary,
                                                fontSize: 16,
                                                fontFamily: Styles().fontFamilies.regular),
                                          ),
                                        ),
                                      ),
                                ])),
                                Semantics(label:Localization().getStringEx("panel.create_event.additional_info.purchase_tickets.title","ADD LINK TO PURCHASE TICKETS"),
                                  hint: Localization().getStringEx("panel.create_event.additional_info.purchase_tickets.hint",""), textField: true, excludeSemantics: true, child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          Localization().getStringEx("panel.create_event.additional_info.purchase_tickets.title","ADD LINK TO PURCHASE TICKETS"),
                                          style: TextStyle(
                                              color: Styles().colors.fillColorPrimary,
                                              fontSize: 14,
                                              fontFamily: Styles().fontFamilies.bold,
                                              letterSpacing: 1),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: Container(
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Styles().colors.fillColorPrimary,
                                                  width: 1)),
                                          height: 48,
                                          child: TextField(
                                            controller: _eventPurchaseUrlController,
                                            decoration: InputDecoration(
                                                border: InputBorder.none),
                                            style: TextStyle(
                                                color: Styles().colors.fillColorPrimary,
                                                fontSize: 16,
                                                fontFamily: Styles().fontFamilies.regular),
                                          ),
                                        ),
                                      ),
                                ])),
                                Semantics(label:Localization().getStringEx("panel.create_event.additional_info.button.confirm.purchase_tickets",'Confirm purchase tickets URL'),
                                  hint: Localization().getStringEx("panel.create_event.additional_info.button.confirm.hint",""), button: true, excludeSemantics: true, child:
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 24),
                                        child: GestureDetector(
                                          onTap: _onTapConfirmPurchaseUrl,
                                          child: Text(
                                            Localization().getStringEx("panel.create_event.additional_info.button.confirm.title",'Confirm URL'),
                                            style: TextStyle(
                                                color: Styles().colors.fillColorPrimary,
                                                fontSize: 16,
                                                fontFamily: Styles().fontFamilies.medium,
                                                decoration: TextDecoration.underline,
                                                decorationThickness: 1,
                                                decorationColor:
                                                    Styles().colors.fillColorSecondary),
                                          ),
                                        ),
                                      ),
                                ),
                                Semantics(label:Localization().getStringEx("panel.create_event.additional_info.website.title",'ADD EVENT WEBSITE LINK'),
                                  hint: Localization().getStringEx("panel.create_event.additional_info.website.hint",""), textField: true, excludeSemantics: true, child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          Localization().getStringEx("panel.create_event.additional_info.website.title",'ADD EVENT WEBSITE LINK'),
                                          style: TextStyle(
                                              color: Styles().colors.fillColorPrimary,
                                              fontSize: 14,
                                              fontFamily: Styles().fontFamilies.bold,
                                              letterSpacing: 1),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: Container(
                                          padding:
                                              EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Styles().colors.fillColorPrimary,
                                                  width: 1)),
                                          height: 48,
                                          child: TextField(
                                            controller: _eventWebsiteController,
                                            decoration: InputDecoration(
                                                border: InputBorder.none),
                                            style: TextStyle(
                                                color: Styles().colors.fillColorPrimary,
                                                fontSize: 16,
                                                fontFamily: Styles().fontFamilies.regular),
                                          ),
                                        ),
                                      ),
                                    ]
                                  )
                                ),
                                Semantics(label:Localization().getStringEx("panel.create_event.additional_info.button.confirm.website",'Confirm website URL'),
                                  hint: Localization().getStringEx("panel.create_event.additional_info.button.confirm.hint",""), button: true, excludeSemantics: true, child:
                                      GestureDetector(
                                        onTap: _onTapConfirmWebsiteUrl,
                                        child: Text(
                                          Localization().getStringEx("panel.create_event.additional_info.button.confirm.title",'Confirm URL'),
                                          style: TextStyle(
                                              color: Styles().colors.fillColorPrimary,
                                              fontSize: 16,
                                              fontFamily: Styles().fontFamilies.medium,
                                              decoration: TextDecoration.underline,
                                              decorationThickness: 1,
                                              decorationColor:
                                                  Styles().colors.fillColorSecondary),
                                        ),
                                      )
                                ),
                                (GroupPrivacy.public == widget.group?.privacy)?
                                  Container(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                      Localization().getStringEx("panel.create_event.additional_info.group.description","This event will only show up on your group's page. Only members can see it"),
                                      style: TextStyle(
                                          color: Styles().colors.textSurface,
                                          fontSize: 16,
                                          fontFamily: Styles().fontFamilies.regular,
                                      ),
                                    ),
                                  ) : Container()
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              (widget.group!=null)? Container():
                              Expanded(
                                  child: RoundedButton(
                                    label:  Localization().getStringEx("panel.create_event.additional_info.button.cancel.title","Cancel"),
                                    backgroundColor: Colors.white,
                                    borderColor: Styles().colors.fillColorPrimary,
                                    textColor: Styles().colors.fillColorPrimary,
                                    onTap: _onTapCancel,
                                  )),
                              (widget.group!=null)? Container():
                              Container(
                                width: 6,
                              ),
                              (widget.group!=null)? Container():
                              Expanded(
                                  child: RoundedButton(
                                label: isEdit?  Localization().getStringEx("panel.create_event.additional_info.button.edint.title","Update Event"):
                                                Localization().getStringEx("panel.create_event.additional_info.button.preview.title","Preview"),
                                backgroundColor: Colors.white,
                                borderColor: Styles().colors.fillColorSecondary,
                                textColor: Styles().colors.fillColorPrimary,
                                onTap: isEdit? (){
                                  widget.onEditTap(_populateEventWithData(widget.editEvent));
                                } : _onTapPreview,
                              )),
                              (widget.group==null)? Container():
                              Expanded(
                                  child: ScalableRoundedButton(
                                    label: isEdit?  Localization().getStringEx("panel.create_event.additional_info.button.edint.title","Update Event"):
                                    Localization().getStringEx("panel.create_event.additional_info.button.create.title","Create event"),
                                    backgroundColor: Colors.white,
                                    borderColor: Styles().colors.fillColorSecondary,
                                    textColor: Styles().colors.fillColorPrimary,
                                    onTap: isEdit? (){
                                      widget.onEditTap(_populateEventWithData(widget.editEvent));
                                    } : _onTapCreate,
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        ]);
  }

  void _prepopulateWithUpdateEvent(){
    Event event = widget.editEvent;

    if(event!=null) {
      _imageUrl = event.imageURL;
      event.category = _selectedCategory != null ? _selectedCategory["category"] : null;
      if (event.category != null)
        _selectedCategory = {"category": event.category};

      _eventTitleController.text = event.title;
//      startDate = AppDateTime().dateTimeFromString(event.startDateString, format: AppDateTime.eventsServerCreateDateTimeFormat);
      startDate = event.startDateGmt;
      if(startDate!=null)
        startTime = TimeOfDay.fromDateTime(startDate);
//      endDate = AppDateTime().dateTimeFromString(event.endDateString, format: AppDateTime.eventsServerCreateDateTimeFormat);
      endDate = event.endDateGmt;
      if(endDate!=null)
        endTime = TimeOfDay.fromDateTime(endDate);
      _allDay = event.allDay;
      _location = event.location;
      _eventDescriptionController.text = event.longDescription;
      _eventPurchaseUrlController.text = event.registrationUrl;
      _eventWebsiteController.text = event.titleUrl;
    }
  }

  void _loadEventCategories() async {
    _setLoading(true);
    _eventCategories = await ExploreService().loadEventCategories();
    _setLoading(false);
  }

  List<DropdownMenuItem<dynamic>> _buildDropDownItems() {
    int categoriesCount = _eventCategories?.length ?? 0;
    if (categoriesCount == 0) {
      return null;
    }
    return _eventCategories.map((dynamic category) {
      return DropdownMenuItem<dynamic>(
        value: category,
        child: Text(
          category['category'],
        ),
      );
    }).toList();
  }

  void _onDropDownValueChanged(dynamic value) {
    Analytics.instance.logSelect(target: "Category selected: $value");
    setState(() {
      _selectedCategory = value;
    });
  }

  void _onTapAddImage() async {
    Analytics.instance.logSelect(target: "Add Image");
    _imageUrl = await showDialog(
        context: context,
        builder: (_) => Material(
          type: MaterialType.transparency,
          child: AddImageWidget(),
        )
    );
  }

  void _onAllDayToggled() {
    _allDay = !_allDay;
    setState(() {});
  }

  void _onOnlineToggled() {
    _isOnline = !_isOnline;
    setState(() {});
  }

  void _onTapSelectLocation() {
    Analytics.instance.logSelect(target: "Select Location");
    _performSelectLocation();
  }

  void _performSelectLocation() async {
    _setLoading(true);

    String location = await NativeCommunicator().launchSelectLocation();
    _setLoading(false);
    if (location != null) {
      Map<String, dynamic> locationSelectionResult = jsonDecode(location);
      if (locationSelectionResult != null &&
          locationSelectionResult.isNotEmpty) {
        Map<String, dynamic> locationData = locationSelectionResult["location"];
        if (locationData != null) {
          _location = Location.fromJSON(locationData);
          _populateLocationField();
          setState(() {});
        }
      }
    }
  }

  void _populateLocationField() {
    if (_location != null) {
      String locationName;
      if ((_location.name != null) && _location.name.isNotEmpty) {
        locationName = _location.name;
      }
      else if ((_location.address != null) && _location.address.isNotEmpty) {
        locationName = _location.address;
      } else {
        locationName =  Localization().getStringEx("panel.create_event.location.custom.title","CUSTOM");
      }
      _location.name = locationName;
      _eventLocationController.text = locationName;

      if(AppString.isStringNotEmpty(_location.description)){
        _eventCallUrlController?.text = _location.description;
      }
    }
  }

  void _onTapConfirmPurchaseUrl() {
    Analytics.instance.logSelect(target: "Confirm Purchase url");
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                WebPanel(url: _eventPurchaseUrlController.text)));
  }

  void _onTapConfirmCallUrl() {
    Analytics.instance.logSelect(target: "Confirm Purchase url");
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                WebPanel(url: _eventCallUrlController.text)));
  }

  void _onTapConfirmWebsiteUrl() {
    Analytics.instance.logSelect(target: "Confirm Website url");
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => WebPanel(url: _eventWebsiteController.text)));
  }

  void _onTapCancel() {
    Analytics.instance.logSelect(target: "Cancel");
    Navigator.pop(context);
  }

  void _onTapPreview() async {
    Analytics.instance.logSelect(target: "Preview");
    if (_isDataValid()) {
      Event event = _constructEventFromData();
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ExploreEventDetailPanel(
                  event: event, previewMode: true))).then((dynamic data) {
        if (data != null) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _onTapCreate() async {
    Analytics.instance.logSelect(target: "Create");
    if (_isDataValid()) {
      Event event = _constructEventFromData();
      //post event
      ExploreService().postNewEvent(event).then((bool success){
        if(success){
          Groups().linkEventToGroup(groupId: widget?.group?.id).then((value){
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => GroupEventDetailPanel(
                        event: event, previewMode: true))).then((dynamic data) {
              Navigator.pop(context);
            });
          });
        }else {
          AppToast.show("Unable to create Event");
        }
      });

    }
  }
  
  Event _populateEventWithData(Event event){
    if(_location==null) {
      _location = new Location();
    }
    _location.description = _isOnline? (_eventCallUrlController?.text?.toString()?? "") : (_eventLocationController?.text?.toString()?? "");

    event.imageURL = _imageUrl;
    event.category = _selectedCategory != null ? _selectedCategory["category"] : null;
    event.title = _eventTitleController.text;
    event.startDateString = AppDateTime().formatDateTime(
        startDate, format: AppDateTime.eventsServerCreateDateTimeFormat);
    event.endDateString = AppDateTime().formatDateTime(
        endDate, format: AppDateTime.eventsServerCreateDateTimeFormat);
    event.allDay = _allDay;
    event.location = _location;
    event.longDescription = _eventDescriptionController.text;
    event.registrationUrl = AppString.isStringNotEmpty(_eventPurchaseUrlController.text)?_eventPurchaseUrlController.text : null;
    event.titleUrl = _eventWebsiteController.text;
    event.isVirtual = _isOnline;

    return event;
  }

  Event _constructEventFromData(){
    Event event = Event();
    return _populateEventWithData(event);
  }

  void _onTapStartDate() async {
    Analytics.instance.logSelect(target: "Start Date");
    DateTime date = await _pickDate(startDate, null);

    if (date != null) {
      startDate = date;
      startDate = _populateDateTimeWithTimeOfDay(date, startTime);
    }
    setState(() {});
  }

  void _onTapStartTime() async {
    Analytics.instance.logSelect(target: "Start Time");
    DateTime start = startDate ?? DateTime.now();
    TimeOfDay time =
        await _pickTime(startTime ?? (new TimeOfDay.fromDateTime(start)));
    if (time != null) startTime = time;

    startDate = _populateDateTimeWithTimeOfDay(start, startTime);
    setState(() {});
  }

  void _onTapEndDate() async {
    Analytics.instance.logSelect(target: "End Date");
    DateTime date = await _pickDate(endDate, startDate);

    if (date != null) {
      endDate = date;
      endDate = _populateDateTimeWithTimeOfDay(date, endTime);
    }
    setState(() {});
  }

  void _onTapEndTime() async {
    Analytics.instance.logSelect(target: "End Time");
    DateTime end = endDate ?? DateTime.now();
    TimeOfDay time =
        await _pickTime(endTime ?? (new TimeOfDay.fromDateTime(end)));
    if (time != null) endTime = time;

    endDate = _populateDateTimeWithTimeOfDay(end, endTime);
    setState(() {});
  }

  void _setLoading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  Future<DateTime> _pickDate(DateTime date, DateTime startDate) async {
    DateTime firstDate = startDate ?? DateTime.now();
    date = date ?? firstDate;
    DateTime initialDate = date;
    if (firstDate.isAfter(date)) {
      firstDate = initialDate; //Fix exception
    }
    DateTime lastDate =
        DateTime.fromMillisecondsSinceEpoch(initialDate.millisecondsSinceEpoch)
            .add(Duration(days: 365));
    DateTime result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );

    return result;
  }

  Future<TimeOfDay> _pickTime(TimeOfDay initialTime) async {
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: initialTime);
    return time;
  }

  DateTime _populateDateTimeWithTimeOfDay(DateTime date, TimeOfDay time) {
    if (date != null && time != null) {
      int endHour = time != null ? time.hour : date.hour;
      int endMinute = time != null ? time.minute : date.minute;
      date = new DateTime(date.year, date.month, date.day, endHour, endMinute);
    }

    return date;
  }

  bool _isDataValid() {
    bool _categoryValidation = _selectedCategory != null || widget.group!=null; // Category is not required for group events
    bool _titleValidation =
        AppString.isStringNotEmpty(_eventTitleController.text);
    bool _locationValidation = _location != null || _isOnline;
    bool _startDateValidation = startDate != null;
    bool _startTimeValidation = startTime != null || _allDay;
    bool _endDateValidation = endDate != null;
    bool _endTimeValidation = endTime != null || _allDay;
    bool _propperStartEndTimeInterval = !(startDate?.isAfter(endDate) ?? true);
//    bool subCategoryIsValid = _subCategoryController.text?.isNotEmpty;

    if (!_categoryValidation) {
      AppAlert.showDialogResult(context,  Localization().getStringEx("panel.create_event.verification.category","Please select category"));
      return false;
    } else if (!_locationValidation) {
      AppAlert.showDialogResult(context, Localization().getStringEx("panel.create_event.verification.location","Please select location"));
      return false;
    } else if (!_titleValidation) {
      AppAlert.showDialogResult(context, Localization().getStringEx("panel.create_event.verification.title","Please add title"));
      return false;
    } else if (!_startDateValidation) {
      AppAlert.showDialogResult(context, Localization().getStringEx("panel.create_event.verification.start_date","Please select start date"));
      return false;
    } else if (!_startTimeValidation) {
      AppAlert.showDialogResult(context, Localization().getStringEx("panel.create_event.verification.start_time","Please select start time"));
      return false;
    } else if (!_endDateValidation) {
      AppAlert.showDialogResult(context, Localization().getStringEx("panel.create_event.verification.end_date","Please select end date"));
      return false;
    } else if (!_endTimeValidation) {
      AppAlert.showDialogResult(context, Localization().getStringEx("panel.create_event.verification.end_time","Please select end time"));
      return false;
    } else if (!_propperStartEndTimeInterval) {
      AppAlert.showDialogResult(context,
          Localization().getStringEx("panel.create_event.verification.date_time","Please select propper time interval. Start date cannot be after end date"));
      return false;
    }
    return true;
  }
}

class _EventDateDisplayView extends StatelessWidget {
  final String label;
  final GestureTapCallback onTap;

  _EventDateDisplayView({this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
//        width: 142,
        decoration: BoxDecoration(
            border: Border.all(color: Styles().colors.surfaceAccent, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              AppString.getDefaultEmptyString(value: label, defaultValue: '-'),
              style: TextStyle(
                  color: Styles().colors.fillColorPrimary,
                  fontSize: 16,
                  fontFamily: Styles().fontFamilies.regular),
            ),
            Image.asset('images/icon-down-orange.png')
          ],
        ),
      ),
    );
  }
}

//TBD Separate because its used in GrousSettingsPanel
class AddImageWidget extends StatefulWidget {

  @override
  _AddImageWidgetState createState() => _AddImageWidgetState();
}

class _AddImageWidgetState extends State<AddImageWidget> {
  var _imageUrlController = TextEditingController();
  List<ImageType> _imageTypes;
  ImageType _selectedImageType;
  bool _showProgress = false;

  _AddImageWidgetState();

  @override
  void initState() {
    _loadImageTypes();
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  void _setShowProgress(bool value) {
    setState(() {
      _showProgress = value;
    });
  }

  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: Container(
          //color: Styles().colors.blackTransparent06,
          child: Dialog(
            //backgroundColor: Color(0x00ffffff),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Styles().colors.fillColorPrimary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 10),
                            child: Text(
                              Localization().getStringEx("widget.add_image.heading", "Select Image"),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: Styles().fontFamilies.medium,
                                  fontSize: 24),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: _onTapCloseImageSelection,
                            child: Padding(
                              padding: EdgeInsets.only(right: 10, top: 10),
                              child: Text(
                                '\u00D7',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: Styles().fontFamilies.medium,
                                    fontSize: 50),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                          child: SingleChildScrollView(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                              icon: Image.asset(
                                                  'images/icon-down-orange.png'),
                                              isExpanded: true,
                                              hint: Text(
                                                (_selectedImageType != null)
                                                    ? _selectedImageType.identifier
                                                    : Localization().getStringEx("widget.add_image.description",'Select an image type'),
                                              ),
                                              items: _buildImageTypesItems(),
                                              onChanged: _onImageTypesValueChanged)),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: TextFormField(
                                            controller: _imageUrlController,
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText:  Localization().getStringEx("widget.add_image.field.description.label","Image url"),
                                              labelText:  Localization().getStringEx("widget.add_image.field.description.hint","Image url"),
                                            ))),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: RoundedButton(
                                            label: Localization().getStringEx("widget.add_image.button.use_url.label","Use Url"),
                                            borderColor: Styles().colors.fillColorSecondary,
                                            backgroundColor: Styles().colors.background,
                                            textColor: Styles().colors.fillColorPrimary,
                                            onTap: _onTapUseUrl)),
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: RoundedButton(
                                            label:  Localization().getStringEx("widget.add_image.button.chose_device.label","Choose from device"),
                                            borderColor: Styles().colors.fillColorSecondary,
                                            backgroundColor: Styles().colors.background,
                                            textColor: Styles().colors.fillColorPrimary,
                                            onTap: _onTapChooseFromDevice)),
                                    _showProgress ? CircularProgressIndicator() : Container(),
                                  ]))),
                    )
                  ],
                ),
              )),
        ),
      )
    ]);
  }

  List<DropdownMenuItem<ImageType>> _buildImageTypesItems() {
    if (_imageTypes == null) return null;
    List<DropdownMenuItem<ImageType>> result = [];
    for (ImageType imageType in _imageTypes) {
      DropdownMenuItem ddmi = DropdownMenuItem<ImageType>(
        value: imageType,
        child: Text(
          imageType.identifier,
        ),
      );
      result.add(ddmi);
    }
    return result;
  }

  void _onImageTypesValueChanged(ImageType value) {
    setState(() {
      _selectedImageType = value;
    });
  }

  void _loadImageTypes() {
    Future future = ImageService().loadImageTypes();
    future.then((imageTypes) {
      _imageTypes = imageTypes;
      setState(() {});
    });
  }

  void _onTapCloseImageSelection() {
    Analytics.instance.logSelect(target: "Close image selection");
    Navigator.pop(context, "");
  }

  void _onTapUseUrl() {
    Analytics.instance.logSelect(target: "Use Url");
    String url = _imageUrlController.value.text;
    if (url == "") {
      AppToast.show(Localization().getStringEx("widget.add_image.validation.url.label","Please enter an url"));
      return;
    }
    if (_selectedImageType == null) {
      AppToast.show(Localization().getStringEx("widget.add_image.validation.image_type.label","Please select an image type"));
      return;
    }

    bool isReadyUrl = url.endsWith(".webp");
    if (isReadyUrl) {
      //ready
      AppToast.show(Localization().getStringEx("widget.add_image.validation.success.label","Successfully added an image"));
      Navigator.pop(context, url);
    } else {
      //we need to process it
      _setShowProgress(true);
      Future<ImagesResult> result =
      ImageService().useUrl(_selectedImageType, url);
      result.then((logicResult) {
        _setShowProgress(false);

        ImagesResultType resultType = logicResult.resultType;
        switch (resultType) {
          case ImagesResultType.CANCELLED:
          //do nothing
            break;
          case ImagesResultType.ERROR_OCCURRED:
            AppToast.show(logicResult.errorMessage);
            break;
          case ImagesResultType.SUCCEEDED:
          //ready
            AppToast.show(Localization().getStringEx("widget.add_image.validation.success.label","Successfully added an image"));
            Navigator.pop(context, logicResult.data);
            break;
        }
      });
    }
  }

  void _onTapChooseFromDevice() {
    Analytics.instance.logSelect(target: "Choose From Device");
    if (_selectedImageType == null) {
      AppToast.show(Localization().getStringEx("widget.add_image.validation.image_type.label","Please select an image type"));
      return;
    }

    _setShowProgress(true);

    Future<ImagesResult> result =
    ImageService().chooseFromDevice(_selectedImageType);
    result.then((logicResult) {
      _setShowProgress(false);

      ImagesResultType resultType = logicResult.resultType;
      switch (resultType) {
        case ImagesResultType.CANCELLED:
        //do nothing
          break;
        case ImagesResultType.ERROR_OCCURRED:
          AppToast.show(logicResult.errorMessage);
          break;
        case ImagesResultType.SUCCEEDED:
        //ready
          AppToast.show(Localization().getStringEx("widget.add_image.validation.success.label","Successfully added an image"));
          Navigator.pop(context, logicResult.data);
          break;
      }
    });
  }
}