//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/rendering.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DelayScreen(),
    );
  }
}

List<String> path = [], title = [], disc = [];

class DelayScreen extends StatefulWidget {
  @override
  _DelayScreenState createState() => _DelayScreenState();
}

class _DelayScreenState extends State<DelayScreen> {

  List<Map> sorted = [];

  Future server() async{
    List<Map> news = [];
    Map sortmap = {};
    List list = [];
    String local;
    http.Response response;
    response = await http.get("https://hubblesite.org/api/v3/news");
    int i = 0, j;
    if(response.statusCode == 200){
      json.decode(response.body).forEach((value){
        news.add(json.decode(json.encode(value)));
        local = news[i]["news_id"];
        sortmap[local] = i;
        list.contains(int.parse(local.substring(local.indexOf("-") + 1))) ?
        Container() : list.add(int.parse(local.substring(local.indexOf("-") + 1)));
        i++;
      });
    }

    for (i = 0; i < list.length-1; i++){
      for (j = 0; j < list.length-i-1; j++)
        if (list[j] > list[j+1]){
          int temp = list[j];
          list[j] = list[j+1];
          list[j+1] = temp;
        }
    }
    for(j = 0; j<=1; j++){
      for(i = 0; i < list.length-1; i++){
        if(j == 0){
          sortmap.keys.contains("2020-${list[i]}") ?
          sorted.add(news[sortmap["2020-${list[i]}"]]) : Container();}
        else
        {
          sortmap.keys.contains("2021-${list[i]}") ?
          sorted.add(news[sortmap["2021-${list[i]}"]]) : Container();
        }
      }
    }
  }


  @override
  void initState() {
    server().then((value) => Future.delayed(Duration(seconds: 2), (){
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (BuildContext context) => MyHomePage(sorted: sorted,)
      ));
    }));
    super.initState();
  }

