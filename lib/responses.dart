import 'api.dart';

dynamic _jsonValue(String path, dynamic json) {
  dynamic value = json;
  for (String i in path.split("/")) {
    while (value is Iterable) value = value.first;
    if (value == null) return null;

    if (value is Map) {
      value = value[i];
    } else {
      return null;
    }
  }
  return value;
}

class ApiResponse<T extends dynamic> {
  String? _error;
  T? _data;
  late int _dataCount;

  bool get isSuccess => _error == null;
  String? get error => _error;
  bool get hasData => _data != null;
  T get data => _data!;
  int get count => _dataCount;

  ApiResponse(dynamic obj, {String? dataPath, String? errorPath}) {
    _error = _jsonValue(errorPath ?? Api.globalErrorPath ?? 'error', obj);

    if (isSuccess) {
      if ((dataPath ?? Api.globalDataPath) != null) {
        _data = _jsonValue(dataPath ?? Api.globalDataPath ?? '', obj);
      } else {
        _data = obj as T;
      }
      if (_data is Iterable) {
        _dataCount = (_data as Iterable).length;
      } else if (_data is Map) {
        _dataCount = (_data as Map).length;
      } else {
        _dataCount = 0;
      }
    }
  }

  bool get isMap => _data is Map;
  bool get isList => _data is Iterable;

  List<T> asList<T>() {
    if (isSuccess && isList) return List.from(_data as Iterable);
    return [];
  }

  Map<K, V> asMap<K, V>() {
    if (isSuccess && isMap)
      return Map.castFrom<String, dynamic, K, V>(_data as Map<String, dynamic>);
    return {};
  }
}

class ApiResponseList<T extends dynamic> {
  String? _error;
  List<T>? _items;

  bool get isSuccess => _error == null;
  String? get error => _error;
  bool get hasData => _items != null && _items!.length > 0;
  List<T> get items => _items ?? <T>[];

  ApiResponseList(dynamic obj, {String? dataPath, String? errorPath}) {
    _error = _jsonValue(errorPath ?? Api.globalErrorPath ?? 'error', obj);

    if (isSuccess && (dataPath == null || dataPath.isEmpty)) {
      this._items = List.from(obj);
    } else {
      var r =
          ApiResponse<dynamic>(obj, dataPath: dataPath, errorPath: errorPath);
      _error = r.error;

      if (isSuccess) this._items = List.from(r.data);
    }
  }
}

class ApiResponseMap<K, V> {
  String? _error;
  Map<K, V>? _map;

  bool get isSuccess => _error == null;
  String? get error => _error;
  bool get hasData => _map != null && _map!.length > 0;
  Map<K, V> get map => _map ?? <K, V>{};

  ApiResponseMap(dynamic obj, {String? dataPath, String? errorPath}) {
    if (dataPath == null || dataPath.isEmpty) {
      if (isSuccess) this._map = Map.castFrom(obj);
    } else {
      var r =
          ApiResponse<dynamic>(obj, dataPath: dataPath, errorPath: errorPath);
      _error = r.error;

      if (isSuccess) this._map = Map.castFrom(r.data);
    }
  }
}
