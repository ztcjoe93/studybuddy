import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Licenses extends StatefulWidget {
  @override
  _LicensesState createState() => _LicensesState();
}

class _LicensesState extends State<Licenses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.05),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                    future: rootBundle.loadString('logs/licenses.md'),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                      if (snapshot.hasData){
                        return Markdown(data: snapshot.data);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
