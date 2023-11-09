import 'dart:io';

import 'package:docscanneredgedemo/components/custom_button.dart';
import 'package:docscanneredgedemo/components/custom_snackbar.dart';
import 'package:docscanneredgedemo/viewmodel/homeview_model.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeView({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool showActionButtons = false;
  String? _imagePath;
  @override
  void initState() {
    super.initState();
    widget.viewModel.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Document Scanner by MehdiNathani'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  onPressed: () async {
                    String? imagePath =
                        await widget.viewModel.getImageFromCamera();
                    if (imagePath != null) {
                      showActionButtons = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Success: $imagePath"),
                        ),
                      );
                      setState(() {
                        _imagePath = imagePath;
                      });
                    }
                  },
                  buttonText: "Scan",
                  buttonicon: Icons.camera_alt,
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomButton(
                  onPressed: () async {
                    String? imagePath =
                        await widget.viewModel.getImageFromGallery();
                    if (imagePath != null) {
                      showActionButtons = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Success: $imagePath"),
                        ),
                      );
                      setState(() {
                        _imagePath = imagePath;
                      });
                    }
                  },
                  buttonText: "Upload from Gallery",
                  buttonicon: Icons.upload_file_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: showActionButtons,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    buttonText: "Share",
                    buttonicon: Icons.share,
                    onPressed: () async {
                      await widget.viewModel.shareImage();
                      if (widget.viewModel.shareSuccess) {
                        SnackBarWidget.showSnackBar(
                            context, "Image Shared Successfully.");
                      }
                    },
                  ),
                  CustomButton(
                    buttonicon: Icons.save_alt_outlined,
                    buttonText: "Save to Gallery",
                    onPressed: () async {
                      await widget.viewModel.saveImage();
                      if (widget.viewModel.saveSuccess) {
                        SnackBarWidget.showSnackBar(
                            context, 'Image saved successfully');
                      }
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cropped image path:',
              style: TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Text(
                _imagePath.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Visibility(
                  visible: _imagePath != null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(_imagePath ?? ''),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await widget.viewModel.shareTheApp();
                      if (widget.viewModel.appShared) {
                        SnackBarWidget.showSnackBar(
                            context, 'Thank you for sharing!');
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("Share this App with your friends.",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Copy rights reserved by mehdinathani 2023",
                    style: TextStyle(color: Colors.white),
                  ),
                  Divider(color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
