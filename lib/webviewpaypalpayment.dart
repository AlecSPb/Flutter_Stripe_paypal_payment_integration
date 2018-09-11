import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 4.4.4; One Build/KTU84L.H4) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/28.0.0.20.16;]';

String selectedUrl = 'https://flutter.io';

class WebViewPaypalPayment extends StatelessWidget {
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
          url: selectedUrl,
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
  static String test = "Test Charge";
  static int amount = 100;
  static int purchaseamount = 100;
  static String currency ="usd" ;
  String page=''' <html>
  
 <head>
  <meta name="viewport" content="width=device-width">
  </head> 
<body>

<div id="paypal-button"></div>
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

</body>
</html>''';







  String customPage='''
 <!DOCTYPE html>
<html lang="en">
    <head>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
        <title>Stripe Sample Form</title>

        <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
        <script type="text/javascript" src="https://ajax.aspnetcdn.com/ajax/jquery.validate/1.8.1/jquery.validate.min.js"></script>
        <script type="text/javascript" src="https://js.stripe.com/v1/"></script>
        <script type="text/javascript">
          Stripe.setPublishableKey('pk_test_TYooMQauvdEDq54NiTphI7jx');
            \$(document).ready(function() {
                function addInputNames() {
                    // Not ideal, but jQuery's validate plugin requires fields to have names
                    // so we add them at the last possible minute, in case any javascript 
                    // exceptions have caused other parts of the script to fail.
                    \$(".card-number").attr("name", "card-number")
                    \$(".card-cvc").attr("name", "card-cvc")
                    \$(".card-expiry-year").attr("name", "card-expiry-year")
                }

                function removeInputNames() {
                    \$(".card-number").removeAttr("name")
                    \$(".card-cvc").removeAttr("name")
                    \$(".card-expiry-year").removeAttr("name")
                }

                function submit(form) {
                    // remove the input field names for security
                    // we do this *before* anything else which might throw an exception
                    removeInputNames(); // THIS IS IMPORTANT!

                    // given a valid form, submit the payment details to stripe
                    \$(form['submit-button']).attr("disabled", "disabled")

                    Stripe.createToken({
                        number: \$('.card-number').val(),
                        cvc: \$('.card-cvc').val(),
                        exp_month: \$('.card-expiry-month').val(), 
                        exp_year: \$('.card-expiry-year').val()
                    }, function(status, response) {
                        if (response.error) {
                            // re-enable the submit button
                            \$(form['submit-button']).removeAttr("disabled")
        
                            // show the error
                            \$(".payment-errors").html(response.error.message);

                            // we add these names back in so we can revalidate properly
                            addInputNames();
                        } else {
                            // token contains id, last4, and card type
                            var token = response['id'];

                            // insert the stripe token
                            var input = \$("<input name='stripeToken' value='" + token + "' style='display:none;' />");
                            form.appendChild(input[0])

                            // and submit
                            form.submit();
                        }
                    });
                    
                    return false;
                }
                
                // add custom rules for credit card validating
                jQuery.validator.addMethod("cardNumber", Stripe.validateCardNumber, "Please enter a valid card number");
                jQuery.validator.addMethod("cardCVC", Stripe.validateCVC, "Please enter a valid security code");
                jQuery.validator.addMethod("cardExpiry", function() {
                    return Stripe.validateExpiry(\$(".card-expiry-month").val(), 
                                                 \$(".card-expiry-year").val())
                }, "Please enter a valid expiration");

                // We use the jQuery validate plugin to validate required params on submit
                \$("#example-form").validate({
                    submitHandler: submit,
                    rules: {
                        "card-cvc" : {
                            cardCVC: true,
                            required: true
                        },
                        "card-number" : {
                            cardNumber: true,
                            required: true
                        },
                        "card-expiry-year" : "cardExpiry" // we don't validate month separately
                    }
                });

                // adding the input field names is the last step, in case an earlier step errors                
                addInputNames();
            });
        </script>
    </head>
    <body>

        <h1>Stripe Example Form</h1>
    
        <form action="http://54.213.174.41/leaftyme/public/api/customer/test" method="post" id="example-form" style="display: none;">

            <div class="form-row">
                <label for="name" class="stripeLabel">Your Name</label>
                <input type="text" name="name" class="required" />
            </div>            
    
            <div class="form-row">
                <label for="email">E-mail Address</label>
                <input type="text" name="email" class="required" />
            </div>            
    
            <div class="form-row">
                <label>Card Number</label>
                <input type="text" maxlength="20" autocomplete="off" class="card-number stripe-sensitive required" />
            </div>
            
            <div class="form-row">
                <label>CVC</label>
                <input type="text" maxlength="4" autocomplete="off" class="card-cvc stripe-sensitive required" />
            </div>
            
            <div class="form-row">
                <label>Expiration</label>
                <div class="expiry-wrapper">
                    <select class="card-expiry-month stripe-sensitive required">
                    </select>
                    <script type="text/javascript">
                        var select = \$(".card-expiry-month"),
                            month = new Date().getMonth() + 1;
                        for (var i = 1; i <= 12; i++) {
                            select.append(\$("<option value='"+i+"' "+(month === i ? "selected" : "")+">"+i+"</option>"))
                        }
                    </script>
                    <span> / </span>
                    <select class="card-expiry-year stripe-sensitive required"></select>
                    <script type="text/javascript">
                        var select = \$(".card-expiry-year"),
                            year = new Date().getFullYear();

                        for (var i = 0; i < 12; i++) {
                            select.append(\$("<option value='"+(i + year)+"' "+(i === 0 ? "selected" : "")+">"+(i + year)+"</option>"))
                        }
                    </script>
                </div>
            </div>

            <button type="submit" name="submit-button">Submit</button>
            <span class="payment-errors"></span>
        </form>

        <!-- 
            The easiest way to indicate that the form requires JavaScript is to show
            the form with JavaScript (otherwise it will not render). You can add a
            helpful message in a noscript to indicate that users should enable JS.
        -->
        <script>if (window.Stripe) \$("#example-form").show()</script>
        <noscript><p>JavaScript is required for the registration form.</p></noscript>

    </body>
</html>''';

