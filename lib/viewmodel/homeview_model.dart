import 'package:docscanneredgedemo/components/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class HomeViewModel {
  String? _imagePath;
  BuildContext context;
  bool shareSuccess = false;
  bool saveSuccess = false;
  bool appShared = false;

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
}
