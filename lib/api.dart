import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';

import 'responses.dart';

class Api {
  static Function(String, String) onError;
  static Uri baseUri = Uri();

  static Map<String, String> headers = Map<String, String>();

  static String globalErrorPath;
  static String globalDataPath;

  static bool get _isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static set(String endpoint,
      {Map<String, String> args, List<MultipartFile> files}) async {
    try {
      await _post(endpoint, body: args, files: files);
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  static Future<ApiResponse<T>> get<T>(String endpoint,
      {Map<String, String> args,
      List<MultipartFile> files,
      String method,
      String dataPath,
      String errorPath}) async {
    ApiResponse<T> data;

    try {
      data = ApiResponse<T>(
          await _post(endpoint, body: args, files: files, method: method),
          dataPath: dataPath,
          errorPath: errorPath);
    } catch (e) {
      log(e.toString(), error: e);
      var obj = {"error": e.toString()};
      data = ApiResponse<T>(obj, errorPath: "error");
    }

    if (data.isSuccess) {
      return data;
    } else {
      log(data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error);
    }
  }

  static Future<ApiResponseList<T>> getList<T>(String endpoint,
      {Map<String, String> args,
      String method,
      String dataPath,
      String errorPath}) async {
    ApiResponseList<T> data;

    try {
      data = ApiResponseList<T>(
          await _post(endpoint, body: args, method: method),
          dataPath: dataPath,
          errorPath: errorPath);
    } catch (e) {
      log(e.toString(), error: e);
      var obj = {"error": e.toString()};
      data = ApiResponseList<T>(obj, errorPath: "error");
    }

    if (data.isSuccess) {
      return data;
    } else {
      log(data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error);
    }
  }

  static Future<ApiResponseMap<K, V>> getMap<K, V>(String endpoint,
      {Map<String, String> args,
      String method,
      String dataPath,
      String errorPath}) async {
    ApiResponseMap<K, V> data;

    try {
      data = ApiResponseMap<K, V>(
          await _post(endpoint, body: args, method: method),
          dataPath: dataPath,
          errorPath: errorPath);
    } catch (e) {
      log(e.toString(), error: e);
      var obj = {"error": e.toString()};
      data = ApiResponseMap<K, V>(obj, errorPath: "error");
    }

    if (data.isSuccess) {
      return data;
    } else {
      log(data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error);
    }
  }

  static Future<dynamic> _post(String endpoint,
      {Map headers, Map body, List<MultipartFile> files, String method}) async {
    endpoint = baseUri.toString() + endpoint;
    var r = MultipartRequest(
        (files?.isNotEmpty ?? false) ? "post" : method ?? "get",
        Uri.parse(endpoint));

    try {
      if (_isInDebugMode) {
        String t = '';
        if (body != null && body.length > 0)
          body.forEach((key, value) {
            t += (t.isEmpty ? '?' : '&') + '$key=$value';
          });
        print('Post: ' + endpoint + t);
      }

      if (headers != null && headers.length > 0) r.headers.addAll(headers);
      if (Api.headers?.isNotEmpty ?? false)
        r.headers.addEntries(Api.headers.entries);

      if (body != null && body.length > 0) r.fields.addAll(body);
      if (files != null && files.length > 0) r.files.addAll(files);

      StreamedResponse response;
      try {
        response = await r.send();
      } catch (e) {
        log('Error al intentar acceder a ' + endpoint + ': ' + e.toString(),
            name: method);
        return {
          "isSuccess": false,
          "message":
              'No se puede conectar al servidor, corroborá tu conexión a Internet.'
        };
      }
      String res = await response.stream.bytesToString();

      int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 400 || res == null) {
        String e;
        switch (statusCode) {
          case 500:
            e = 'Oops! Estamos teniendo problemas técnicos.';
            break;
          case 503:
            e = 'Oops! El servidor parece que no esta disponible. Probá en unos minutos.';
            break;
          case 504:
            e = 'Oops! El servidor parece estar congestionado.';
            break;
          default:
            e = 'Oops! Parece que hay un error (${statusCode.toString()})';
        }

        if (_isInDebugMode)
          print('Response ' + statusCode.toString() + ': ' + endpoint);
        log('Error ' + statusCode.toString() + ' al acceder a ' + endpoint,
            name: "post");

        return {"isSuccess": false, "message": e};
      } else {
        var rta = json.decode(res);
        return rta;
      }
    } catch (e) {
      if (_isInDebugMode)
        print('Response Error: ' + endpoint + ' => ' + e.toString());
      log(e.toString(), error: e);
      return Future.error(e);
    }
  }
}
