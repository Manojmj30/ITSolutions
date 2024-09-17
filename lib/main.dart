import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Provider/Provider.dart';
import 'View/Imagegallery_screen.dart';



void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PixabayProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ImageGalleryScreen(),
      ),
    );
  }
}

