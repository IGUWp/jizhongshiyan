import 'dart:ffi';
import 'dart:io';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:jizhongshiyan/config/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class Mappage extends StatefulWidget {
  const Mappage({super.key});

  @override
  State<Mappage> createState() => _MappageState();
}

class _MappageState extends State<Mappage> {
  int firstAddcnt = 0; //判断是否是删除过第一个没有意义的polygon
  AMapController? mapController;
  AMapFlutterLocation? location;
  PermissionStatus? permissionStatus;
  CameraPosition? currentlocation;
  bool CanAddPolygons = false;

  late MapType _mapType;
  List poisData = [];
  var markerLatitude;
  var markerLongitude;
  //需要先设置一个空的map赋值给AMapWidget的markers，否则后续无法添加marker
  Map<String, Marker> _markers = <String, Marker>{};
  Map<String, Polygon> _polygons = {};

  double? meLatitude;
  double? meLongitude;

  @override
  void initState() {
    super.initState();
    _mapType = MapType.normal;

    /// 设置是否已经取得用户同意，如果未取得用户同意，高德定位SDK将不会工作,这里传true
    AMapFlutterLocation.updatePrivacyAgree(true);

    /// 设置是否已经包含高德隐私政策并弹窗展示显示用户查看，如果未包含或者没有弹窗展示，高德定位SDK将不会工作,这里传true
    AMapFlutterLocation.updatePrivacyShow(true, true);
    requestPermission();

    /// 设置Android和iOS的apikey，
    AMapFlutterLocation.setApiKey(Constconfig.androidkey, Constconfig.ioskey);
    _addpolygons();
  }

  Future<void> requestPermission() async {
    final status = await Permission.location.request();
    permissionStatus = status;
    switch (status) {
      case PermissionStatus.denied:
        print("拒绝");
        break;
      case PermissionStatus.granted:
        requestLocation();
        break;
      case PermissionStatus.limited:
        print("限制");
        break;
      default:
        print("其他状态");
        requestLocation();
        break;
    }
  }

