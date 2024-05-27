import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ImagePickerDemo extends StatefulWidget {
  const ImagePickerDemo({super.key});

  @override
  State<ImagePickerDemo> createState() => _ImagePickerDemoState();
}

class _ImagePickerDemoState extends State<ImagePickerDemo> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";

  loadmodel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectImage(file!);
    } catch (e) {
      print("error is ${e.toString()}");
    }
  }

  Future detectImage(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 1,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();
    });

    print("/////////////////");
    print(recognitions);
    int endtime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endtime - startTime}");
  }

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Tflite"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              const Text("No image is selected"),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  _pickImage();
                }, child: const Text("Pick image from gallery")),
            const SizedBox(
              height: 20,
            ),
            Text(v)
          ],
        ),
      ),
    );
  }
}
