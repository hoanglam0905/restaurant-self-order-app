import 'package:flutter/material.dart';

class AppImageWithFallback extends StatelessWidget {
  const AppImageWithFallback({
    required this.fallbackAsset,
    this.imageUrl,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String fallbackAsset;
  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(fallbackAsset, fit: fit);
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      errorBuilder: (_, _, _) => Image.asset(fallbackAsset, fit: fit),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
}
