import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/placed_item_model.dart';
import '../utils/asset_helper.dart';

/// Widget for displaying placed items on the isometric grid
class PlacedItemWidget extends StatelessWidget {
  final PlacedItemModel item;
  final double cellSize;

  const PlacedItemWidget({
    super.key,
    required this.item,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    // Convert grid coordinates to isometric screen coordinates
    // Note: This logic might differ from BaseBuildingView's internal rendering
    // base_building_view.dart seems to use its own Positioned logic.
    final centerX = MediaQuery.of(context).size.width / 2;
    final centerY = MediaQuery.of(context).size.height / 2;

    final isoX =
        (item.gridX - 20) * cellSize; // Assuming 40x40 grid, offset by 20
    final isoY = (item.gridY - 20) * cellSize;

    final screenX = centerX + isoX;
    final screenY = centerY + isoY;

    // Get image path from AssetHelper
    String imagePath = AssetHelper.getAssetPath(item.itemId);

    return Positioned(
      left: screenX,
      top: screenY,
      child: Transform.rotate(
        angle:
            0.0, // Isometric doesn't usually use standard 2D rotation for the sprite itself
        child: GestureDetector(
          onTap: () {
            // Options are usually handled in BaseBuildingView
          },
          child: Container(
            width: cellSize * 2, // Approximate scaling
            height: cellSize * 2,
            alignment: Alignment.bottomCenter,
            child: Transform.flip(
              flipX: item.isFlipped,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
