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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:illinois/model/Event.dart';
import 'package:illinois/model/Explore.dart';
import 'package:illinois/model/News.dart';
import 'package:illinois/model/RecentItem.dart';
import 'package:illinois/model/sport/Game.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/service/Localization.dart';
import 'package:illinois/service/NotificationService.dart';
import 'package:illinois/service/RecentItems.dart';
import 'package:illinois/service/User.dart';
import 'package:illinois/ui/athletics/AthleticsGameDetailPanel.dart';
import 'package:illinois/ui/athletics/AthleticsNewsArticlePanel.dart';
import 'package:illinois/ui/events/CompositeEventsDetailPanel.dart';
import 'package:illinois/ui/explore/ExploreDetailPanel.dart';
import 'package:illinois/ui/widgets/RoundedButton.dart';
import 'package:illinois/ui/widgets/SectionTitlePrimary.dart';
import 'package:illinois/utils/Utils.dart';
import 'package:illinois/service/Styles.dart';

class HomeRecentItemsWidget extends StatefulWidget {

  final StreamController<void> refreshController;

  HomeRecentItemsWidget({this.refreshController});

  @override
  _HomeRecentItemsWidgetState createState() => _HomeRecentItemsWidgetState();
}

class _HomeRecentItemsWidgetState extends State<HomeRecentItemsWidget> implements NotificationsListener {

  List<RecentItem> _recentItems;

  @override
  void initState() {
    super.initState();

    NotificationService().subscribe(this, RecentItems.notifyChanged);

    if (widget.refreshController != null) {
      widget.refreshController.stream.listen((_) {
        _loadRecentItems();
      });
    }

    _loadRecentItems();
  }

  @override
  void dispose() {
    super.dispose();
    NotificationService().unsubscribe(this);
  }

  @override
  Widget build(BuildContext context) {
    return _RecentItemsList(
      heading: Localization().getStringEx('panel.home.label.recently_viewed', 'Recently Viewed'),
      headingIconRes: 'images/campus-tools.png',
      items: _recentItems,
    );
  }

  void _loadRecentItems() {
    setState(() {
      _recentItems = RecentItems().recentItems?.toSet()?.toList();
    });
  }

  // NotificationsListener

  @override
  void onNotification(String name, dynamic param) {
    if (name == RecentItems.notifyChanged) {
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
          _recentItems = RecentItems().recentItems?.toSet()?.toList();
        }));
      }
    }
  }
}

class _RecentItemsList extends StatelessWidget{
  final int limit;
  final List<RecentItem> items;
  final String heading;
  final String subTitle;
  final String headingIconRes;
  final String slantImageRes;
  final Color slantColor;
  final Function tapMore;
  final bool showMoreChevron;
  final bool showMoreButtonExplicitly;
  final String moreButtonLabel;

  //Card Options
  final bool cardShowDate;
  final bool nearMeStyle;

  const _RecentItemsList(
      {Key key, this.items, this.heading, this.subTitle, this.headingIconRes,
        this.slantImageRes = 'images/slant-down-right-blue.png', this.slantColor, this.tapMore, this.cardShowDate = false, this.nearMeStyle = false,this.limit = 3, this.showMoreChevron = true,
        this.moreButtonLabel, this.showMoreButtonExplicitly = false,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool showMoreButton =showMoreButtonExplicitly ||( tapMore!=null && limit<(items?.length??0));
    String moreLabel = AppString.isStringEmpty(moreButtonLabel)? Localization().getStringEx('widget.home_recent_items.button.more.title', 'View All'): moreButtonLabel;
    return items!=null && items.isNotEmpty? Column(
      children: <Widget>[
        SectionTitlePrimary(
            title:heading,
            subTitle: subTitle,
            iconPath: headingIconRes,
            children: _buildListItems(context)
        ),
        !showMoreButton?Container():
        Container(height: 20,),
        !showMoreButton?Container():
        SmallRoundedButton(
          label: moreLabel,
          hint: Localization().getStringEx('widget.home_recent_items.button.more.hint', ''),
          onTap: tapMore,
          showChevron: showMoreChevron,),
        Container(height: 48,),
      ],
    ) : Container();

  }

  List<Widget> _buildListItems(BuildContext context){
    List<Widget> widgets =  [];
    if(items?.isNotEmpty??false){
      int visibleCount = items.length<limit?items.length:limit;
      for(int i = 0 ; i<visibleCount; i++) {
        RecentItem item = items[i];
        widgets.add(_buildItemCart(
            recentItem: item, context: context, nearMeStyle: nearMeStyle));
      }
    }
    return widgets;
  }

  Widget _buildItemCart({RecentItem recentItem, BuildContext context, bool nearMeStyle}) {
    return _HomeRecentItemCard(
      item: recentItem,
      showDate: cardShowDate,
      nearMeStyle: nearMeStyle,
      onTap: () {
        Analytics.instance.logSelect(target: "HomeRecentItemCard clicked: " + recentItem.recentTitle);
        Navigator.push(context, CupertinoPageRoute(builder: (context) => _getDetailPanel(recentItem)));
      },);
  }

  static Widget _getDetailPanel(RecentItem item) {
    Object originalObject = item.fromOriginalJson();
    if (originalObject is News) { // News
      return AthleticsNewsArticlePanel(article: originalObject,);
    } else if (originalObject is Game) { // Game
      return AthleticsGameDetailPanel(game: originalObject,);
    } else if (originalObject is Explore) { // Event or Dining
      if (originalObject is Event && originalObject.isComposite) {
        return CompositeEventsDetailPanel(parentEvent: originalObject);
      }
      return ExploreDetailPanel(explore: originalObject,);
    }

    return Container();
  }
}

class _HomeRecentItemCard extends StatefulWidget {
  final bool showDate;
  final RecentItem item;
  final GestureTapCallback onTap;
  final bool nearMeStyle;

