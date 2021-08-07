import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'responses.dart';

class Api {
  static Function(String, String?)? onError;
  static Uri baseUri = Uri();

  static Map<String, String> headers = Map<String, String>();

  static String? globalErrorPath;
  static String? globalDataPath;
  static Map<String, String> globalParams = Map<String, String>();

  static bool printRequests = false;
  static bool printResponses = false;

  static Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? args,
    List<http.MultipartFile>? files,
    String method: 'put',
  }) async {
    ApiResponse<T> data;

    try {
      data = await _post(endpoint, body: args, files: files, method: method);
    } catch (e) {
      log(e.toString(), error: e);
      var obj = {"error": e.toString()};
      data = ApiResponse<T>(obj, errorPath: "error");
    }

    if (data.isSuccess) {
      return data;
    } else {
      log(data.error!);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error!);
    }
  }

  static Future<ApiResponse<T>> set<T>(
    String endpoint, {
    Map<String, String>? args,
    List<http.MultipartFile>? files,
    String method: 'post',
  }) async {
    ApiResponse<T> data;

    try {
      data = await _post(endpoint, body: args, files: files, method: method);
    } catch (e) {
      log(e.toString(), error: e);
      var obj = {"error": e.toString()};
      data = ApiResponse<T>(obj, errorPath: "error");
    }

    if (data.isSuccess) {
      return data;
    } else {
      log(data.error!);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error!);
    }
  }

  static Future<ApiResponse<T>> get<T>(String endpoint,
      {Map<String, String>? args,
      List<http.MultipartFile>? files,
      String method: 'get',
      String? dataPath,
      String? errorPath}) async {
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
      log(data.error!);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error!);
    }
  }

  static Future<ApiResponseList<T>> getList<T>(String endpoint,
      {Map<String, String>? args,
      String method: 'get',
      String? dataPath,
      String? errorPath}) async {
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
      log(data.error!);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error!);
    }
  }

  static Future<ApiResponseMap<K, V>> getMap<K, V>(String endpoint,
      {Map<String, String>? args,
      String method: 'get',
      String? dataPath,
      String? errorPath}) async {
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
      log(data.error!);
      onError?.call(baseUri.toString() + endpoint, data.error);
      return Future.error(data.error!);
    }
  }

  static Future<dynamic> _post(String endpoint,
      {Map<String, String>? headers,
      Map<String, String>? body,
      List<http.MultipartFile>? files,
      String? method}) async {
    endpoint = baseUri.toString() + endpoint;
    method = method?.toUpperCase() ?? 'GET';

    if (body == null) body = Map<String, String>();
    if (globalParams.isNotEmpty) body.addAll(globalParams);

    String queryEndpoint = '';
    if (method != 'POST' && body.isNotEmpty)
      queryEndpoint = Uri(queryParameters: body).query;
    if (headers == null) headers = {};
    // var r = MultipartRequest(
    //     (files?.isNotEmpty ?? false) ? "post" : method ?? "get",
    //     Uri.parse(endpoint));

    //var r = HttpRe(method ?? 'get', Uri.parse(endpoint));
    if (printRequests) {
      // String t = '';
      // if (method != 'POST' && body != null && body.length > 0)
      //   queryEndpoint = Uri(queryParameters: body).query;
      // body.forEach((key, value) {
      //   t += (t.isEmpty ? '?' : '&') + '$key=$value';
      // });
      print('Request: $method ' + endpoint + '?' + queryEndpoint);
    }
//http.
    try {
      // if (headers != null && headers.length > 0)
      //   r.headers.addAll(headers as Map<String, String>);
      // if (Api.headers.isNotEmpty) r.headers.addEntries(Api.headers.entries);
      // log('generando conexion: $method');

      http.Response r;
      switch (method) {
        case 'POST':
          var j = json.encode(body);
          headers.addEntries(
              [MapEntry<String, String>('content-type', 'application/json')]);
          r = await http.post(Uri.parse(endpoint), headers: headers, body: j);
          break;

        default:
          var url = Uri.parse(endpoint);
          if (body.isNotEmpty) {
            String queryString = '?' + Uri(queryParameters: body).query;
            url = Uri.parse(endpoint + queryString);
          }

          // var url = Uri.dataFromString(endpoint, parameters: body);
          // var url = Uri( , queryParameters: body);
          // var url = Uri.parse(endpoint);
          // url.queryParametersAll.addAll(body)
          // if (body?.isNotEmpty ?? false) url.queryParameters.addAll(body!);
          r = await http.get(url, headers: headers);
      }

      // if (body != null && body.length > 0)
      //   r.fields.addAll(body as Map<String, String>);
      // if (files != null && files.length > 0) r.files.addAll(files);

      // http.StreamedResponse response;
      try {
        // response = await r.send();
      } catch (e) {
        log('Error al intentar acceder a ' + endpoint + ': ' + e.toString(),
            name: method);
        return {
          "isSuccess": false,
          globalErrorPath ?? 'message':
              'No se puede conectar al servidor, corroborá tu conexión a Internet.'
        };
      }
      // String res = await response.stream.bytesToString();
      String res = r.body;

      //int statusCode = response.statusCode;
      int statusCode = r.statusCode;
      if (statusCode < 200 || statusCode >= 400) {
        String e = '';

        if (globalErrorPath != null) {
          try {
            var rta = json.decode(res);
            var err = rta[globalErrorPath];
            if (err != null) e = err;
          } catch (er) {}
        }

        if (e.isEmpty)
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

        if (printResponses) {
          print('Response ' + statusCode.toString() + ': ' + endpoint);
          print(res.toString());
        }

        // log('Error ' + statusCode.toString() + ' al acceder a ' + endpoint,
        //     name: "post");

        // if (_isInDebugMode || printResponses) log(res.toString());

        return {"isSuccess": false, globalErrorPath ?? 'message': e};
      } else {
        var rta = json.decode(res);
        if (printResponses) {
          print('Response ' + statusCode.toString() + ': ' + endpoint);
          print(rta.toString());
        }
        return rta;
      }
    } catch (e) {
      if (printResponses)
        print('Response Error: ' + endpoint + ' => ' + e.toString());
      log(e.toString(), error: e);
      return Future.error(e);
    }
  }
}
