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
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:illinois/service/Config.dart';
import 'package:rokwire_plugin/service/deep_link.dart';
import 'package:rokwire_plugin/service/notification_service.dart';
import 'package:rokwire_plugin/service/service.dart';
import 'package:illinois/service/Storage.dart';
import 'package:rokwire_plugin/utils/utils.dart';

class NativeCommunicator with Service implements NotificationsListener {
  
  static const String notifyMapSelectExplore  = "edu.illinois.rokwire.nativecommunicator.map.explore.select";
  static const String notifyMapClearExplore   = "edu.illinois.rokwire.nativecommunicator.map.explore.clear";
  
  static const String notifyMapRouteStart  = "edu.illinois.rokwire.nativecommunicator.map.route.start";
  static const String notifyMapRouteFinish = "edu.illinois.rokwire.nativecommunicator.map.route.finish";
  
  static const String notifyGeoFenceRegionsEnter     = "edu.illinois.rokwire.nativecommunicator.geofence.regions.enter";
  static const String notifyGeoFenceRegionsExit      = "edu.illinois.rokwire.nativecommunicator.geofence.regions.exit";
  static const String notifyGeoFenceRegionsChanged   = "edu.illinois.rokwire.nativecommunicator.geofence.regions.changed";
  static const String notifyGeoFenceBeaconsChanged   = "edu.illinois.rokwire.nativecommunicator.geofence.beacons.changed";
  
  final MethodChannel _platformChannel = const MethodChannel('edu.illinois.rokwire/native_call');

  // Singletone
  static final NativeCommunicator _communicator = new NativeCommunicator._internal();

  factory NativeCommunicator() {
    return _communicator;
  }

  NativeCommunicator._internal();

  // Initialization

