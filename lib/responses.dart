import 'api.dart';

dynamic _jsonValue(String path, dynamic json) {
  dynamic value = json;
  for (String i in path.split("/")) {
    while (value is Iterable) value = (value as Iterable).first;
    if (value != null) {
      value = value[i];
    } else {
      return null;
    }
  }
  return value;
}

class ApiResponse<T extends dynamic> {
  String _error;
  T _data;
  int _dataCount;

  bool get isSuccess => _error == null;
  String get error => _error;
  bool get hasData => _data != null;
  T get data => _data;
  int get count => _dataCount;

  ApiResponse(dynamic obj, {String dataPath, String errorPath}) {
    if ((errorPath ?? Api.globalErrorPath) != null)
      this._error = _jsonValue(errorPath ?? Api.globalErrorPath, obj);
    if (isSuccess) {
      if ((dataPath ?? Api.globalDataPath) != null) {
        this._data = _jsonValue(dataPath ?? Api.globalDataPath, obj);
      } else {
        this._data = obj;
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
}

class ApiResponseList<T extends dynamic> {
  String _error;
  List<T> _items;

  bool get isSuccess => _error == null;
  String get error => _error;
  bool get hasData => _items != null && _items.length > 0;
  List<T> get items => _items;

  ApiResponseList(dynamic obj, {String dataPath, String errorPath}) {
    var r = ApiResponse<dynamic>(obj, dataPath: dataPath, errorPath: errorPath);
    _error = r.error;

    if (isSuccess) this._items = List.from(r.data);
  }
}

class ApiResponseMap<K, V> {
  String _error;
  Map<K, V> _map;

  bool get isSuccess => _error == null;
  String get error => _error;
  bool get hasData => _map != null && _map.length > 0;
  Map<K, V> get map => _map;

  ApiResponseMap(dynamic obj, {String dataPath, String errorPath}) {
    var r = ApiResponse<dynamic>(obj, dataPath: dataPath, errorPath: errorPath);
    _error = r.error;

    if (isSuccess) this._map = Map.castFrom(r.data);
  }
}
