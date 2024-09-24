import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TestFile extends StatelessWidget {
  const TestFile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedNetworkImage(
        imageUrl:
            'https://images.unsplash.com/photo-1532264523420-881a47db012d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9',
        height: 200,
        width: 200,
        key: UniqueKey(),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