  String success='''<!DOCTYPE html>
<html lang="en">
<head>
  <title>Bootstrap Example</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>
<body>

<div class="container">
  <h2>Alerts</h2>
  <div class="alert alert-success">
    <strong>Success!</strong> This alert box could indicate a successful or positive action.
  </div>
  <div class="alert alert-info">
    <strong>Info!</strong> This alert box could indicate a neutral informative change or action.
  </div>
  <div class="alert alert-warning">
    <strong>Warning!</strong> This alert box could indicate a warning that might need attention.
  </div>
  <div class="alert alert-danger">
    <strong>Danger!</strong> This alert box could indicate a dangerous or potentially negative action.
  </div>
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

  // On urlChanged stream
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  StreamSubscription<WebViewHttpError> _onHttpError;

  StreamSubscription<double> _onScrollYChanged;

  StreamSubscription<double> _onScrollXChanged;

  final _urlCtrl = new TextEditingController(text: selectedUrl);

  final _codeCtrl =
  new TextEditingController(text: 'window.navigator.userAgent');

  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  final _history = [];


  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    _urlCtrl.addListener(() {
      selectedUrl = _urlCtrl.text;
    });

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        _scaffoldKey.currentState.showSnackBar(
            const SnackBar(content: const Text('Webview Destroyed')));
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          _history.add('onUrlChanged: $url');
          print('onUrlChanged: $url');
          print(url.contains("test1"));
          if(url.contains("test1"))
            {
             // print(url.contains("payment done"));
//              _scaffoldKey.currentState.showSnackBar(
//                  const SnackBar(content: const Text('Payment Successful')));
         // _showDialog("Payment Successful");

              String url=new Uri.dataFromString("$success", mimeType: 'text/html').toString();
              flutterWebviewPlugin.launch(url,
                  rect: new Rect.fromLTWH(
                      0.0, 0.0, MediaQuery.of(context).size.width, (MediaQuery.of(context).size.height*95)/100),
                  userAgent: kAndroidUserAgent);


            }


        });
      }
    });




    _onScrollYChanged =
        flutterWebviewPlugin.onScrollYChanged.listen((double y) {
          if (mounted) {
            setState(() {
              _history.add("Scroll in  Y Direction: $y");
            });
          }
        });

    _onScrollXChanged =
        flutterWebviewPlugin.onScrollXChanged.listen((double x) {
          if (mounted) {
            setState(() {
              _history.add("Scroll in  X Direction: $x");
            });
          }
        });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
          if (mounted) {
            setState(() {
              _history.add('onStateChanged: ${state.type} ${state.url}');
            });
          }
        });

    _onHttpError =
        flutterWebviewPlugin.onHttpError.listen((WebViewHttpError error) {
          if (mounted) {
            setState(() {
              _history.add('onHttpError: ${error.code} ${error.url}');
            });
          }
        });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();

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
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Container(
            padding: const EdgeInsets.all(24.0),
            child: new TextField(controller: _urlCtrl),
          ),
          new RaisedButton(
            onPressed: () {
              String url=new Uri.dataFromString("$page", mimeType: 'text/html').toString();
              flutterWebviewPlugin.launch(url,
                  rect: new Rect.fromLTWH(
                      0.0, 0.0, MediaQuery.of(context).size.width, (MediaQuery.of(context).size.height*95)/100),
                  userAgent: kAndroidUserAgent);
            },
            child: const Text('Do Payment)'),
          ),

        ],
      ),
    );
  }

  //show dialog for choose images from
// user defined function
  void _showDialog(String message) {
    // flutter defined function
    showDialog(

      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Center(child: new Text("Payment Status")),
          content: new Container(
            height: 80.0,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    //close dialog
                    Navigator.pop(_scaffoldKey.currentContext);

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "Camera",
                      style: new TextStyle(fontSize: 17.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Roboto"),
                    ),
                  ),
                ),
                new Divider(
                  color: Colors.grey,
                ),
                InkWell(

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "Gallery",
                      style: new TextStyle(fontSize: 17.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Roboto"),
                    ),
                  ),
                  onTap: () { //close dialog
                    Navigator.pop(_scaffoldKey.currentContext);
                    //_onImageButtonPressed();
                  },
                ),
              ]
              ,
            ),

          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
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