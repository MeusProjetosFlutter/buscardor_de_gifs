import "package:flutter/material.dart";
import 'package:buscardor_de_gifs/pages/homepage.dart';
import 'package:share_plus/share_plus.dart';

class GifPage extends StatelessWidget {
  final Map _gifMap;

  GifPage(this._gifMap);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: shareGIF,
            icon: Icon(Icons.share),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(_gifMap["title"], style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: GestureDetector(
          onLongPress:shareGIF,
          child: Image.network(_gifMap["images"]["fixed_height"]["url"]),
        ),
      ),
    );
  }

  void shareGIF() {
    SharePlus.instance.share(
        ShareParams(text: _gifMap["images"]["fixed_height"]["url"])
    );
  }
}
