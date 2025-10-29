import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:buscardor_de_gifs/pages/gifpage.dart";
import 'package:share_plus/share_plus.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _offset = 0;
  String? _search;

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: getGIFCount(snapshot.data["data"]),
      itemBuilder: (BuildContext context, int index) {
        if (_search == null || index < snapshot.data["data"].length) {
          return GestureDetector(
            onTap: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> GifPage(snapshot.data["data"][index])));
              });
            },
            onLongPress: (){
              SharePlus.instance.share(
                  ShareParams(text: snapshot.data["data"][index]["images"]["fixed_height"]["url"])
              );
            },
            child: Image.network(
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              fit: BoxFit.cover,
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 70),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search!.isEmpty) {
      response = await http.get(
        Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=Xmoh3lEaWH1mIxlKy4KX7xC6lOhJN6vn&limit=19&offset=0&rating=g&bundle=messaging_non_clips",
        ),
      );
    } else {
      response = await http.get(
        Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=Xmoh3lEaWH1mIxlKy4KX7xC6lOhJN6vn&q=$_search&limit=19&offset=$_offset&rating=g&lang=en&bundle=messaging_non_clips",
        ),
      );
    }
    return json.decode(response.body);
  }

  int getGIFCount(List data) {
    if (_search == null) {
      return data.length - 1;
    } else {
      return data.length + 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif",
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }

                  default:
                    return Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
