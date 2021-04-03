# flutter_api

A REST API Connector, you can connect your Flutter Project to any endpoint easily.


## Initialization 

The `baseUri` is **required** and it's used globally

```dart
  Api.baseUri = Uri.parse('https://query1.finance.yahoo.com/v8/finance/');
```


## Configuration

* `Api.baseUri` used by all the requests. (required)
* `Api.globalDataPath` sets the json path of the response for `value.data`.
* `Api.globalErrorPath` sets the json path for determine if an error exists in the response.
* `Api.headers` can add any header required by the api.
* `Api.onError` it's called when has a error on the response.


## Functions usage

* `Api.set()` it's make a call to the Api, this don't returns value.
* `Api.get<T>()` returns a value.
* `Api.getList<T>()` returns a `List` value.
* `Api.getMap<K,V>()` returns a `Map` value.

Example:
```dart
  Api.get<num>(
          'chart/${_currencys[0]}=X?includePrePost=false&interval=1d&corsDomain=finance.yahoo.com&.tsrc=finance',
          dataPath: 'chart/result/meta/regularMarketPrice')
      .then((value) {
    print(_currencys[0] + ': ' + value.data.toString());
  });
```


## Builders usage

* `ApiBuilder<T>` returns a value._
* `ApiListBuilder<T>` returns a `List` value.
* `ApiMapBuilder<K,V>` returns a `Map` value.

Example:
```dart
  ApiBuilder(
    url:
        'chart/${_currencys[index]}=X?includePrePost=false&interval=1d&corsDomain=finance.yahoo.com&.tsrc=finance',
    dataPath: 'chart/result/meta',
    showLoading: false,
    builder: (value) {
      if (!value.hasData) return Text("No Data");
      var title = 'USD - ' + value.data['currency'];
      return ListTile(
        title: Text(title),
        subtitle: Text(
          DateTime.fromMillisecondsSinceEpoch(
                      value.data['regularMarketTime'] * 1000)
                  .toString() +
              ' (${value.data['timezone']})',
          textScaleFactor: .8,
        ),
        trailing: Text(
            value.data['regularMarketPrice'].toString() + ' \$'),
      );
    },
  );
```