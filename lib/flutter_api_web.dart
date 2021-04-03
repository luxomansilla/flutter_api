import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FlutterApiPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
        'ar.com.luxomansilla.flutter_api',
        const StandardMethodCodec(),
        ServicesBinding.instance!.defaultBinaryMessenger);
    final FlutterApiPlugin instance = FlutterApiPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {}
}