  /// 请求位置
  void requestLocation() {
    location = AMapFlutterLocation()
      ..setLocationOption(AMapLocationOption())
      ..onLocationChanged().listen((event) {
        // print(event);
        double? latitude = double.tryParse(event['latitude'].toString());
        double? longitude = double.tryParse(event['longitude'].toString());
        markerLatitude = latitude.toString();
        markerLongitude = longitude.toString();
        meLatitude = latitude;
        meLongitude = longitude;
        if (latitude != null && longitude != null) {
          setState(() {
            currentlocation = CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 18,
            );
          });
        }
      })
      ..startLocation();
  }

  // void _onMapPoiTouched(AMapPoi poi) async {
  //   if (null == poi) {
  //     return;
  //   }
  //   print('_onMapPoiTouched===> ${poi.toJson()}');
  //   var xx = poi.toJson();
  //   print(xx['latLng']);
  //   markerLatitude = xx['latLng'][1];
  //   markerLongitude = xx['latLng'][0];
  //   print(markerLatitude);
  //   print(markerLatitude);
  //   setState(() {
  //     _addMarker(poi.latLng!);
  //   });
  //   _getPoisData();
  // }

  void _addpolygons() {
    final Polygon polygon = Polygon(
        points: <LatLng>[
          LatLng(38.885, 115.514),
        ],
        strokeColor: Colors.blue.withOpacity(0.8),
        fillColor: Colors.blue.withOpacity(0.2),
        strokeWidth: 2);
    //创建和polygon并列的marker
    final Marker marker = Marker(
        position: polygon.points[0],
        alpha: 0.0); //实际上这个点是看不到的，因为alpha是透明度，0就是看不见

    _polygons["id"] = polygon;
    _markers["id"] = marker;
  }

  void addPoint(LatLng latlnt) {
    final Polygon? polygon = _polygons["id"];
    List<LatLng> currentPoints = polygon!.points;
    List<LatLng> newPoints = <LatLng>[];
    newPoints.addAll(currentPoints);
    if (firstAddcnt == 0) {
      newPoints.remove(newPoints[0]);
      _markers.clear();
      firstAddcnt++;
    }
    newPoints.add(latlnt);
    // print(newPoints);
    setState(() {
      _polygons["id"] = polygon.copyWith(
        pointsParam: newPoints,
      );
    });
  }

  void addMarker(LatLng latlnt) {
    final Marker? marker = Marker(position: latlnt);
    _markers[marker!.id] = marker;
  }

  // //添加一个marker
  // void _addMarker(LatLng markPostion) async {
  //   _removeAll();
  //   final Marker marker = Marker(
  //     position: markPostion,
  //     //使用默认hue的方式设置Marker的图标
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
  //   );
  //   //调用setState触发AMapWidget的更新，从而完成marker的添加
  //   setState(() {
  //     //将新的marker添加到map里
  //     _markers[marker.id] = marker;
  //   });
  //   _changeCameraPosition(markPostion);
  // }

  /// 清除marker
  // void _removeAll() {
  //   if (_markers.isNotEmpty) {
  //     setState(() {
  //       _markers.clear();
  //     });
  //   }
  // }

  /// 改变中心点
  void _changeCameraPosition(LatLng markPostion, {double zoom = 13}) {
    mapController?.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            //中心点
            target: markPostion,
            //缩放级别
            zoom: zoom,
            //俯仰角0°~45°（垂直与地图时为0）
            tilt: 30,
            //偏航角 0~360° (正北方为0)
            bearing: 0),
      ),
      animated: true,
    );
  }

  @override
  void dispose() {
    location?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "高德地图",
          style: TextStyle(),
        ),
      ),
      body: currentlocation == null
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 350,
                  child: SizedBox(
                    child: AMapWidget(
                      buildingsEnabled: true,
                      // 隐私政策包含高德 必须填写
                      privacyStatement: Constconfig.aMapPrivacyStatement,
                      apiKey: Constconfig.aMapApiKeys,
                      // 初始化地图中心店
                      initialCameraPosition: currentlocation!,
                      //定位小蓝点
                      myLocationStyleOptions: MyLocationStyleOptions(
                        false,
                      ),
                      // 普通地图normal,卫星地图satellite,夜间视图night,导航视图 navi,公交视图bus,
                      mapType: _mapType,
                      // 缩放级别范围
                      minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
                      // onPoiTouched: _onMapPoiTouched,
                      onTap: (LatLng latlng) {
                        if (CanAddPolygons) {
                          addPoint(latlng);
                          addMarker(latlng); //多边形的point
                          print('object');
                        }
                      },

                      markers: Set<Marker>.of(_markers.values),
                      polygons: Set<Polygon>.of(_polygons.values),
                      // 地图创建成功时返回AMapController
                      onMapCreated: (AMapController controller) {
                        mapController = controller;
                      },
                    ),
                  ),
                ),
                // Expanded(//显示建筑物信息
                //   child: ListView(
                //     children: [
                //       Container(
                //         padding: EdgeInsets.all(16),
                //         child: const Text(
                //           '周边信息',
                //           style: TextStyle(
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ),
                //       _buildPoisList(),
                //       ElevatedButton(
                //         onPressed: _getPoisData,
                //         child: Text('获取周边数据'),
                //       ),
                //     ],
                //   ),
                // ),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        child: const Text(
                          '对建筑物描点',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            CanAddPolygons = true;
                            print(_polygons["id"]?.points);
                          });
                        },
                        child: Text('开始描点'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: SpeedDial(
        // marginRight: 25, //右边距
        // marginBottom: 50, //下边距
        animatedIcon: AnimatedIcons.menu_close, //带动画的按钮
        animatedIconTheme: const IconThemeData(size: 22.0),
        // visible: isShow, //是否显示按钮
        closeManually: false, //是否在点击子按钮后关闭展开项
        curve: Curves.bounceIn, //展开动画曲线
        overlayColor: Colors.black, //遮罩层颜色
        overlayOpacity: 0.5, //遮罩层透明度
        onOpen: () => print('OPENING DIAL'), //展开回调
        onClose: () => print('DIAL CLOSED'), //关闭回调
        tooltip: 'Speed Dial', //长按提示文字
        heroTag: 'speed-dial-hero-tag', //hero标记
        backgroundColor: Colors.blue, //按钮背景色
        foregroundColor: Colors.white, //按钮前景色/文字色
        elevation: 8.0, //阴影
        // shape: const CircleBorder({}), //shape修饰
        children: [
          //子按钮
          SpeedDialChild(
              label: '普通地图',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                // onButtonClick(1);
                setState(() {
                  _mapType = MapType.normal;
                });
              }),
          SpeedDialChild(
            label: '卫星地图',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.satellite;
              });
            },
          ),
          SpeedDialChild(
            label: '导航地图',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.navi;
              });
            },
          ),
          SpeedDialChild(
            label: '公交地图',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.bus;
              });
            },
          ),
          SpeedDialChild(
            label: '黑夜模式',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                _mapType = MapType.night;
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildPoisList() {
  //   return Column(
  //     children: poisData.map((value) {
  //       return ListTile(
  //         title: Text(value['name']),
  //         subtitle: Text(
  //             '${value['pname']}${value['cityname']}${value['adname']}${value['address']}'),
  //         onTap: () async {
  //           List locationData = value['location'].split(',');
  //           double l1 = double.parse(locationData[1]);
  //           double l2 = double.parse(locationData[0]);
  //           markerLatitude = l2;
  //           markerLongitude = l1;
  //           _getPoisData();
  //           _addMarker(LatLng(l1, l2));
  //           _changeCameraPosition(LatLng(l1, l2));
  //         },
  //         onLongPress: () {
  //           showCupertinoDialog(
  //               context: context,
  //               builder: (context) {
  //                 return CupertinoAlertDialog(
  //                   title: const Text('提示'),
  //                   content: const Text('是否进入高德地图导航'),
  //                   actions: <Widget>[
  //                     CupertinoDialogAction(
  //                       child: const Text('取消'),
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                     ),
  //                     CupertinoDialogAction(
  //                       child: Text('确认'),
  //                       onPressed: () async {
  //                         String title = value['name'];
  //                         var locationData = value['location'].split(',');
  //                         double l1 = double.parse(locationData[1]);
  //                         double l2 = double.parse(locationData[0]);

  //                         Uri uri = Uri.parse(
  //                             '${Platform.isAndroid ? 'android' : 'ios'}amap://path?sourceApplication=applicationName&sid=&slat=$meLatitude&slon=$meLongitude&sname=&did=&dlat=$l1&dlon=$l2&dname=$title&dev=0&t=0');

  //                         try {
  //                           if (await canLaunchUrl(uri)) {
  //                             await launchUrl(uri);
  //                           } else {
  //                             print('无法调起高德地图');
  //                           }
  //                         } catch (e) {
  //                           print('无法调起高德地图');
  //                         }
  //                         Navigator.pop(context);
  //                       },
  //                     ),
  //                   ],
  //                 );
  //               });
  //         },
  //       );
  //     }).toList(),
  //   );
  // }

  /// 获取周边数据
  Future<void> _getPoisData() async {
    var response = await Dio().get(
        'http://restapi.amap.com/v3/place/around?key=${Constconfig.webkey}&location=$markerLatitude,$markerLongitude&keywords=&types=&radius=1000&offset=20&page=1&extensions=base');
    setState(() {
      poisData = response.data['pois'];
    });
  }
}
