import 'dart:async';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:flutter/material.dart';
import 'package:jizhongshiyan/config/config.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _lat = ""; //纬度
  String _lon = ""; //经度
  String country = ""; //国家
  String province = ""; //省份
  String city = ""; //市
  String district = ""; //区
  String street = ""; //街道
  String adCode = ""; //邮编
  String address = ""; //详细地址
  String cityCode = ""; //区号

  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  late StreamSubscription<Map<String, Object>> _locationListener;

  Future<void> reuqestPermission() async {
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission == true) {
      print('定位权限申请通过');
    } else {
      print('定位权限申请不通过');
    }
  }

  ///申请定位权限
  Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      //未授权重新发起请求
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    reuqestPermission();
    AMapFlutterLocation.setApiKey(Constconfig.androidkey, Constconfig.ioskey);
    AMapFlutterLocation.updatePrivacyAgree(true);
    AMapFlutterLocation.updatePrivacyShow(true, true);
    _locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      print(result);
      setState(() {
        _lat = result["latitude"].toString();
        _lon = result["longitude"].toString();
        country = result['country'].toString();
        province = result['province'].toString();
        city = result['city'].toString();
        district = result['district'].toString();
        street = result['street'].toString();
        adCode = result['adCode'].toString();
        address = result['address'].toString();
        cityCode = result['cityCode'].toString();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_locationListener != null) {
      _locationListener.cancel();
    }
    if (_locationPlugin != null) {
      _locationPlugin.destroy();
    }
  }

  void _setLocationOption() {
    if (_locationPlugin != null) {
      AMapLocationOption locationOption = AMapLocationOption();
      locationOption.onceLocation = false;
      locationOption.needAddress = true;
      locationOption.geoLanguage = GeoLanguage.DEFAULT;
      locationOption.desiredLocationAccuracyAuthorizationMode =
          AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;
      locationOption.fullAccuracyPurposeKey = "AMapLocationScene";
      locationOption.locationInterval = 2000;
      locationOption.locationMode = AMapLocationMode.Hight_Accuracy;
      _locationPlugin.setLocationOption(locationOption);
    }
  }

  void _startLocation() {
    if (null != _locationPlugin) {
      ///开始定位之前设置定位参数
      _setLocationOption();
      _locationPlugin.startLocation();
    }
  }

  ///停止定位
  void _stopLocation() {
    if (null != _locationPlugin) {
      _locationPlugin.stopLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定位'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("经度:$_lon"),
            Text("纬度:$_lat"),
            Text('国家：$country'),
            Text('省份：$province'),
            Text('城市：$city'),
            Text('区：$district'),
            Text('城市编码：$cityCode'),
            Text('街道：$street'),
            Text('邮编：$adCode'),
            Text('详细地址：$address'),
            SizedBox(height: 20),
            ElevatedButton(
              child: const Text('开始定位'),
              onPressed: () {
                _startLocation();
              },
            ),
            ElevatedButton(
              child: const Text('停止定位'),
              onPressed: () {
                _stopLocation();
              },
            ),
          ],
        ),
      ),
    );
  }
}
