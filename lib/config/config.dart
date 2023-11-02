import 'package:amap_flutter_base/amap_flutter_base.dart';

class Constconfig {
  static const androidkey = "61c4872799c4c762be6fa047272c0b02";
  static const ioskey = "";
  static const webkey = "d6c7705d2969fbad16b956bb4426311d";

  static const AMapApiKey aMapApiKeys =
      AMapApiKey(iosKey: ioskey, androidKey: androidkey);
  static const AMapPrivacyStatement aMapPrivacyStatement =
      AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);
}
