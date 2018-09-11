import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 4.4.4; One Build/KTU84L.H4) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/28.0.0.20.16;]';

class WebViewDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter WebView Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => const MyHomePage(title: 'Flutter WebView Demo'),
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
  // This widget is the root of your application.

  int itemId = 10;
  String token = "abc123";
  String currency = "usd";
  String paypal = '''
 <!doctype html>
<html>
<head>
 <meta name="viewport" content="width=device-width">
<title>Untitled Document</title>
</head>
<style>
	
	body {
    padding: 10px;
}
	
	.summarydiv {
    float: left;
    text-align: center;
    width: 100%;
    padding: 20px 0;
}
.values-div {
    float: left;
    width: 100%;
    padding: 20px 0;
    border-bottom: 1px solid #d1d1d1;
}
	.valuerightsec1 {
    float: left;
    width: 50%;
    color: #2d2d2d;
    font-size: 15px;
		text-align: left;
}
		.valuerightsec2 {
    float: left;
    width: 50%;
    color: #2d2d2d;
    font-size: 15px;
				text-align: right;
}
	.summarydiv img {
    padding-bottom: 32px;
}
.summarydiv h3
{
	float:left;
	width:100%;
	text-align:center;
	color:#65BC46;
}
.paymentdiv {
    float: left;
    width: 100%;
    text-align: center;
    margin-top: 30px;
}
.paymentdiv button span {
    background: none;
    background-image: none;
}
.paymentdiv button {
    background: #65BC46;
        background-image: none;
    background-image: none !important;
}
.paypalbuttoncus {
    float: left;
    width: 100%;
    margin-top: 30px;
}
	</style>
<body>
	
	<div class="summarydiv">
    <img src="credit-card.png"  alt=""/> 
	<h3> Summary </h3>
	
	<div class="values-div">
		
		<div class="valuerightsec1">Item Name</div>
		<div class="valuerightsec2">Lorem</div>
		</div>
		<div class="values-div">
		<div class="valuerightsec1">Item Price</div>
		<div class="valuerightsec2">\$5000</div>
		</div>



<div id="paypal-button" class="paypalbuttoncus"></div>
<script src="https://www.paypalobjects.com/api/checkout.js"></script>
<script>
paypal.Button.render({
  // Configure environment
  env: 'sandbox',
  client: {
    sandbox: 'demo_sandbox_client_id',
    production: 'demo_production_client_id'
  },
  // Customize button (optional)
  locale: 'en_US',
  style: {
    size: 'small',
    color: 'gold',
    shape: 'pill',
  },
  // Set up a payment
  payment: function (data, actions) {
    return actions.payment.create({
      transactions: [{
        amount: {
          total: '0.01',
          currency: 'USD'
        }
      }]
    });
  },
  // Execute the payment
  onAuthorize: function (data, actions) {
    return actions.payment.execute()
      .then(function () {
        // Show a confirmation message to the buyer
        window.alert('Thank you for your purchase!');
      });
  }
}, '#paypal-button');
</script>


	</div>
</body>
</html>

  ''';

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

          if (url.contains("test1")) {
            flutterWebviewPlugin.close();
            _showDialog("SUCCESSFUL", "assets/success_logo.png");
          } else if (url.contains("failed")) {
            flutterWebviewPlugin.close();
            _showDialog("UNSUCCESSFUL", "assets/unsuccess_logo.png");
          } else if (url.contains("success")) {
            flutterWebviewPlugin.close();
            _showDialog("SUCCESSFUL", "assets/success_logo.png");
          } else if (url.contains("stripe") || url.contains("paypal")) {
            //hide progress bar
            setState(() {
              _isLoading = false; //hide progress bar
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
          Column(
            children: <Widget>[
              new RaisedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  String itemId = "10";
                  String token = "abc123";
                  String currency = "usd";
                  String paypalurl =
                      "http://54.213.174.41/leaftyme/public/api/customer/paypal";

                  flutterWebviewPlugin.launch("$paypalurl",
                      rect: new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0),
                      userAgent: kAndroidUserAgent,
                      headers: {
                        "token": "$token",
                        "item_id": "$itemId",
                        "currency": "$currency"
                      });
                },
                child: const Text('Paypal Payment)'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
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
                          "token": "$token",
                          "item_id": "$itemId",
                          "currency": "$currency"
                        });
                  },
                  child: const Text('Stripe Payment)'),
                ),
              ),
            ],
          ),
          buildLoading()
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
