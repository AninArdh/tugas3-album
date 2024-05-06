import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Album App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AlbumList(),
    );
  }
}

class AlbumList extends StatefulWidget {
  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  List<dynamic> albums = [];
  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  void fetchAlbums() async {
    final albumResponse = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));
    final userResponse = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

    if (albumResponse.statusCode == 200 && userResponse.statusCode == 200) {
      final albumData = json.decode(albumResponse.body);
      final userData = json.decode(userResponse.body);

      albumData.forEach((album) {
        final user = userData.firstWhere((user) => user['id'] == album['userId'], orElse: () => null);
        album['username'] = user?['username'];
        album['name'] = user?['name'];
      });

      setState(() {
        albums = albumData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Album List'),
      ),
      body: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return ListTile(
            title: Text(album['title']),
            subtitle: Text('${album['username']} (${album['name']})'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlbumDetail(albumId: album['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AlbumDetail extends StatefulWidget {
  final int albumId;

  AlbumDetail({required this.albumId});

  @override
  _AlbumDetailState createState() => _AlbumDetailState();
}

class _AlbumDetailState extends State<AlbumDetail> {
  Map<String, dynamic> album = {};
  List<dynamic> photos = [];

  @override
  void initState() {
    super.initState();
    fetchAlbum();
  }

  void fetchAlbum() async {
    final albumResponse = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/${widget.albumId}'));
    final photoResponse = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos?albumId=${widget.albumId}'));

    if (albumResponse.statusCode == 200 && photoResponse.statusCode == 200) {
      final albumData = json.decode(albumResponse.body);
      final photoData = json.decode(photoResponse.body);

      final userResponse = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users/${albumData['userId']}'));

      if (userResponse.statusCode == 200) {
        final user = json.decode(userResponse.body);
        albumData['username'] = user['username'];
        albumData['name'] = user['name'];
      }

      setState(() {
        album = albumData;
        photos = photoData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(album['title'] ?? 'Album Detail'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username: ${album['username'] ?? ''}', style: TextStyle(fontSize: 18)),
                Text('Name: ${album['name'] ?? ''}', style: TextStyle(fontSize: 18)),
                Text('Title: ${album['title'] ?? ''}', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Card(
                  child: Column(
                    children: [
                      Image.network(photo['thumbnailUrl']),
                      Text(photo['title']),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
