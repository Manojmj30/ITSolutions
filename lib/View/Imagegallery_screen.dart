

import 'package:provider/provider.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';


import '../Model/Pixabay_model.dart';
import '../Provider/Provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';







class ImageGalleryScreen extends StatefulWidget {
  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<PixabayProvider>(context, listen: false);
    provider.fetchImages();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          provider.hasMore) {
        provider.fetchImages();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<PixabayProvider>(context, listen: false);
      provider.fetchImages(newQuery: _searchController.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PixabayProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Image Gallery'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Search',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5,0,5,0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.of(context).size.width / 150).floor(),
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1,
                ),
                itemCount: provider.images.length + (provider.hasMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == provider.images.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ImageTile(image: provider.images[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );

  }
}

class ImageTile extends StatelessWidget {
  final PixabayImage image;

  const ImageTile({required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => FullScreenImage(imageUrl: image.imageUrl),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(3,3,3,0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                 borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7.0,horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_off_alt_sharp,color: Colors.grey,size:15),
                        const SizedBox(width:5),
                        Text('${image.likes}', overflow: TextOverflow.ellipsis,style: const TextStyle(color: Colors.grey,fontSize: 10,fontWeight: FontWeight.bold)),
                      ],
                    ),

                    Row(
                      children: [
                        const Icon(Icons.visibility,color: Colors.grey,size:15),
                        const SizedBox(width:5),
                        Text('${image.views}', overflow: TextOverflow.ellipsis,style: const TextStyle(color: Colors.grey,fontSize: 10,fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: imageUrl,
            child: CachedNetworkImage(imageUrl: imageUrl),
          ),
        ),
      ),
    );
  }
}

