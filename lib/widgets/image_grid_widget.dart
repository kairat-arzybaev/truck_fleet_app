import 'package:flutter/material.dart';

import 'full_image_page.dart';

class ImageGridWidget extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final void Function(String imageUrl)? onImageTap;

  const ImageGridWidget({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 3,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding = const EdgeInsets.all(8.0),
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: imageUrls.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];
        return GestureDetector(
          onTap: () {
            if (onImageTap != null) {
              onImageTap!(imageUrl);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullImagePage(imageUrl: imageUrl),
                ),
              );
            }
          },
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
