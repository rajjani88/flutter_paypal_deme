import 'package:flutter/material.dart';
import 'package:flutter_paypal_demo/paypalserveice/my_checkout.dart';
//import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
//import 'package:flutter_paypal/flutter_paypal.dart';

const mClientID =
    "ARRDwDLRACbhTIaJ4mx5d_s_0osCufD8D7h5ZO0pO_2HSuk26XwSqGfzBIXpwvLFLhEoF_fXEnBziK8r";
const mSecertKEy =
    "EFOSN7ZEqKqzJMGUB9FwQ9yDDWKlN4a8En4TNUyWcblEp84juEZVWJ7PPOx3llWXafuSCIVQUbByRGvX";

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  checkoutPaypal(BuildContext mContext) {
    Navigator.of(mContext).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckout(
        sandboxMode: true,
        clientId: mClientID,
        secretKey: mSecertKEy,
        returnURL: "success.snippetcoder.com",
        cancelURL: "cencel.com",
        transactions: const [
          {
            "amount": {
              "total": '10',
              "currency": "USD",
              "details": {
                "subtotal": '10',
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": "The payment transaction description.",
            "item_list": {
              "items": [
                {
                  "name": "Apple",
                  "quantity": 2,
                  "price": '5',
                  "currency": "USD"
                },
              ],
              // shipping address is Optional
              "shipping_address": {
                "recipient_name": "Raman Singh",
                "line1": "Delhi",
                "line2": "",
                "city": "Delhi",
                "country_code": "IN",
                "postal_code": "11001",
                "phone": "+00000000",
                "state": "Texas"
              },
            }
          }
        ],
        note: "PAYMENT_NOTE",
        onSuccess: onSuccess,
        onError: (error) {
          print("onError: $error");
          //Navigator.pop(context);
        },
        onCancel: () {
          print('cancelled:');
        },
      ),
    ));
  }

  onSuccess(Map params) async {
    print('I am Success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                // oncheckoutClick(context);
                checkoutPaypal(context);
              },
              child: const Text("Start Paypal Checkout"),
            ),
          )
        ],
      ),
    );
  }
}
