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
    String method = 'put',
    Map<String, String>? headers,
  }) async {
    ApiResponse<T> data;

    try {
      data = await _post(endpoint,
          args: args, files: files, method: method, headers: headers);
    } catch (e) {
      var obj = {"error": e.toString()};
      data = ApiResponse<T>(obj, errorPath: "error");
    }

    if (!data.isSuccess) {
      log(baseUri.toString() + endpoint, error: data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
    }

    return data;
  }

  static Future<ApiResponse<T>> set<T>(
    String endpoint, {
    Map<String, String>? args,
    List<http.MultipartFile>? files,
    String method = 'post',
    Map<String, String>? headers,
  }) async {
    ApiResponse<T> data;

    try {
      data = await _post(endpoint,
          args: args, files: files, method: method, headers: headers);
    } catch (e) {
      var obj = {"error": e.toString()};
      data = ApiResponse<T>(obj, errorPath: "error");
    }

    if (!data.isSuccess) {
      log(baseUri.toString() + endpoint, error: data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
    }

    return data;
  }

  static Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? args,
    List<http.MultipartFile>? files,
    String method = 'get',
    String? dataPath,
    String? errorPath,
    Map<String, String>? headers,
  }) async {
    ApiResponse<T> data;

    // try {
    var rta = await _post(endpoint,
        args: args,
        files: files,
        method: method,
        headers: headers,
        errorPath: errorPath);
    data = ApiResponse<T>(rta,
        dataPath: dataPath ?? globalDataPath, errorPath: errorPath);
    // } catch (e) {
    //   var obj = {"error": e.toString()};
    //   data = ApiResponse<T>(obj, errorPath: "error");
    // }

    if (!data.isSuccess) {
      log(baseUri.toString() + endpoint, error: data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
    }

    return data;
  }

  static Future<ApiResponseList<T>> getList<T>(
    String endpoint, {
    Map<String, String>? args,
    String method = 'get',
    String? dataPath,
    String? errorPath,
    Map<String, String>? headers,
  }) async {
    ApiResponseList<T> data;

    try {
      var rta = await _post(endpoint,
          args: args, method: method, headers: headers, errorPath: errorPath);
      data = ApiResponseList<T>(rta,
          dataPath: dataPath ?? globalDataPath, errorPath: errorPath);
    } catch (e) {
      var obj = {"error": e.toString()};
      data = ApiResponseList<T>(obj, errorPath: "error");
    }

    if (!data.isSuccess) {
      log(baseUri.toString() + endpoint, error: data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
    }

    return data;
  }

  static Future<ApiResponseMap<K, V>> getMap<K, V>(
    String endpoint, {
    Map<String, String>? args,
    String method = 'get',
    String? dataPath,
    String? errorPath,
    Map<String, String>? headers,
  }) async {
    ApiResponseMap<K, V> data;

    try {
      data = ApiResponseMap<K, V>(
          await _post(endpoint,
              args: args,
              method: method,
              headers: headers,
              errorPath: errorPath),
          dataPath: dataPath ?? globalDataPath,
          errorPath: errorPath);
    } catch (e) {
      var obj = {"error": e.toString()};
      data = ApiResponseMap<K, V>(obj, errorPath: "error");
    }

    if (!data.isSuccess) {
      log(baseUri.toString() + endpoint, error: data.error);
      onError?.call(baseUri.toString() + endpoint, data.error);
    }

    return data;
  }

  static Future<dynamic> _post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? args,
    List<http.MultipartFile>? files,
    String? method,
    String? errorPath,
  }) async {
    if (!endpoint.contains("://")) endpoint = baseUri.toString() + endpoint;
    if (errorPath == null) errorPath = globalErrorPath ?? 'error';

    method = method?.toUpperCase() ?? 'GET';

    if (args == null) args = Map<String, String>();
    if (globalParams.isNotEmpty) args.addAll(globalParams);

    String queryEndpoint = '';
    if (args.isNotEmpty) queryEndpoint = Uri(queryParameters: args).query;
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
      if (Api.headers.isNotEmpty) headers.addEntries(Api.headers.entries);
      // log('generando conexion: $method');

      http.Response? r;

      var url = Uri.parse(endpoint);
      if (args.isNotEmpty) {
        String queryString = '?' + Uri(queryParameters: args).query;
        url = Uri.parse(endpoint + queryString);
      }

      switch (method) {
        case 'POST':
          // {
          var request = http.MultipartRequest(method, url);
          request.headers.addAll(headers);

          if (files?.isNotEmpty ?? false) request.files.addAll(files!);
          await request.send().then((value) async {
            r = await http.Response.fromStream(value);
          });

          r = await http.post(url, headers: headers);

          break;
        case 'DELETE':
          r = await http.delete(url, headers: headers);

          break;
        default:
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
          errorPath:
              'No se puede conectar al servidor, corroborá tu conexión a Internet.'
        };
      }
      // String res = await response.stream.bytesToString();
      String res = r?.body ?? '';

      //int statusCode = response.statusCode;
      int statusCode = r?.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 400) {
        String e = '';

        try {
          var rta = json.decode(res);
          var err = rta[errorPath];
          if (err != null) e = err;
        } catch (er) {}

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

        return {errorPath: e};
      } else {
        if (res.isEmpty) {
          return ApiResponse("");
        }

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
      return {errorPath: e.toString()};
    }
  }
}
