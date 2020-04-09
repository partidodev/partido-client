import 'package:flutter/material.dart';

class SignupSuccessfulPage extends StatelessWidget {

  SignupSuccessfulPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign up'),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20, 35, 20, 20),
          children: <Widget>[
            Column(
             // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sign up',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 15.0),
                Text("You have been signed up successfully!"),
                SizedBox(height: 15.0),
                Text("You can now start by logging in and creating a new group or joining an existing group if you recieved a join key."),
                SizedBox(height: 15.0),
                MaterialButton(
                    minWidth: double.infinity,
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text("Login"),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    }),
              ],
            ),
          ],
        )
    );
  }
}
