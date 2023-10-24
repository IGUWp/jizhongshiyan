import 'package:amap_flutter_base/amap_flutter_base.dart';

class Constconfig {
  static const androidkey = "61c4872799c4c762be6fa047272c0b02	";
  static const ioskey = "";
  static const webkey = "0ba57db5af2617ba78a06f946f85c3dd";

  static const AMapApiKey aMapApiKeys =
      AMapApiKey(iosKey: ioskey, androidKey: androidkey);
  static const AMapPrivacyStatement aMapPrivacyStatement =
      AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);
}
