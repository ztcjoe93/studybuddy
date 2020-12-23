import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Changelog extends StatefulWidget {
  @override
  _ChangelogState createState() => _ChangelogState();
}

class _ChangelogState extends State<Changelog> {

  //https://stackoverflow.com/questions/44816042/flutter-read-text-file-from-assets
  Future<String> readChangeLog() async {
    // fetch changelog from logs/ and parse
    String data = await rootBundle.loadString('logs/changelog.md');
    var lines = data.split("\n");
    return data;
  }

  @override
  void initState() {
    super.initState();
    readChangeLog();
  }

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
                  future: readChangeLog(),
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
