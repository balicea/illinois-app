
import 'package:flutter/material.dart';
import 'package:illinois/service/Analytics.dart';
import 'package:rokwire_plugin/service/location_services.dart';
import 'package:illinois/service/Onboarding2.dart';
import 'package:illinois/service/Styles.dart';

class Onboarding2PermissionsPanel extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Onboarding2PermissionsPanelState();

}
class _Onboarding2PermissionsPanelState extends State <Onboarding2PermissionsPanel>{

  @override
  void initState() {
    _requestLocation(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Styles().colors!.background,
    );
  }

  void _requestLocation(BuildContext context) async {
    Analytics.instance.logSelect(target: 'Share My locaiton') ;
    await LocationServices.instance.status.then((LocationServicesStatus? status){
      if (status == LocationServicesStatus.serviceDisabled) {
        LocationServices.instance.requestService();
      }
      else if (status == LocationServicesStatus.permissionNotDetermined) {
        LocationServices.instance.requestPermission().then((LocationServicesStatus? status) {
          //Next
          _goNext();
        });
      }
      else if (status == LocationServicesStatus.permissionDenied) {
        //Denied  - request again
        LocationServices.instance.requestPermission().then((LocationServicesStatus? status) {
          //Next
          _goNext();
        });
      }
      else if (status == LocationServicesStatus.permissionAllowed) {
        //Next()
        _goNext();
      }
    });
  }

  void _goNext(){
    Onboarding2().finalize(context);
  }
}