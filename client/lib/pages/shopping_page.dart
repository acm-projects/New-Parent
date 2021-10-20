import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycolor2/src/color_extension.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({Key? key}) : super(key: key);

  @override
  _ShoppingPageState createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  static const Color accentColor = Color(0xFF008080);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        foregroundColor: accentColor,
        backgroundColor: Colors.white,
        title: const Text(
          "Shopping",
          style: TextStyle(fontWeight: FontWeight.w200, fontSize: 50),
        ),
      ),
      body: SvgPicture.asset(
        'images/undraw_baby.svg',
        color: Colors.green.shade100,
      ),
    );
  }
}
