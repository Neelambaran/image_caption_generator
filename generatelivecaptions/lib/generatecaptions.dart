import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class GenerateLiveCaptions extends StatefulWidget {
  const GenerateLiveCaptions({super.key});

  @override
  State<GenerateLiveCaptions> createState() => _GenerateLiveCaptionsState();
}

class _GenerateLiveCaptionsState extends State<GenerateLiveCaptions> {
  FlutterTts flutterTts = FlutterTts();
  String resultText = "Fetching Response...";
  List<CameraDescription>? cameras;
  CameraController? controller;
  bool takePhoto = false;

  @override
  void initState() {
    super.initState();
    takePhoto = true;
    detectCameras().then((_) {
      initializeController();
    });
  }

  Future<void> detectCameras() async {
    cameras = await availableCameras();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  void initializeController() {
    controller = CameraController(cameras![0], ResolutionPreset.medium);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      if (takePhoto) {
        const interval = const Duration(seconds: 5);
        new Timer.periodic(interval, (Timer t) => capturePictures());
      }
    });
  }

  capturePictures() async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    String filePath = '$dirPath/${timestamp}.png';

    if (takePhoto) {
      XFile imageFile = await controller!.takePicture();
      String imagePath = imageFile.path;

      if (takePhoto) {
        File imgFile = File(imagePath);
        fetchResponse(imgFile);
      }
    }
  }

  Future<Map<String, dynamic>?> fetchResponse(File image) async {
    final File file = image;
    final List<int> data = await file.readAsBytes();

    final response = await http.post(
      Uri.parse(
          "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large"),
      headers: {
        "Authorization": "Bearer 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"
      },
      body: data,
    );

    print(response);
    print(response.body);
    print("object");
    // if (response.statusCode == 200) {
    //   // final Map<String, dynamic> result = json.decode(response.body);
    //   // print(result);
    // } else {
    //   // throw Exception("Failed to query the API");
    //   print("ed");
    // }
    //   final mimeTypeData =
    //       lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    //   final imageUploadRequest = http.MultipartRequest(
    //       'POST',
    //       Uri.parse(
    //           'https://max-image-caption-generator-neelambaran-cs21-dev.apps.sandbox-m4.g2pi.p1.openshiftapps.com/model/predict'));

    //   final file = await http.MultipartFile.fromPath('image', image.path,
    //       contentType: MediaType(mimeTypeData![0], mimeTypeData[1]));

    //   imageUploadRequest.fields['ext'] = mimeTypeData[1];
    //   imageUploadRequest.files.add(file);

    try {
      List<dynamic> jsonList = json.decode(response.body);
      print(jsonList.toString());
      String generatedText = '';
      for (var jsonItem in jsonList) {
        // Access the "generated_text" field in each JSON object
        generatedText = jsonItem['generated_text'];
        print(generatedText);
      }
      parseResponse(generatedText);
      await flutterTts.speak(generatedText);
      // return generatedText.to;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void parseResponse(String response) {
    // String r = "";
    // var predictions = response['predictions'];
    // for (var prediction in predictions) {
    //   var caption = prediction['caption'];
    //   var probability = prediction['probability'];
    //   r = r + '$caption\n\n';
    // }
    setState(() {
      resultText = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.004, 1],
            colors: [
              Color(0x11232526),
              Color(0xFF232526),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 20),
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  setState(() {
                    takePhoto = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            if (controller != null)
              (controller!.value.isInitialized)
                  ? Center(child: buildCameraPreview())
                  : Container()
          ],
        ),
      ),
    );
  }

  Widget buildCameraPreview() {
    var size = MediaQuery.of(context).size.width / 1.2;
    return Column(
      children: <Widget>[
        Container(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Container(
              width: size,
              height: size,
              child: CameraPreview(controller!),
            ),
            SizedBox(height: 30),
            Text(
              'Prediction is: \n',
              style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.w900,
                fontSize: 30,
              ),
            ),
            Text(
              resultText,
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ))
      ],
    );
  }
}
