import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      await _sendImageToServer(_imageFile!);
    }
  }

  Future<void> _sendImageToServer(File image) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.43.247:5000/process_image'));

    var file = await http.MultipartFile.fromPath(
      "image",
      image.path,
    );
    // request.files
    //     .add(await http.MultipartFile.fromPath('image', image.path));
    // print(image.path);
    try {
      request.files.add(file);
      var response = await request.send();
      print('respppppppppppppppppppppppppppppppppppppppppppppppppp');
      if (response.statusCode == 200) {
        print('Server Response: ${await response.stream.bytesToString()}');
      } else {
        print('Error: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                : Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: Text('Take Picture'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: Text('Select from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