  _HomeRecentItemCard(
      {@required this.item, this.onTap, this.showDate = false, this.nearMeStyle = false}) {
    assert(item != null);
  }

  @override
  _HomeRecentItemCardState createState() => _HomeRecentItemCardState();
}

class _HomeRecentItemCardState extends State<_HomeRecentItemCard> implements NotificationsListener {
  static const EdgeInsets _detailPadding = EdgeInsets.only(bottom: 16);
  static const EdgeInsets _iconPadding = EdgeInsets.only(right: 5);

//  Object _originalItem;

  @override
  void initState() {
    NotificationService().subscribe(this, User.notifyFavoritesUpdated);
//    _originalItem = widget.item.fromOriginalJson();
    super.initState();
  }

  @override
  void dispose() {
    NotificationService().unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Object _originalItem = widget.item.fromOriginalJson();
    bool isFavorite = User().isFavorite(_originalItem);
    String itemIconPath = widget.item.getIconPath();
    bool hasIcon = AppString.isStringNotEmpty(itemIconPath);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: Padding(
          padding: EdgeInsets.only(
              left: 0, right: 0, bottom:8),
          child:Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.all(Radius.circular(4))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 0,top: 0),
                      child:  Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(flex:10, child:
                          Padding(padding:  EdgeInsets.only(top: 16),
                              child:
                              Row(children: <Widget>[
                                Visibility(
                                    visible: (widget.nearMeStyle && hasIcon),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: 11),
                                      child: Image.asset(AppString
                                          .getDefaultEmptyString(
                                          value: itemIconPath)),)),
                                Container(width: 230, child:
                                Text(
                                  widget.item.recentTitle ?? "",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: Styles().fontFamilies.extraBold,
                                    color: Styles().colors.fillColorPrimary,),
                                ))
                              ],))),
                          Visibility(visible: User().favoritesStarVisible,
                            child: Expanded(flex: 2, child:
                            GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Analytics.instance.logSelect(target: "HomeRecentItemCard  Favorite: "+widget?.item?.recentTitle);
                                  User().switchFavorite(_originalItem);
                                },
                                child: Semantics(
                                    label: isFavorite
                                        ? Localization().getStringEx(
                                        'widget.card.button.favorite.off.title',
                                        'Remove From Favorites')
                                        : Localization().getStringEx(
                                        'widget.card.button.favorite.on.title',
                                        'Add To Favorites'),
                                    hint: isFavorite ? Localization()
                                        .getStringEx(
                                        'widget.card.button.favorite.off.hint',
                                        '') : Localization()
                                        .getStringEx(
                                        'widget.card.button.favorite.on.hint',
                                        ''),
                                    excludeSemantics: true,
                                    child: Container(
                                        child: Padding(
                                            padding: EdgeInsets
                                                .only(right: 16,
                                                top: 16,
                                                left: 16),
                                            child: Image.asset(
                                                isFavorite
                                                    ? 'images/icon-star-selected.png'
                                                    : 'images/icon-star.png')
                                        ))
                                )
                            )),)],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 17, right: 17, top:10),
                      child:
                      Column(children: _buildDetails()),
                    )
                  ],
                ),
              ),
              _topBorder()
            ],
          )),
    );
  }

  List<Widget> _buildDetails() {
    List<Widget> details =  [];
    if(AppString.isStringNotEmpty(widget.item.recentTime)) {
      if (widget.showDate) {
        details.add(_dateDetail());
      }
      details.add(_timeDetail());
    }
    return details;
  }

  //Not used any more
  Widget _dateDetail(){
    String displayTime = widget.item.recentTime;
    if ((displayTime != null) && displayTime.isNotEmpty) {
      String displayDate = Localization().getStringEx('widget.home_recent_item_card.label.date', 'Date');
      return Semantics(label: displayDate, excludeSemantics: true, child:Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          children: <Widget>[
            widget.nearMeStyle ? Container(width: 24) : Image.asset(
                'images/icon-calendar.png'),
            Padding(
              padding: _iconPadding,
            ),
            Text(displayDate,
                style: TextStyle(
                    fontFamily: Styles().fontFamilies.medium,
                    fontSize: widget.nearMeStyle ? 14 : 12,
                    color: Styles().colors.textBackground)),
          ],
        ),
      ));
    } else {
      return null;
    }
  }

  Widget _timeDetail() {
    String displayTime = widget.item.recentTime;
    if ((displayTime != null) && displayTime.isNotEmpty) {
      return Semantics(label: displayTime, excludeSemantics: true, child:Padding(
        padding: _detailPadding,
        child: Row(
          children: <Widget>[
            widget.nearMeStyle ? Container(width: 24) : Image.asset('images/icon-calendar.png'),
            Padding(padding: _iconPadding,),
            Text(displayTime,
                style: TextStyle(
                    fontFamily: Styles().fontFamilies.medium,
                    fontSize: widget.nearMeStyle ? 14 : 12,
                    color: Styles().colors.textBackground)),
          ],
        ),
      ));
    } else {
      return null;
    }
  }

  Widget _topBorder() {
    Object _originalItem = widget.item.fromOriginalJson();
    Color borderColor = (_originalItem is Explore) ? _originalItem.uiColor : Styles().colors.fillColorPrimary;
    return Container(height: 7, color: borderColor);
  }

  // NotificationsListener

  @override
  void onNotification(String name, dynamic param) {
    if (name == User.notifyFavoritesUpdated) {
      if (mounted){
        setState(() {});
      }
    }
  }
}