  @override
  void createService() {
    NotificationService().subscribe(this,[
      DeepLink.notifyUri,
    ]);
    _platformChannel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  Future<void> initService() async {
    await _nativeInit();
    await super.initService();
  }

  @override
  void destroyService() {
    NotificationService().unsubscribe(this);
  }

  @override
  Set<Service> get serviceDependsOn {
    return Set.from([Config(), DeepLink()]);
  }

  // NotificationsListener

  @override
  void onNotification(String name, dynamic param) {
    if (name == DeepLink.notifyUri) {
      _onDeepLinkUri(param);
    }
  }

  Future<void> _nativeInit() async {
    try {
      await _platformChannel.invokeMethod('init', { "keys": Config().secretKeys });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  String get appSettingsUrl => '${DeepLink().appUrl}/app_settings';

  void _onDeepLinkUri(Uri? uri) {
    if (uri != null) {
      Uri? settingsUri = Uri.tryParse(appSettingsUrl);
      if ((settingsUri != null) &&
          (settingsUri.scheme == uri.scheme) &&
          (settingsUri.authority == uri.authority) &&
          (settingsUri.path == uri.path))
      {
        launchAppSettings();
      }
    }
  }

  Future<void> launchExploreMapDirections({dynamic target}) async {
    dynamic jsonData;
    try {
      if (target != null) {
        if (target is List) {
          jsonData = [];
          for (dynamic entry in target) {
            jsonData.add(entry.toJson());
          }
        }
        else {
          jsonData = target.toJson();
        }
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
    
    if (jsonData != null) {
      await launchMapDirections(jsonData: jsonData);
    }
  }

  Future<void> launchMapDirections({dynamic jsonData}) async {
    try {
      String? lastPageName = Analytics().currentPageName;
      Map<String, dynamic>? lastPageAttributes = Analytics().currentPageAttributes;
      Analytics().logPage(name: 'MapDirections');
      Analytics().logMapShow();
      
      await _platformChannel.invokeMethod('directions', {
        'explore': jsonData,
        'options': {
          'showDebugLocation': Storage().debugMapLocationProvider,
          'hideLevels': Storage().debugMapHideLevels,
        }});

      Analytics().logMapHide();
      Analytics().logPage(name: lastPageName, attributes: lastPageAttributes);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<String?> launchSelectLocation({dynamic explore}) async {
    try {

      String? lastPageName = Analytics().currentPageName;
      Map<String, dynamic>? lastPageAttributes = Analytics().currentPageAttributes;
      Analytics().logPage(name: 'MapSelectLocation');
      Analytics().logMapShow();

      dynamic jsonData = (explore != null) ? explore.toJson() : null;
      String? result = await _platformChannel.invokeMethod('pickLocation', {"explore": jsonData});

      Analytics().logMapHide();
      Analytics().logPage(name: lastPageName, attributes: lastPageAttributes);
      return result;

    } on PlatformException catch (e) {
      print(e.message);
    }

    return null;
  }

  Future<void> launchMap({dynamic target, dynamic markers}) async {
    try {
      String? lastPageName = Analytics().currentPageName;
      Map<String, dynamic>? lastPageAttributes = Analytics().currentPageAttributes;
      Analytics().logPage(name: 'Map');
      Analytics().logMapShow();

      await _platformChannel.invokeMethod('map', {
        'target': target,
        'options': {
          'showDebugLocation': Storage().debugMapLocationProvider,
          'hideLevels': Storage().debugMapHideLevels,
        },
        'markers': markers,
      });

      Analytics().logMapHide();
      Analytics().logPage(name: lastPageName, attributes: lastPageAttributes);

    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void>launchNotification({String? title, String? subtitle, String? body, bool sound = true}) async {
    await _platformChannel.invokeMethod('showNotification', {
      'title': title,
      'subtitle': subtitle,
      'body': body,
      'sound': sound,
    });
  }

  Future<void> dismissLaunchScreen() async {
    try {
      await _platformChannel.invokeMethod('dismissLaunchScreen');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> setLaunchScreenStatus(String? status) async {
    try {
      await _platformChannel.invokeMethod('setLaunchScreenStatus', {
        'status': status
      });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> addCardToWallet(List<int> cardData) async {
    try {
      String cardBase64Data = base64Encode(cardData);
      await _platformChannel.invokeMethod('addToWallet', { "cardBase64Data" : cardBase64Data });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<dynamic> geoFence({List<dynamic>? regions, Map<String, dynamic>? beacons}) async {
    try {
      Map<String, dynamic> params = {};
      if (regions != null) {
        params['regions'] = regions;
      }
      else if (beacons != null) {
        params['beacons'] = beacons;
      }
      return await _platformChannel.invokeMethod('geoFence', params);
    } on PlatformException catch (e) {
      print(e.message);
    }
    return null;
  }

  Future<List<DeviceOrientation>?> enabledOrientations(List<DeviceOrientation> orientationsList) async {
    List<DeviceOrientation>? result;
    try {
      dynamic inputStringsList = _deviceOrientationListToStringList(orientationsList);
      dynamic outputStringsList = await _platformChannel.invokeMethod('enabledOrientations', { "orientations" : inputStringsList });
      result = _deviceOrientationListFromStringList(outputStringsList);
    } on PlatformException catch (e) {
      print(e.message);
    }
    return result;
  }

  Future<String?> queryFirebaseInfo() async {
    String? result;
    try {
      result = await _platformChannel.invokeMethod('firebaseInfo');
    } on PlatformException catch (e) {
      print(e.message);
    }
    return result;
  }

  Future<AuthorizationStatus?> queryNotificationsAuthorization(String method) async {
    AuthorizationStatus? result;
    try {
      result = _authorizationStatusFromString(await _platformChannel.invokeMethod('notifications_authorization', {"method": method }));
    } on PlatformException catch (e) {
      print(e.message);
    }
    return result;
  }

  Future<AuthorizationStatus?> queryTrackingAuthorization(String method) async {
    AuthorizationStatus? result;
    try {
      result = _authorizationStatusFromString(await _platformChannel.invokeMethod('tracking_authorization', {"method": method }));
    } on PlatformException catch (e) {
      print(e.message);
    }
    return result;
  }

  Future<Uint8List?> getBarcodeImageData(Map<String, dynamic> params) async {
    Uint8List? result;
    try {
      String? base64String = await _platformChannel.invokeMethod('barcode', params);
      result = (base64String != null) ? base64Decode(base64String) : null;
    }
    catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<bool?> launchApp(Map<String, dynamic> params) async {
    bool? result;
    try {
      result = await _platformChannel.invokeMethod('launchApp', params);
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<bool?> launchAppSettings() async {
    bool? result;
    try {
      result = await _platformChannel.invokeMethod('launchAppSettings');
    } catch (e) {
      print(e.toString);
    }
    return result;
  }

  Future<void> launchTest() async {
    try {
      await _platformChannel.invokeMethod('test');
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "map.explore.select":
        _notifyMapSelectExplore(call.arguments);
        break;
      case "map.explore.clear":
        _notifyMapClearExplore(call.arguments);
        break;
      
      case "map.route.start":
        _notifyMapRouteStart(call.arguments);
        break;
      case "map.route.finish":
        _notifyMapRouteFinish(call.arguments);
        break;
      
      case "geo_fence.regions.enter":
        _notifyGeoFenceRegionsEnter(call.arguments);
        break;
      case "geo_fence.regions.exit":
        _notifyGeoFenceRegionsExit(call.arguments);
        break;
      case "geo_fence.regions.changed":
        _notifyGeoFenceRegionsChanged(call.arguments);
        break;
      case "geo_fence.beacons.changed":
        _notifyGeoFenceBeaconsChanged(call.arguments);
        break;

      case "firebase_message":
        //PS use firebase messaging plugin!
        //FirebaseMessaging().onMessage(call.arguments);
        break;

      default:
        break;
    }
    return null;
  }

  void _notifyMapSelectExplore(dynamic arguments) {
    dynamic jsonData = (arguments is String) ? JsonUtils.decode(arguments) : null;
    Map<String, dynamic>? params = (jsonData is Map) ? jsonData.cast<String, dynamic>() : null;
    int? mapId = (params is Map) ? params!['mapId'] : null;
    dynamic exploreJson = (params is Map) ? params!['explore'] : null;

    NotificationService().notify(notifyMapSelectExplore, {
      'mapId': mapId,
      'exploreJson': exploreJson
    });
  }
  
  void _notifyMapClearExplore(dynamic arguments) {
    dynamic jsonData = (arguments is String) ? JsonUtils.decode(arguments) : null;
    Map<String, dynamic>? params = (jsonData is Map) ? jsonData.cast<String, dynamic>() : null;
    int? mapId = (params is Map) ? params!['mapId'] : null;

    NotificationService().notify(notifyMapClearExplore, {
      'mapId': mapId,
    });
  }

  void _notifyMapRouteStart(dynamic arguments) {
    dynamic jsonData = (arguments is String) ? JsonUtils.decode(arguments) : null;
    Map<String, dynamic>? params = (jsonData is Map) ? jsonData.cast<String, dynamic>() : null;
    NotificationService().notify(notifyMapRouteStart, params);
  }

  void _notifyMapRouteFinish(dynamic arguments) {
    dynamic jsonData = (arguments is String) ? JsonUtils.decode(arguments) : null;
    Map<String, dynamic>? params = (jsonData is Map) ? jsonData.cast<String, dynamic>() : null;
    NotificationService().notify(notifyMapRouteFinish, params);
  }

  void _notifyGeoFenceRegionsEnter(dynamic arguments) {
    NotificationService().notify(notifyGeoFenceRegionsEnter, arguments);
  }

  void _notifyGeoFenceRegionsExit(dynamic arguments) {
    NotificationService().notify(notifyGeoFenceRegionsExit, arguments);
  }

  void _notifyGeoFenceRegionsChanged(dynamic arguments) {
    NotificationService().notify(notifyGeoFenceRegionsChanged, arguments);
  }

  void _notifyGeoFenceBeaconsChanged(dynamic arguments) {
    NotificationService().notify(notifyGeoFenceBeaconsChanged, arguments);
  }
}

enum AuthorizationStatus {
  NotDetermined,
  Restricted,
  Denied,
  Allowed
}

AuthorizationStatus? _authorizationStatusFromString(String? value){
  if("not_determined" == value) {
    return AuthorizationStatus.NotDetermined;
  }
  else if("restricted" == value) {
    return AuthorizationStatus.Denied;
  }
  else if("denied" == value) {
    return AuthorizationStatus.Denied;
  }
  else if("allowed" == value) {
    return AuthorizationStatus.Allowed;
  }
  else {
    return null;
  }
}

DeviceOrientation? _deviceOrientationFromString(String value) {
  switch (value) {
    case 'portraitUp': return DeviceOrientation.portraitUp;
    case 'portraitDown': return DeviceOrientation.portraitDown;
    case 'landscapeLeft': return DeviceOrientation.landscapeLeft;
    case 'landscapeRight': return DeviceOrientation.landscapeRight;
  }
  return null;
}

String? _deviceOrientationToString(DeviceOrientation value) {
    switch(value) {
      case DeviceOrientation.portraitUp: return "portraitUp";
      case DeviceOrientation.portraitDown: return "portraitDown";
      case DeviceOrientation.landscapeLeft: return "landscapeLeft";
      case DeviceOrientation.landscapeRight: return "landscapeRight";
    }
}

List<DeviceOrientation>? _deviceOrientationListFromStringList(List<dynamic>? stringsList) {
  
  List<DeviceOrientation>? orientationsList;
  if (stringsList != null) {
    orientationsList = [];
    for (dynamic string in stringsList) {
      if (string is String) {
        DeviceOrientation? orientation = _deviceOrientationFromString(string);
        if (orientation != null) {
          orientationsList.add(orientation);
        }
      }
    }
  }
  return orientationsList;
}

List<String>? _deviceOrientationListToStringList(List<DeviceOrientation>? orientationsList) {
  
  List<String>? stringsList;
  if (orientationsList != null) {
    stringsList = [];
    for (DeviceOrientation orientation in orientationsList) {
      String? orientationString = _deviceOrientationToString(orientation);
      if (orientationString != null) {
        stringsList.add(orientationString);
      }
    }
  }
  return stringsList;
}
