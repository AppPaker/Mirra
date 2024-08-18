import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRWidget extends StatelessWidget {
  final String data;
  final double size;

  const QRWidget({super.key, this.size = 100.0, required this.data});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String uid = user!.uid;

    return Center(
      child: Container(
        color: Colors.white, // this sets the background color to white
        child: PrettyQr(
          image: const AssetImage('assets/images/Asset_3@10x.png'),
          size: size,
          data: uid,
          elementColor: Colors.black, // this sets the squares to black
          errorCorrectLevel: QrErrorCorrectLevel.M,
          typeNumber: null,
          roundEdges: true,
        ),
      ),
    );
  }
}
