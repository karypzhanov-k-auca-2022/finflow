import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/entities/about_info.dart';

Future<AboutInfo> loadAboutInfo() async {
  final packageInfo = await PackageInfo.fromPlatform();
  final deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    final info = await deviceInfo.webBrowserInfo;
    return AboutInfo(
      appVersion: packageInfo.version,
      deviceModel: info.browserName.name,
      osVersion: info.platform ?? 'Web',
    );
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final info = await deviceInfo.androidInfo;
      return AboutInfo(
        appVersion: packageInfo.version,
        deviceModel: _androidModel(info.manufacturer, info.model),
        osVersion: 'Android ${info.version.release}',
      );
    case TargetPlatform.iOS:
      final info = await deviceInfo.iosInfo;
      return AboutInfo(
        appVersion: packageInfo.version,
        deviceModel: info.modelName,
        osVersion: '${info.systemName} ${info.systemVersion}',
      );
    case TargetPlatform.macOS:
      final info = await deviceInfo.macOsInfo;
      return AboutInfo(
        appVersion: packageInfo.version,
        deviceModel: info.model,
        osVersion: 'macOS ${info.osRelease}',
      );
    case TargetPlatform.windows:
      final info = await deviceInfo.windowsInfo;
      return AboutInfo(
        appVersion: packageInfo.version,
        deviceModel: info.productName,
        osVersion: 'Windows ${info.displayVersion}',
      );
    case TargetPlatform.linux:
      final info = await deviceInfo.linuxInfo;
      return AboutInfo(
        appVersion: packageInfo.version,
        deviceModel: info.prettyName,
        osVersion: info.version ?? info.name,
      );
    case TargetPlatform.fuchsia:
      final info = await deviceInfo.deviceInfo;
      return AboutInfo(
        appVersion: packageInfo.version,
        deviceModel: info.data['model']?.toString() ?? 'Fuchsia device',
        osVersion: 'Fuchsia',
      );
  }
}

String _androidModel(String manufacturer, String model) {
  final normalizedManufacturer = manufacturer.trim();
  final normalizedModel = model.trim();
  if (normalizedManufacturer.isEmpty) return normalizedModel;
  if (normalizedModel.toLowerCase().startsWith(
    normalizedManufacturer.toLowerCase(),
  )) {
    return normalizedModel;
  }

  final displayManufacturer =
      '${normalizedManufacturer[0].toUpperCase()}'
      '${normalizedManufacturer.substring(1)}';
  return '$displayManufacturer $normalizedModel';
}
