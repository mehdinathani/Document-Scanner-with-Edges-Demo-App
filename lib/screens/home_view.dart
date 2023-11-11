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
  List<String> _imagePaths = [];
  bool showActionButtons = false;
  String? _imagePath;
  late bool isMultipleImages;

  @override
  void initState() {
    super.initState();
    isMultipleImages = false;
    widget.viewModel.init(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget displayImages() {
      if (isMultipleImages) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _imagePaths.length,
          itemBuilder: (context, index) {
            return Image.file(
                File(_imagePaths[index])); // Displaying each image
          },
        );
      } else {
        return _imagePath != null
            ? Image.file(File(_imagePath!)) // Displaying the single image
            : Container(); // Placeholder or empty container if no image to show
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Document Scanner by MehdiNathani'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  onPressed: () async {
                    if (isMultipleImages) {
                      List<String>? imagePath =
                          await widget.viewModel.getImagesFromCameraMulti();
                      if (imagePath != null) {
                        showActionButtons = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Success: $imagePath"),
                          ),
                        );
                        setState(() {
                          _imagePaths.addAll(imagePath);
                          _imagePath = imagePath.first;
                        });
                      }
                    } else {
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
                    if (isMultipleImages) {
                      List<String>? imagePath =
                          await widget.viewModel.getImagesFromGalleryMulti();
                      if (imagePath != null) {
                        showActionButtons = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Success: $imagePath"),
                          ),
                        );
                        setState(() {
                          _imagePaths.addAll(imagePath);
                          _imagePath = imagePath.first;
                        });
                      }
                    } else {
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
              child: Column(
                children: [
                  Row(
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
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                          onPressed: () async {
                            await widget.viewModel.convertImageToPDF();
                          },
                          buttonicon: Icons.picture_as_pdf,
                          buttonText: "Save as PDF"),
                      CustomButton(
                        onPressed: () async {
                          await widget.viewModel.sharePDF();
                        },
                        buttonicon: Icons.share,
                        buttonText: "Share as PDF",
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white,
                  value: isMultipleImages,
                  onChanged: (value) {
                    setState(() {
                      isMultipleImages = value;
                      debugPrint(
                        isMultipleImages
                            ? "Multi Image Selection Enabled"
                            : "Multi Image Selection Disabled",
                      );
                    });
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(
                  isMultipleImages
                      ? "Multi Image Selection Enabled"
                      : "Multi Image Selection Disabled",
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 20),
            const Visibility(
              visible: false,
              child: Text(
                'Cropped image path:',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Visibility(
              visible: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                child: Text(
                  _imagePath.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Visibility(
                  visible: _imagePath != null,
                  child: isMultipleImages
                      ? displayImages() // Displays the list of images
                      : Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white)),
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            File(_imagePath ?? ''),
                          ),
                        ),
                ),
              ),
            ),
            // Expanded(
            //   child: SingleChildScrollView(
            //     child: Visibility(
            //       visible: _imagePath != null,
            //       child:  Container(

            //         decoration:
            //             BoxDecoration(border: Border.all(color: Colors.white)),
            //         padding: const EdgeInsets.all(8.0),
            //         child: Image.file(
            //           File(_imagePath ?? ''),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
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
                    child: const Row(
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
                  const SizedBox(
                    height: 20,
                  ),
                  const Center(
                    child: Text(
                      "Copyright © 2023 Mehdi Nathani. All rights reserved.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
