// import 'package:flutter/material.dart';
// import 'image_grid_widget.dart';

// class ExpandableImageGrid extends StatefulWidget {
//   final List<String> imageUrls;
//   final String buttonText;

//   const ExpandableImageGrid({
//     super.key,
//     required this.imageUrls,
//     this.buttonText = 'Просмотреть документы',
//   });

//   @override
//   State<ExpandableImageGrid> createState() => _ExpandableImageGridState();
// }

// class _ExpandableImageGridState extends State<ExpandableImageGrid>
//     with SingleTickerProviderStateMixin {
//   bool _showImages = false;
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize the AnimationController
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );

//     // Set the initial state of the animation based on _showImages
//     if (_showImages) {
//       _animationController.value = 1.0;
//     }
//   }

//   @override
//   void dispose() {
//     // Dispose the AnimationController to free up resources
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _toggleExpand() {
//     setState(() {
//       _showImages = !_showImages;
//       if (_showImages) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Button to expand/collapse the image grid
//         TextButton(
//           onPressed: _toggleExpand,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Button text
//               Text(
//                 widget.buttonText,
//                 style: const TextStyle(
//                   color: Colors.blue,
//                   fontSize: 18,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // Rotating arrow icon
//               RotationTransition(
//                 turns: _animationController.drive(
//                   Tween(begin: 0.0, end: 0.5),
//                 ),
//                 child: const Icon(
//                   Icons.expand_more,
//                   color: Colors.blue,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Animated expansion/collapse of the image grid
//         SizeTransition(
//           sizeFactor: _animationController,
//           axisAlignment: -1.0,
//           child: widget.imageUrls.isNotEmpty
//               ? ImageGridWidget(imageUrls: widget.imageUrls)
//               : const Text('Нет доступных документов.'),
//         ),
//       ],
//     );
//   }
// }

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
