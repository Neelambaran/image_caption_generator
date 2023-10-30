import 'dart:convert';
import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:generatelivecaptions/generatecaptions.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FlutterTts flutterTts = FlutterTts();
  bool _loading = true;
  bool hideRepeat = true;
  late File _image;
  final picker = ImagePicker();
  String resultText = "Fetching";
  String message = '';
  String data = '';
  String from = 'en', to = '';
  String selectedvalue = '';
  TextEditingController controller = TextEditingController();
  List<String> languages = [
    'English',
    'Tamil',
    'Hindi',
    'Arabic	',
    'German',
    'Russian',
    'Spanish',
    'Urdu',
    'Japanese',
    'Italian',
    'French',
    'Malayalam',
    'Kannada',
    'Telugu',
    'Punjabi',
  ];
  List<String> languagescode = [
    'en',
    'ta',
    'hi',
    'ar',
    'de',
    'ru',
    'es',
    'ur',
    'ja',
    'it',
    'fr',
    'ml',
    'kn',
    'te',
    'pa',
  ];

  List<String> speechCode = [
    'en-IN',
    'ta-IN',
    'hi-IN',
    'ar',
    'de-DE',
    'ru-RU',
    'es-ES',
    'ur-PK',
    'ja-JP',
    'it-IT',
    'fr-FR',
    'ml-IN',
    'te-IN',
    'pa-IN'
  ];
  final translator = GoogleTranslator();

  translate(fromText) async {
    try {
      await translator.translate(fromText, from: from, to: to).then((value) {
        data = value.text;
        print(data);
        setState(() {});
        // print(value);
      });
    } on SocketException catch (_) {
      SnackBar mysnackbar = const SnackBar(
        content: Text('Internet not Connected'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(mysnackbar);
      setState(() {});
    }
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });
    //var
    fetchResponse(_image);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      _loading = false;
    });
    fetchResponse(_image);

    //var
  }

  Future<Map<String, dynamic>?> fetchResponse(File image) async {
    // final mimeTypeData =
    //     lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

    // final imageUploadRequest = http.MultipartRequest(
    //     'POST',
    //     Uri.parse(
    //         'https://max-image-caption-generator-neelambaran-cs21-dev.apps.sandbox-m4.g2pi.p1.openshiftapps.com/model/predict'));

    // final file = await http.MultipartFile.fromPath('image', image.path,
    //     contentType: MediaType(mimeTypeData![0], mimeTypeData[1]));

    // imageUploadRequest.fields['ext'] = mimeTypeData[1];
    // imageUploadRequest.files.add(file);

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
    print(response.body);

    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> result = json.decode(response.body);
    //   print(result);
    // } else {
    //   throw Exception("Failed to query the API");
    // }

    try {
      List<dynamic> jsonList = json.decode(response.body);
      print(jsonList.toString());
      String generatedText = '';
      for (var jsonItem in jsonList) {
        // Access the "generated_text" field in each JSON object
        generatedText = jsonItem['generated_text'];
        print(generatedText);
        // translate(generatedText);
      }
      parseResponse(generatedText);
      // await flutterTts.speak(generatedText);
      message = generatedText;

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
              colors: [Color(0x11232526), Color(0xFF2322526)]),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 70),
              Text(
                "AI CAPTIONS",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              Text(
                'Image Caption Generator',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Container(
                height: MediaQuery.of(context).size.height - 300,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 253, 242, 242),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7),
                    ]),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: _loading
                          ? Container(
                              width: 500,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: 100,
                                    child: Image.asset(
                                      'assets/notepad.png',
                                    ),
                                  ),
                                  SizedBox(height: 50),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            //pickImage();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GenerateLiveCaptions()));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                120,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 17),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Live Camera',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            pickGalleryImage();
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                120,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 17),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Camera Roll',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            pickImage();
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                120,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 17),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Take a Photo',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 28),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      height: 200,
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: IconButton(
                                                icon:
                                                    Icon(Icons.arrow_back_ios),
                                                color: Colors.black,
                                                onPressed: () {
                                                  setState(() {
                                                    _loading = true;
                                                    resultText = "Fetching";
                                                    data = '';
                                                    controller.text = '';
                                                  });
                                                },
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  205,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  _image,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            )
                                          ]),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      child: Text(
                                        resultText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                if (resultText != "Fetching")
                                  CustomDropdown(
                                    controller: controller,
                                    hintText: "Choose any Language",
                                    // value: selectedvalue,
                                    // focusColor: Colors.transparent,
                                    items: languages,
                                    // languages.map((lang) {
                                    //   return DropdownMenuItem(
                                    //     value: lang,
                                    //     child: Text(lang),
                                    //     onTap: () {
                                    //       if (lang == languages[0]) {
                                    //         from = languagescode[0];
                                    //       } else if (lang == languages[1]) {
                                    //         from = languagescode[1];
                                    //       } else if (lang == languages[2]) {
                                    //         from = languagescode[2];
                                    //       } else if (lang == languages[3]) {
                                    //         from = languagescode[3];
                                    //       } else if (lang == languages[4]) {
                                    //         from = languagescode[4];
                                    //       } else if (lang == languages[5]) {
                                    //         from = languagescode[5];
                                    //       } else if (lang == languages[6]) {
                                    //         from = languagescode[6];
                                    //       } else if (lang == languages[7]) {
                                    //         from = languagescode[7];
                                    //       } else if (lang == languages[8]) {
                                    //         from = languagescode[8];
                                    //       }
                                    //       setState(() {
                                    //         // print(lang);
                                    //         // print(from);
                                    //       });
                                    //     },
                                    //   );
                                    // }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedvalue = value;
                                        if (value == 'Japanese' ||
                                            value == 'Urdu' ||
                                            value == 'Arabic') {
                                          hideRepeat = true;
                                        }
                                        var index = languages.indexOf(value);
                                        to = languagescode[index];
                                        translate(message);
                                      });
                                    },
                                  ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: Text(
                                    data,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                if (resultText != "Fetching" && hideRepeat)
                                  InkWell(
                                    onTap: () async {
                                      List<dynamic> languages =
                                          await flutterTts.getLanguages;
                                      print(selectedvalue);
                                      // print(speechCode[
                                      //     languages.indexOf(selectedvalue)]);

                                      // await flutterTts.setLanguage();
                                      await flutterTts.speak(data);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 35, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        "Voice",
                                        style: TextStyle(
                                            fontSize: 19,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
