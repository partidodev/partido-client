import 'package:flutter/material.dart';

class CreateBillPage extends StatefulWidget {
  CreateBillPage({Key key}) : super(key: key);

  @override
  _CreateBillPageState createState() => _CreateBillPageState();
}

class _CreateBillPageState extends State<CreateBillPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create bill'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Create bill form',
            ),
          ],
        ),
      ),
    );
  }
}
