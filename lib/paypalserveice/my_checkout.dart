import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_paypal_demo/paypalserveice/my_paypal_services.dart';
import 'package:flutter_paypal_demo/screens/return.dart';

class PaypalCheckout extends StatefulWidget {
  final Function? onSuccess, onCancel, onError;
  final String? returnURL, cancelURL, note, clientId, secretKey;
  final List? transactions;
  final bool? sandboxMode;

  const PaypalCheckout({
    super.key,
    this.onSuccess,
    this.onError,
    this.onCancel,
    required this.returnURL,
    required this.cancelURL,
    required this.transactions,
    required this.clientId,
    required this.secretKey,
    this.sandboxMode = false,
    this.note = '',
  });

  @override
  State<StatefulWidget> createState() {
    return PaypalCheckoutState();
  }
}

class PaypalCheckoutState extends State<PaypalCheckout> {
  String? checkoutUrl;
  String navUrl = '';
  String executeUrl = '';
  String accessToken = '';
  bool loading = true;
  bool pageloading = true;
  bool loadingError = false;
  late PaypalServices services;
  int pressed = 0;
  double progress = 0;

  late InAppWebViewController webView;

  Map getOrderParams() {
    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": widget.transactions,
      "note_to_payer": widget.note,
      "redirect_urls": {
        "return_url": widget.returnURL,
        "cancel_url": widget.cancelURL
      }
    };
    return temp;
  }

  @override
  void initState() {
    services = PaypalServices(
      sandboxMode: widget.sandboxMode!,
      clientId: widget.clientId!,
      secretKey: widget.secretKey!,
    );

    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        Map getToken = await services.getAccessToken();

        if (getToken['token'] != null) {
          accessToken = getToken['token'];
          final transactions = getOrderParams();
          final res =
              await services.createPaypalPayment(transactions, accessToken);

          if (res["approvalUrl"] != null) {
            setState(() {
              checkoutUrl = res["approvalUrl"];
              executeUrl = res["executeUrl"];
            });
          } else {
            widget.onError!(res);
          }
        } else {
          widget.onError!("${getToken['message']}");
        }
      } catch (e) {
        widget.onError!(e);
        print('exception: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Paypal Payment",
          ),
        ),
        body: Stack(
          children: <Widget>[
            InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(checkoutUrl!)),
              initialOptions: InAppWebViewGroupOptions(
                android: AndroidInAppWebViewOptions(textZoom: 120),
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onLoadStart: (
                InAppWebViewController? controller,
                Uri? requestURL,
              ) {
                print("===== out URI $requestURL");
                print("inside : ${requestURL!.path} == ${widget.returnURL!}");
                if (requestURL!.path
                    .contains(Uri.parse(widget.returnURL!).path)) {
                  final uri = requestURL;
                  print("===== URI $uri");
                  final payerID = uri.queryParameters['PayerID'];

                  if (payerID != null) {
                    services
                        .executePayment(executeUrl, payerID, accessToken)
                        .then(
                      (id) {
                        widget.onSuccess!(id);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const ReturnPage(),
                        ));
                      },
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                }

                if (requestURL.path.contains(widget.cancelURL!)) {
                  print("cancelURL");
                  widget.onCancel!();
                  Navigator.of(context).pop();
                }
              },
              onCloseWindow: (InAppWebViewController controller) {
                widget.onCancel!();
              },
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
            progress < 1
                ? SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: progress,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Paypal Payment",
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
