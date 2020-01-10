import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gif/ui/git_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //! DEFININDO VARIAVEIS
  String _search;
  int _offset = 0;
  bool net = true;

  //! CRIANDO OS SNACKBARS
  final snackFast = SnackBar(
    content: Text('Consumo de Internet Normal!'),
    duration: Duration(seconds: 2),
  );
  final snackSlow = SnackBar(
    content: Text('Modo Economia de Internet Ativa!'),
    duration: Duration(seconds: 2),
  );

  //! FUTURE FUNCTION
  Future<Map> _getGifs() async {
    http.Response response;

    if (_search==null || _search.isEmpty) {
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=j3TzB4uAtMUA7AX2PUq4hCMsWoLvomQs&limit=20&rating=G');
    } else {
      response = await http.get('https://api.giphy.com/v1/gifs/search?api_key=j3TzB4uAtMUA7AX2PUq4hCMsWoLvomQs&q=$_search&limit=20&offset=$_offset&rating=G&lang=en');
    }

    return json.decode(response.body);
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
      //!APPBAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network('https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),

      //!BODY
      body: Builder(
        builder: (context) => Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                //! TEXT INPUT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(color: Colors.white)
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Pesquise Aqui!',
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.white, fontSize:18 ),
                        textAlign: TextAlign.center,
                        onSubmitted: (text) {
                          setState(() {
                            _search = text;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                //! SLOWLY NET BUTTON
                FloatingActionButton(
                  child: Icon(Icons.wifi, color: (net==true)?Colors.white:Colors.black,),
                  backgroundColor: (net==true)?Colors.black:Colors.white,
                  onPressed: (){
                    setState(() {
                      if (net) {
                        net = false;
                        Scaffold.of(context).showSnackBar(snackSlow);
                      } else {
                        net = true;
                        Scaffold.of(context).showSnackBar(snackFast);
                      }
                    });
                  },
                )
              ],
            ),

            //! GRID GIFS
            Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        height: 200.0,
                        width: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) return Container();
                      else return _createGifTable(context, snapshot);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
      ),
      itemCount: snapshot.data['data'].length,
      itemBuilder: (context, index) {
        // if (index == (snapshot.data['data'].length-1) && _search != null) {
        if (index == (snapshot.data['data'].length-1) && _search != null) {
          return GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0,),
                  Text('Pesquisar Mais...', style: TextStyle(color: Colors.white, fontSize: 20.0),)
                ],
              ),
            ),
            onTap: (){
              setState(() {
                _offset += 19;
              });
            },
          );
        } else {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images'][(net)?'fixed_height':'preview_gif']['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>GifPage(snapshot.data['data'][index])));
            },
            onLongPress: (){
              Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        }
      },
    );
  }

}