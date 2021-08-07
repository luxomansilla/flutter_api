import 'package:flutter/material.dart';

import 'responses.dart';
import 'api.dart';

class ApiBuilder<T extends dynamic> extends StatelessWidget {
  final Widget Function(ApiResponse<T> data) builder;
  final Widget? loading;
  final String url;
  final Map<String, String>? args;
  final String method;
  final String? dataPath;
  final String? errorPath;
  final bool? showLoading;
  ApiBuilder(
      {required this.url,
      this.args,
      this.method: 'get',
      this.dataPath,
      required this.builder,
      this.loading,
      this.showLoading,
      this.errorPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<T>>(
        future: Api.get<T>(url, args: args, method: method, dataPath: dataPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return builder(snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.waiting &&
              showLoading!) {
            return loading ?? Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!.hasData) {}
          return Container();
        });
  }
}

class ApiListBuilder<T extends dynamic> extends StatelessWidget {
  final Widget Function(ApiResponseList<T> data) builder;
  final Widget? loading;
  final String url;
  final Map<String, String>? args;
  final String method;
  final String? dataPath;
  final String? errorPath;
  final bool showLoading;
  ApiListBuilder(
      {required this.url,
      this.args,
      this.method: 'get',
      this.dataPath,
      required this.builder,
      this.loading,
      this.showLoading: true,
      this.errorPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponseList<T>>(
        future:
            Api.getList<T>(url, args: args, method: method, dataPath: dataPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return builder(snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.waiting &&
              showLoading) {
            return loading ?? Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!.hasData) {}
          return Container();
        });
  }
}

class ApiMapBuilder<K, V> extends StatelessWidget {
  final Widget Function(ApiResponseMap<K, V> data) builder;
  final Widget? loading;
  final String url;
  final Map<String, String>? args;
  final String method;
  final String? dataPath;
  final String? errorPath;
  final bool showLoading;
  ApiMapBuilder(
      {required this.url,
      this.args,
      this.method: 'get',
      this.dataPath,
      required this.builder,
      this.loading,
      this.showLoading: true,
      this.errorPath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponseMap<K, V>>(
        future: Api.getMap<K, V>(url,
            args: args, method: method, dataPath: dataPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return builder(snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.waiting &&
              showLoading) {
            return loading ?? Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data!.hasData) {}
          return Container();
        });
  }
}
