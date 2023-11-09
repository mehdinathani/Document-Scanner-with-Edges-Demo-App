import 'package:docscanneredgedemo/screens/home_view.dart';
import 'package:docscanneredgedemo/viewmodel/homeview_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      title: "Document Scanner App By MehdiNathani",
      home: HomeView(
        viewModel: HomeViewModel(context),
      ),
    );
  }
}
