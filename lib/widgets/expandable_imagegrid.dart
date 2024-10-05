import 'package:flutter/material.dart';
import 'image_grid_widget.dart';

class ExpandableImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final String title;

  const ExpandableImageGrid({
    super.key,
    required this.imageUrls,
    this.title = 'Просмотреть документы',
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 16.0),
      children: [
        imageUrls.isNotEmpty
            ? ImageGridWidget(imageUrls: imageUrls)
            : const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Нет доступных документов.'),
              ),
      ],
    );
  }
}
