import 'dart:io';
import 'dart:typed_data';

import 'package:camera_gallery_image_picker/camera_gallery_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeViewModel {
  String? _imagePath;
  String? _pdfPath;
  BuildContext context;
  bool shareSuccess = false;
  bool saveSuccess = false;
  bool appShared = false;
  List<Asset> selectedImages = [];

  HomeViewModel(this.context);

  Future<void> init(BuildContext context) async {
    this.context = context;
  }

  Future<String?> getImageFromCamera() async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      // Have not permission to camera
      return null;
    }

    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool success = false;

    try {
      success = await EdgeDetection.detectEdge(
        imagePath,
        canUseGallery: true,
        androidScanTitle: 'Scanning',
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    if (success) {
      _imagePath = imagePath;
      return imagePath;
    } else {
      return null;
    }
  }

  Future<String?> getImageFromGallery() async {
    String imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    bool success = false;
    try {
      success = await EdgeDetection.detectEdgeFromGallery(
        imagePath,
        androidCropTitle: 'Crop', // use custom localizations for android
        androidCropBlackWhiteTitle: 'Black White',
        androidCropReset: 'Reset',
      );
      debugPrint("success: $success");
    } catch (e) {
      debugPrint(e.toString());
    }

    if (success) {
      _imagePath = imagePath;
      return imagePath;
    } else {
      return null;
    }
  }

  Future<void> shareImage() async {
    if (_imagePath != null) {
      final result = await Share.shareFilesWithResult([_imagePath!],
          text: 'Check out this image!');
      if (result.status == ShareResultStatus.success) {
        shareSuccess = true;
      }
      // await Share.shareFiles([_imagePath!], text: 'Check out this image!');
    }
  }

  Future<void> saveImage() async {
    if (_imagePath != null) {
      final result = await ImageGallerySaver.saveFile(_imagePath!);
      if (result['isSuccess']) {
        saveSuccess = true;
      }
    }
  }

  Future<void> shareTheApp() async {
    final result = await Share.shareWithResult(
        'check out the great app from mehdinathani');

    if (result.status == ShareResultStatus.success) {
      debugPrint('Thank you for sharing!');
      appShared = true;
    }
  }

  Future<void> convertImageToPDF() async {
    final imagePath = _imagePath!;
    final pdfPath = imagePath.replaceAll('.jpeg', '.pdf');

    final pdf = pw.Document();

    // Read image bytes from file
    final imageBytes = File(imagePath).readAsBytesSync();

    // Create a pw.MemoryImage from image bytes
    final image = pw.MemoryImage(imageBytes);

    // Add a page to the PDF with the image
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    // Save the PDF to a Uint8List
    final Uint8List pdfBytes = await pdf.save();

    // Write the Uint8List to the file
    final File file = File(pdfPath);
    await file.writeAsBytes(pdfBytes);

    debugPrint('PDF generated successfully at ${file.path}');
    _pdfPath = file.path;
  }

  Future<void> sharePDF() async {
    await convertImageToPDF();
    if (_pdfPath != null) {
      final result = await Share.shareFilesWithResult([_pdfPath!],
          text: 'Check out this image!');
      if (result.status == ShareResultStatus.success) {
        shareSuccess = true;
      }
    }
  }

  Future<List<String>?> getImagesFromCameraMulti() async {
    List<String> imagePaths = [];

    // Loop to capture images using the edge detection
    while (true) {
      String? imagePath =
          await getImageFromCamera(); // Function to capture single image using edge detection
      if (imagePath != null) {
        imagePaths.add(imagePath);
      } else {
        break; // Break the loop if there's an issue or the user stops capturing images
      }
    }

    if (imagePaths.isNotEmpty) {
      return imagePaths;
    } else {
      return null; // Handle if there are no captured images
    }
  }

  // Future<List<String>?> getImagesFromGalleryMulti() async {
  //   List<File> multipleImageFiles =
  //       await CameraGalleryImagePicker.pickMultiImage();

  //   if (multipleImageFiles.isNotEmpty) {
  //     return multipleImageFiles.map((file) => file.path).toList();
  //   } else {
  //     return null;
  //   }
  // }

  Future<List<String>?> getImagesFromGalleryMulti() async {
    List<String> imagePaths = [];

    // Loop to capture images using the edge detection
    while (true) {
      String? imagePath =
          await getImageFromGallery(); // Function to capture single image using edge detection
      if (imagePath != null) {
        imagePaths.add(imagePath);
      } else {
        break; // Break the loop if there's an issue or the user stops capturing images
      }
    }

    if (imagePaths.isNotEmpty) {
      return imagePaths;
    } else {
      return null; // Handle if there are no captured images
    }
  }

  Future<void> shareImagesMulti(List<String> imagePaths) async {
    for (var imagePath in imagePaths) {
      if (imagePath != null) {
        final result = await Share.shareFiles(imagePaths,
            text: "Shared using Doument Scanner by mehdinathani");
        // text: 'Check out this image!');
        // if (result.status == ShareResultStatus.success) {
        //   // You might need to handle individual image share success here
        // }
      }
    }
  }

  Future<void> saveImageMulti(List<String> imagePaths) async {
    for (var imagePath in imagePaths) {
      final result = await ImageGallerySaver.saveFile(imagePath);
      if (result['isSuccess']) {
        saveSuccess = true; // Consider handling success for each image here
      }
    }
  }

  Future<String?> convertImagesToSinglePDF(List<String> imagePaths) async {
    if (imagePaths.isEmpty) {
      return null; // Handle an empty list
    }

    final pdf = pw.Document();

    for (var imagePath in imagePaths) {
      final imageBytes = File(imagePath).readAsBytesSync();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    final pdfPath = imagePaths.first.replaceAll(
        '.jpeg', '.pdf'); // Define a single file path for the combined PDF

    final pdfBytes = await pdf.save();
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(pdfBytes);

    debugPrint('Combined PDF generated successfully at ${pdfFile.path}');
    return pdfFile.path;
  }

  Future<void> shareSinglePDF(List<String> imagePaths) async {
    _pdfPath = await convertImagesToSinglePDF(imagePaths);
    if (_pdfPath != null) {
      final result = await Share.shareFilesWithResult([_pdfPath!],
          text: 'Check out this PDF!');
      if (result.status == ShareResultStatus.success) {
        shareSuccess = true;
      }
    }
  }
}
