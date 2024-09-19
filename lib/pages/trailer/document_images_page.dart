import 'package:flutter/material.dart';

class DocumentImagesPage extends StatelessWidget {
  final List<String> imageUrls;

  const DocumentImagesPage({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Документы'),
        ),
        body: const Center(
          child: Text('Нет доступных документов.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Документы'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: imageUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Adjust as needed
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return GestureDetector(
            onTap: () {
              _showFullImage(context, imageUrl);
            },
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImagePage(imageUrl: imageUrl),
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final String imageUrl;

  const FullImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Изображение'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
