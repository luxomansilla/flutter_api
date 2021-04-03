import 'package:flutter/material.dart';
import 'package:flutter_api/api.dart';
import 'package:flutter_api/api_builders.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> _currencys = ["USDARS", "USDCAD", "USDJPY", "USDMXN", "USDEUR"];

  @override
  void initState() {
    super.initState();
    Api.baseUri = Uri.parse('https://query1.finance.yahoo.com/v8/finance/');
    Api.globalDataPath='';
    Api.globalErrorPath='';
    Api.headers= null;
    Api.onError=null;
Api.set<String>(endpoint)
    Api.get<num>(
            'chart/${_currencys[0]}=X?includePrePost=false&interval=1d&corsDomain=finance.yahoo.com&.tsrc=finance',
            dataPath: 'chart/result/meta/regularMarketPrice')
        .then((value) {
      print(_currencys[0] + ': ' + value.data.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Api example')),
        body: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            itemCount: _currencys.length,
            itemBuilder: (BuildContext context, int index) {
              return ApiBuilder(
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
                    onTap: () =>
                        _dialogMap(context, 'Map $title', _currencys[index]),
                    onLongPress: () =>
                        _dialogList(context, 'List $title', _currencys[index]),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _dialogList(BuildContext context, String title, String currency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cierres $title'),
        content: ApiListBuilder<double>(
          url:
              'chart/$currency=X?includePrePost=false&interval=1m&corsDomain=finance.yahoo.com&.tsrc=finance',
          dataPath: 'chart/result/indicators/quote/close',
          builder: (data) {
            List<Widget> list = [];

            for (var i = 0; i < data.items.length; i++) {
              var item = data.items[i];
              if (item == null) continue;
              if (i > 0 && data.items[i - 1] == item) continue;
              list.add(ListTile(
                trailing: Text(item.toString()),
              ));
            }

            return Scrollbar(
              child: SingleChildScrollView(child: Column(children: list)),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _dialogMap(BuildContext context, String title, String currency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: ApiMapBuilder<String, dynamic>(
          url:
              'chart/$currency=X?includePrePost=false&interval=1m&corsDomain=finance.yahoo.com&.tsrc=finance',
          dataPath: 'chart',
          builder: (data) {
            List<Widget> list = [];

            var timestamps =
                List.castFrom<dynamic, int>(data.map['result'][0]['timestamp']);
            var quotes = List.castFrom<dynamic, double>(
                data.map['result'][0]['indicators']['quote'][0]['close']);

            for (var i = 0; i < timestamps.length; i++) {
              var time =
                  DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000);
              list.add(ListTile(
                title: Text(
                  time.toString(),
                  textScaleFactor: .8,
                ),
                trailing: Text(
                    (quotes[i] == null ? '-' : quotes[i].toStringAsFixed(4)) +
                        ' \$'),
              ));
            }

            return Scrollbar(
              child: SingleChildScrollView(child: Column(children: list)),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ACEPTAR'),
          ),
        ],
      ),
    );
  }
}
