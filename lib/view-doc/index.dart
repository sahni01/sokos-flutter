import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewDocScreen extends StatefulWidget {
  final String url;
  final String filename;
  final String fileType;

  ViewDocScreen(
      {required this.url, required this.filename, required this.fileType});

  @override
  _ViewDocScreenState createState() => _ViewDocScreenState();
}

class _ViewDocScreenState extends State<ViewDocScreen> {
  List<dynamic> mediaList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> downloadFile(
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.filename)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: widget.fileType == 'application/pdf'
                  ? SfPdfViewer.network(widget.url)
                  : widget.fileType.contains("image")
                      ? Image(image: NetworkImage(widget.url)) : Container()
                      // : DocumentViewer(filePath: pdfFlePath!)
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.download),
                label: Text('Download'),
                onPressed: isLoading
                    ? null
                    : () => downloadFile(context, widget.url, widget.filename),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
