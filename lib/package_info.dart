// TODO Implement this library.
import 'package:package_info/package_info.dart';

PackageInfo packageInfo =  PackageInfo.fromPlatform() as PackageInfo;

String appName = packageInfo.appName;
String packageName = packageInfo.packageName;
String version = packageInfo.version;
String buildNumber = packageInfo.buildNumber;

