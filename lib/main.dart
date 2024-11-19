import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:sokos2/view-doc/index.dart';

void main() {
  // FlutterFileView.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // ignore: public_member_api_docs
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // const MyApp({super.key});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sokos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MediaListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MediaListScreen extends StatefulWidget {
  @override
  _MediaListScreenState createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  List<dynamic> mediaList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMediaData();
  }

  Future<void> fetchMediaData() async {
    final url = Uri.parse('https://dev-console.sokos.io/api/media');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        mediaList = json.decode(response.body)['docs'];
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sokos Media")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: mediaList.length,
              itemBuilder: (context, index) {
                final media = mediaList[index];
                return MediaTile(media: media);
              },
            ),
    );
  }
}

class MediaTile extends StatelessWidget {
  final dynamic media;

  MediaTile({required this.media});

  Future<void> downloadFile(String url, String filename) async {
    // Implement file download functionality here
    // Use packages like dio or path_provider for file saving
  }

  @override
  Widget build(BuildContext context) {
    final String mimeType = media['mimeType'] ?? '';
    final bool isImage = mimeType.startsWith('image/');
    final String? url = isImage
        ? media['sizes']['thumbnail']['url']
        : null; // Placeholder if no image URL for non-images

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display thumbnail if it’s an image, or show a document icon for non-image files
            isImage && url != null
                ? Image.network(
                    url,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.insert_drive_file, size: 100, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              media['alt'] ?? 'No Alt Text',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (isImage && media['sizes']['thumbnail']['url'] != null)
                    DownloadButton(
                      url: media['sizes']['thumbnail']['url'],
                      label: 'Thumbnail',
                      filename: media['sizes']['thumbnail']['filename'],
                    ),
                  if (isImage && media['sizes']['card']['url'] != null) ...[
                    SizedBox(width: 10), // Adjust this width as needed
                    DownloadButton(
                      url: media['sizes']['card']['url'],
                      label: 'Card',
                      filename: media['sizes']['card']['filename'],
                    ),
                  ],
                  if (isImage && media['sizes']['tablet']['url'] != null) ...[
                    SizedBox(width: 10),
                    DownloadButton(
                      url: media['sizes']['tablet']['url'],
                      label: 'Tablet',
                      filename: media['sizes']['tablet']['filename'],
                    ),
                  ],
                  if (!isImage) ...[
                    DownloadButton(
                      url: media['url'],
                      label: 'Download File',
                      filename: media['filename'],
                    ),
                    SizedBox(width: 10),
                    ViewButton(
                      url: media['url'],
                      label: 'View',
                      filename: media['filename'],
                      fileType: media['mimeType'],
                    ),
                  ],
                  if (isImage) ...[
                    SizedBox(width: 10),
                    ViewButton(
                      url: media['url'],
                      label: 'View',
                      filename: media['filename'],
                      fileType: media['mimeType'],
                    ),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DownloadButton extends StatelessWidget {
  final String url;
  final String label;
  final String filename;

  DownloadButton(
      {required this.url, required this.label, required this.filename});

  Future<void> downloadImage(
      BuildContext context, String url, String filename) async {
    try {
      // Get the application directory
      final directory = '/storage/emulated/0/Download/';
      final filePath = '$directory/$filename';

      // Start downloading the file
      final dio = Dio();
      await dio.download(url, filePath);

      // Show a success message
      print("File downloaded to $filePath");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Downloaded $filename")),
      );
    } catch (e) {
      print("Download failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to download $filename")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => downloadImage(context, url, filename),
      child: Text(label),
    );
  }
}

class ViewButton extends StatelessWidget {
  final String url;
  final String label;
  final String filename;
  final String fileType;

  ViewButton(
      {required this.url,
      required this.label,
      required this.filename,
      required this.fileType});

  Future<void> viewImage(
      BuildContext context, String url, String filename) async {
    try {
      
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDocScreen(
              url: url,
              filename: filename,
              fileType: fileType,
            ),
          ),
        );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Viewing $filename")),
      );
    } catch (e) {
      print("View failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't open this file!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => viewImage(context, url, filename),
      child: Text(label),
    );
  }
}