/*  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs){
      path = prefs.getStringList("path");
      title = prefs.getStringList("title");
      disc = prefs.getStringList("disc");
    }).then((value) =>     Future.delayed(Duration(seconds: 2), (){
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (BuildContext context) => MyHomePage()
    ));
    }));
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.white,
        body: Center(child: Image.asset('assets/tenor.gif')));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, @required this.sorted}) : super(key: key);

  final List<Map> sorted;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<VideoPlayerController> vController = [];

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0a3b10),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              margin: EdgeInsets.all(0),
              padding: EdgeInsets.all(0),
              child: Container(
                color: Color(0xff0a3b10),
            ),
            ),
            GestureDetector(
              onTap: (){
                _scaffoldKey.currentState.openEndDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Home"),
                  ),
                ),
              ),
            ),
            Divider(color: Colors.black, indent: 20, height: 5, endIndent: 20,),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {return player();}));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Video"),
                  ),
                ),
              ),
            ),
            Divider(color: Colors.black, indent: 20, height: 5, endIndent: 20,),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) { return profile();}));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Profile"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: List.generate(widget.sorted.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) { return browser(url: widget.sorted[index]["url"],);}));
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: ClipRect(
                          clipBehavior: Clip.hardEdge,
                            child: Image.asset("assets/news.png"),
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.sorted[index]["name"], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,maxLines: 2,),
                            Text("This is the news to be read after opening this tile to other window", overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 2,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.call_to_action),
                                Text(widget.sorted[index]['news_id']),
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 1, top: 1),
                                    child: Text("Sports", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                  ),
                                  color: Colors.orange,
                                ),
                                Icon(Icons.bookmark_border),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class profile extends StatelessWidget {

  List<TextEditingController> details = List.generate(6, (index) => TextEditingController());
  List<String> field = ["Location", "Pincode", "Date of Birth", "Gendar", "Whatsapp no.", "Email"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0a3b10),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.6,
            color: Colors.black12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Colors.orange),
                    ),
                    child: Center(child: Image.asset("assets/avatar.png")),
                  ),
                ),
                Text("Dinesh Shandilya", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20),),
                FlatButton(onPressed: () {  }, child: Text("Edit Profile", style: TextStyle(color: Colors.orange),), color: Colors.white,)
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                children: List.generate(6, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(field[index], style: TextStyle(color: Colors.black45),),
                              TextField(
                                controller: details[index],
                                textAlign: TextAlign.start,
                                textInputAction: TextInputAction.go,
                                style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                ),
                                decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 5.0, left: 5.0),
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                })
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class player extends StatefulWidget {
  @override
  _playerState createState() => _playerState();
}

class _playerState extends State<player> {

  VideoPlayerController vController;
  ChewieController chewieController;

  @override
 void initState(){
    vController = VideoPlayerController.asset("assets/video.MP4");
    chewieController = ChewieController(
        autoPlay: true,
        looping: true,
        showControlsOnInitialize: false,
        autoInitialize: false,
        videoPlayerController: vController);
    vController.initialize().then((value) {
      chewieController = ChewieController(
        aspectRatio: vController.value.aspectRatio,
        videoPlayerController: vController,
      );
    }).then((value) {setState(() {});});
    vController.play();
    super.initState();
  }

  @override
  void dispose() {
    vController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff0a3b10),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            elevation: 5,
            backgroundColor: Colors.white,
            title: Center(child: Text("Videos", style: TextStyle(color: Colors.black),)),
          ),
          SizedBox(height: 10,),
          Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            child: Chewie(
              controller: chewieController,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("This is the Heading text.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,maxLines: 2,),
                  Text("Date & Time", style: TextStyle(fontSize: 15, color: Colors.black87)),
                  Text("This is the Sub Heading.",overflow: TextOverflow.ellipsis,maxLines: 2,),
                  Center(
                      child: GestureDetector(
                        child: Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  offset: Offset.fromDirection(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                )
                              ],
                            ),
                            child: Center(child: Text("Information",style: TextStyle(fontWeight: FontWeight.bold),)),
                          ),
                        ),
                      )),
                ],
              )

            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                children: List.generate(20, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: ClipRect(
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset("assets/news.png"),
                              ),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Expanded(
                            flex: 3,
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Heading of the News", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,maxLines: 2,),
                                  Text("This is the news to be read after opening this tile to other window", overflow: TextOverflow.ellipsis, softWrap: true, maxLines: 2,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.call_to_action),
                                      Text("03-03-2021"),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 1, top: 1),
                                          child: Text("Sports", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                        ),
                                        color: Colors.orange,
                                      ),
                                      Icon(Icons.bookmark_border),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class browser extends StatelessWidget {
  browser({Key key,@required this.url}) : super(key: key);

  final String url;
  WebViewController _controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(),
      body: SafeArea(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: url,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          },
        ),
      ),
    );
  }
}


/*
class upload extends StatefulWidget {
  @override
  _uploadState createState() => _uploadState();
}

class _uploadState extends State<upload> {

  TextEditingController headline = TextEditingController(), description = TextEditingController();
  VideoPlayerController vController;
  ChewieController chewieController;
  final picker = ImagePicker();
  String videoPath;

  @override
  void dispose() {
    vController.dispose();
    super.dispose();
  }

  Future getImage(bool camera) async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      videoPath = pickedFile.path;
      vController = VideoPlayerController.file(File(videoPath));
      chewieController = ChewieController(
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
        autoInitialize: true,
        videoPlayerController: vController,
      );
    }
    setState(() {});
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.width * 0.5,
            color: Colors.grey,
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                  Radius.circular(
                      MediaQuery.of(context).size.width * 0.04)),
              child: videoPath != null ? Chewie(
                controller: chewieController,
              ) : Center(
                  child: FlatButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: Center(child: Text("Loading...",style: TextStyle(color: Colors.black45),)),
                              content: CupertinoActivityIndicator()
                          );
                        },
                      );
                      getImage(false);
                    },
              child: Row(
                children: [
                  Icon(Icons.file_upload),
                  Text("upload")
                ],),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              color: Colors.grey,
              child: TextField(
                controller: headline,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 13.0),
                    hintText: "Title",
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              color: Colors.grey,
              child: TextField(
                controller: description,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 13.0),
                    hintText: "Description",
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none),
              ),
            ),
          ),
          Center(
            child: FlatButton(
                onPressed: (){
                  if(path == null){
                    path = [];
                    title = [];
                    disc = [];
                  }
                  path.add(videoPath);
                  videoPath = null;
                  title.add(headline.text);
                  disc.add(description.text);
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setStringList("path", path);
                    prefs.setStringList("title", title);
                    prefs.setStringList("disc", disc);
                  });
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) { return MyHomePage();}));
                  },
                child: Text("Save"),
            ),
          )
        ],
      )
    );
  }
}
*/
