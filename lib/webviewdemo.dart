import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 4.4.4; One Build/KTU84L.H4) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/28.0.0.20.16;]';

class WebViewDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Payment Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => const MyHomePage(title: 'Flutter Payment Demo'),
        '/widget': (_) => new WebviewScaffold(
              appBar: new AppBar(
                title: const Text('Widget webview'),
              ),
              withZoom: true,
              withLocalStorage: true,
            )
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //fields required for payments
  String _itemId = "10";
  String _userToken = "abc123";
  String _currency = "usd";

  // Instance of WebView plugin
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  // On destroy stream
  StreamSubscription _onDestroy;

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;
  bool _isLoading = false;

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        _scaffoldKey.currentState.showSnackBar(
            const SnackBar(content: const Text('Webview Destroyed')));
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          print('onUrlChanged: $url');

          if (url.contains("failed")) {
            flutterWebviewPlugin.close();
            _showDialog("UNSUCCESSFUL", "assets/unsuccess_logo.png");
          } else if (url.contains("success")) {
            flutterWebviewPlugin.close();
            _showDialog("SUCCESSFUL", "assets/success_logo.png");
          }
          //check if stripe or paypal page is loaded or not
          else if (url.contains("stripe") || url.contains("paypal")) {
            //hide progress bar

            setState(() {
              _isLoading = false; //hide progress bar
              //show webpage in full screen
              flutterWebviewPlugin.resize(new Rect.fromLTWH(
                  0.0,
                  0.0,
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height));
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    flutterWebviewPlugin.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new RaisedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    String paypalurl =
                        "http://54.213.174.41/leaftyme/public/api/customer/paypal";
                    flutterWebviewPlugin.launch("$paypalurl",
                        rect: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0),
                        userAgent: kAndroidUserAgent,
                        headers: {
                          "token": "$_userToken",
                          "item_id": "$_itemId",
                          "currency": "$_currency"
                        });
                  },
                  child: const Text('Paypal Payment'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new RaisedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });

                      String paypalurl =
                          "http://54.213.174.41/leaftyme/public/api/customer/stripe";

                      flutterWebviewPlugin.launch("$paypalurl",
                          rect: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0),
                          userAgent: kAndroidUserAgent,
                          headers: {
                            "token": "$_userToken",
                            "item_id": "$_itemId",
                            "currency": "$_currency"
                          });
                    },
                    child: const Text('Stripe Payment'),
                  ),
                ),
              ],
            ),
          ),
          buildLoading() //show loading
        ],
      ),
    );
  }

  //show loading

  Widget buildLoading() {
    return Positioned(
        child: _isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(new Color(0xfff5a623))),
                ),
                color: Colors.white.withOpacity(0.8),
              )
            : new Container());
  }

  //show dialog for choose images from
// user defined function
  void _showDialog(String message, String logo) {
    // flutter defined function
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Center(child: new Text("Payment Status")),
          content: new Container(
            height: 100.0,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset(
                  "$logo",
                  height: 50.0,
                  width: 50.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new Text(
                    "$message",
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.green,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Roboto"),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
