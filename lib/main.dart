import 'package:flutter/material.dart';
import 'package:fyp/Album.dart';
import 'package:fyp/Services/dbHelper.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:csv/csv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite Demo - Music',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter SQLite Demo - Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late dbHelper handler;

  @override
  void initState() {
    super.initState();
    handler = dbHelper();
    handler.initializeDB().whenComplete(() async {
      await addAlbum();
      setState(() {});
    });
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/config.json');
  }

  Future<int> addAlbum() async {
    final rawCSV = await rootBundle.loadString("assets/data.csv");
    List<List<dynamic>> csvList = const CsvToListConverter().convert(rawCSV);
    List<Album> albumList = [];
    for (var line in csvList) {
      Album album =
          Album(id: line[0], title: line[1], artist: line[2], price: line[3]);
      albumList.add(album);
    }
    return await handler.insertAlbums(albumList);
    // Album first = Album(
    //     id: 1, title: "The Queen Is Dead", artist: "The Smiths", price: 24.86);
    // Album second =
    //     Album(id: 2, title: "Nevermind", artist: "Nirvana", price: 17.39);
    // Album third =
    //     Album(id: 3, title: "OK Computer", artist: "RadioHead", price: 5.50);
    // List<Album> listOfAlbums = [first, second, third];
    // return await handler.insertAlbums(listOfAlbums);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: handler.retrieveAlbums(),
        builder: (BuildContext context, AsyncSnapshot<List<Album>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: const Icon(Icons.delete_forever),
                  ),
                  key: ValueKey<int>(snapshot.data![index].id),
                  onDismissed: (DismissDirection direction) async {
                    await handler.deleteAlbum(snapshot.data![index].id);
                    setState(() {
                      snapshot.data!.remove(snapshot.data![index]);
                    });
                  },
                  child: Card(
                      child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    title: Text(snapshot.data![index].title),
                    subtitle: Text(snapshot.data![index].artist +
                        "  £" +
                        snapshot.data![index].price.toString()),
                  )),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
