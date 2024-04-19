import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: "HELLO"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;


  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // File _image = File('images/bg.jpg');
  File? _image;
  List _recognitions = [];
  double _imageHeight = 0;
  double _imageWidth = 0;
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    loadModel();
    imagePicker = ImagePicker();
  }


  // Choose image from camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      predictImage(image);
    } else {
      // Handle the case when the user cancels image picking
      if (kDebugMode) {
        print('User canceled image picking');
      }
    }
  }

  _imgFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      predictImage(image);
    } else {
      // Handle the case when the user cancels image picking
      if (kDebugMode) {
        print('User canceled image picking');
      }
    }
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String? res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
        // useGpuDelegate: true,
      );
      if (kDebugMode) {
        print(res);
      }
    } on PlatformException {
      if (kDebugMode) {
        print('Failed to load model.');
      }
    }
  }

  Future predictImage(File image) async {
    poseNet(image);

    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));
    setState(() {
      _image = image;
    });
  }

  Future poseNet(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 2,
    );

    if (kDebugMode) {
      print(recognitions);
    }

    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = DateTime.now().millisecondsSinceEpoch;
    if (kDebugMode) {
      print("Inference took ${endTime - startTime}ms");
    }
  }

  List<Widget> renderKeypoints(Size screen) {
    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    for (var re in _recognitions) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() | 0xFF000000);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      lists.addAll(list);
    }

    return lists;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Center(child: Container(margin:EdgeInsets.only(top:size.height/2-140),child: const Icon(Icons.image_rounded,color: Colors.white,size: 100,))) : Image.file(_image!),
    ));
    stackChildren.addAll(renderKeypoints(size));
    stackChildren.add(
      Container(
        height: size.height,
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _imgFromCamera,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Icon(
                  Icons.camera,
                  color: Colors.black,
                ),
              ),
              ElevatedButton(
                onPressed: _imgFromGallery,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Icon(
                  Icons.image,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.only(top: 50),
        color: Colors.black,
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}












// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:tflite/tflite.dart';
// import 'package:image_picker/image_picker.dart';
//
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: MyHomePage(title: "HELLO"),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//
//   @override
//   MyHomePageState createState() => MyHomePageState();
// }
//
// class MyHomePageState extends State<MyHomePage> {
//   late File _image;
//   late List _recognitions;
//   late double _imageHeight;
//   late double _imageWidth;
//   late ImagePicker imagePicker;
//
//   @override
//   void initState() {
//     super.initState();
//     loadModel();
//     imagePicker = ImagePicker();
//   }
//
//   // Choose image from camera
//   _imgFromCamera() async {
//     PickedFile? pickedFile = (await imagePicker.pickImage(source: ImageSource.camera)) as PickedFile?;
//     if (pickedFile != null) {
//       File image = File(pickedFile.path);
//       predictImage(image);
//     }
//   }
//
//   // Choose image from gallery
//   _imgFromGallery() async {
//     PickedFile? pickedFile = (await imagePicker.pickImage(source: ImageSource.gallery)) as PickedFile?;
//     if (pickedFile != null) {
//       File image = File(pickedFile.path);
//       predictImage(image);
//     }
//   }
//
//   Future loadModel() async {
//     Tflite.close();
//     try {
//       String? res = await Tflite.loadModel(
//         model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
//         // useGpuDelegate: true,
//       );
//       if (kDebugMode) {
//         print(res);
//       }
//     } on PlatformException {
//       if (kDebugMode) {
//         print('Failed to load model.');
//       }
//     }
//   }
//
//   Future predictImage(File image) async {
//     poseNet(image);
//
//     FileImage(image)
//         .resolve(const ImageConfiguration())
//         .addListener(ImageStreamListener((ImageInfo info, bool _) {
//       setState(() {
//         _imageHeight = info.image.height.toDouble();
//         _imageWidth = info.image.width.toDouble();
//       });
//     }));
//     setState(() {
//       _image = image;
//     });
//   }
//
//   Future poseNet(File image) async {
//     int startTime = DateTime.now().millisecondsSinceEpoch;
//     var recognitions = await Tflite.runPoseNetOnImage(
//       path: image.path,
//       numResults: 2,
//     );
//
//     if (kDebugMode) {
//       print(recognitions);
//     }
//
//     setState(() {
//       _recognitions = recognitions!;
//     });
//     int endTime = DateTime.now().millisecondsSinceEpoch;
//     if (kDebugMode) {
//       print("Inference took ${endTime - startTime}ms");
//     }
//   }
//
//   List<Widget> renderKeypoints(Size screen) {
//     double factorX = screen.width;
//     double factorY = _imageHeight / _imageWidth * screen.width;
//
//     var lists = <Widget>[];
//     for (var re in _recognitions) {
//       var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() | 0xFF000000);
//       var list = re["keypoints"].values.map<Widget>((k) {
//         return Positioned(
//           left: k["x"] * factorX - 6,
//           top: k["y"] * factorY - 6,
//           width: 100,
//           height: 12,
//           child: Text(
//             "● ${k["part"]}",
//             style: TextStyle(
//               color: color,
//               fontSize: 12.0,
//             ),
//           ),
//         );
//       }).toList();
//
//       lists.addAll(list);
//     }
//
//     return lists;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     List<Widget> stackChildren = [];
//
//     stackChildren.add(Positioned(
//       top: 0.0,
//       left: 0.0,
//       width: size.width,
//       child: null == _image ? Center(child: Container(margin:EdgeInsets.only(top:size.height/2-140),child: const Icon(Icons.image_rounded,color: Colors.white,size: 100,))) : Image.file(_image),
//     ));
//     stackChildren.addAll(renderKeypoints(size));
//     stackChildren.add(
//       Container(
//         height: size.height,
//         alignment: Alignment.bottomCenter,
//         child: Container(
//           color: Colors.white,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: _imgFromCamera,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                 child: const Icon(
//                   Icons.camera,
//                   color: Colors.black,
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _imgFromGallery,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                 child: const Icon(
//                   Icons.image,
//                   color: Colors.black,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Container(
//         margin: const EdgeInsets.only(top: 50),
//         color: Colors.black,
//         child: Stack(
//           children: stackChildren,
//         ),
//       ),
//     );
//   }
// }
//












// // import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Demo'),
//         ),
//         body: const Center(
//           child: Text(
//             'Hello, Flutter!',
//             style: TextStyle(fontSize: 24.0),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
