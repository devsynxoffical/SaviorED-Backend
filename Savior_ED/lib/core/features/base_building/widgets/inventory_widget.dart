import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../viewmodels/base_building_viewmodel.dart';
import '../models/level_requirements_model.dart';
import '../utils/asset_helper.dart';
import '../config/building_cost_config.dart'; // Import cost config

class InventoryWidget extends StatelessWidget {
  final VoidCallback? onClose;
  const InventoryWidget({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<BaseBuildingViewModel>(
      builder: (context, viewModel, child) {
        final requirements =
            viewModel.currentLevelConfig.requirements.requiredItems;

        return SizedBox(
          height: 180, // Fixed height to prevent overflow in landscape
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6), // Transparent Dark
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header / Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5),
                    itemCount: requirements.length,
                    itemBuilder: (context, index) {
                      final req = requirements[index];
                      return _buildInventoryItem(context, req, viewModel);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryItem(
    BuildContext context,
    ItemRequirement requirement,
    BaseBuildingViewModel viewModel,
  ) {
    final currentCount =
        viewModel.levelProgress?.placedItems[requirement.itemTemplateId] ?? 0;
    final totalRequired = requirement.quantity;
    final isMaxed = currentCount >= totalRequired;

    return GestureDetector(
      onTap: isMaxed
          ? null
          : () {
              viewModel.startPlacementMode(requirement.itemTemplateId);
              if (onClose != null) onClose!();
            },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isMaxed ? Colors.red.withOpacity(0.3) : Colors.white24,
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Transform.flip(
                    flipX: viewModel.isFlippedGlobal,
                    child: Image.asset(
                      AssetHelper.getAssetPath(requirement.itemTemplateId),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMaxed ? 'MAX' : '$currentCount/$totalRequired',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isMaxed ? Colors.redAccent : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isMaxed) _buildCostRow(requirement.itemTemplateId),
              ],
            ),
            if (isMaxed)
              const Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.lock, color: Colors.white24, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String templateId) {
    final cost = BuildingCostConfig.getCost(templateId);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cost.wood > 0) ...[
            Icon(Icons.forest, size: 10, color: Colors.brown[300]),
            const SizedBox(width: 2),
            Text(
              '${cost.wood}',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (cost.stone > 0) ...[
            Icon(Icons.construction, size: 10, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              '${cost.stone}',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (cost.coins > 0) ...[
            const Icon(Icons.monetization_on, size: 10, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              '${cost.coins}',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
