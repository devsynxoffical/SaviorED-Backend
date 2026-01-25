import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../viewmodels/base_building_viewmodel.dart';
import '../models/level_requirements_model.dart';
import '../utils/asset_helper.dart';
import '../config/building_cost_config.dart'; // Import cost config
import '../../castle_grounds/viewmodels/castle_grounds_viewmodel.dart';

class InventoryWidget extends StatelessWidget {
  final VoidCallback? onClose;
  const InventoryWidget({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<BaseBuildingViewModel>(
      builder: (context, viewModel, child) {
        final requirements =
            viewModel.currentLevelConfig.requirements.requiredItems;

        return Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.95),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              // Header / Drag Handle
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5),
                  itemCount: requirements.length,
                  itemBuilder: (context, index) {
                    final req = requirements[index];
                    return _buildInventoryItem(context, req, viewModel);
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
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
    final templateId = requirement.itemTemplateId;

    return GestureDetector(
      onTap: isMaxed
          ? null
          : () {
              viewModel.startPlacementMode(templateId);
              if (onClose != null) onClose!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: isMaxed ? Colors.black26 : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMaxed ? Colors.redAccent.withOpacity(0.2) : Colors.white24,
            width: 1.5,
          ),
          boxShadow: isMaxed
              ? []
              : [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Item Image
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Transform.flip(
                        flipX: viewModel.isFlippedGlobal,
                        child: Image.asset(
                          AssetHelper.getAssetPath(templateId),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Progress Text
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      isMaxed ? 'COMPLETED' : '$currentCount / $totalRequired',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isMaxed ? Colors.redAccent : Colors.white70,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Cost Row or Stock Indicator
                  _buildPriceOrStock(context, templateId, isMaxed),
                  const SizedBox(height: 8),
                ],
              ),

              // Lock Overlay
              if (isMaxed)
                Positioned.fill(
                  child: Container(
                    color: Colors.black38,
                    child: Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent.withOpacity(0.5),
                        size: 30,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceOrStock(
    BuildContext context,
    String templateId,
    bool isMaxed,
  ) {
    if (isMaxed) return const SizedBox.shrink();

    final castleViewModel = Provider.of<CastleGroundsViewModel>(
      context,
      listen: false,
    );
    final inStock = castleViewModel.castle?.inventory[templateId] ?? 0;

    if (inStock > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        ),
        child: Text(
          'OWNED',
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return _buildCostRow(templateId);
  }

  Widget _buildCostRow(String templateId) {
    final cost = BuildingCostConfig.getCost(templateId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cost.wood > 0)
            _costChip(Icons.forest, '${cost.wood}', Colors.brown[300]!),
          if (cost.stone > 0) ...[
            if (cost.wood > 0) const SizedBox(width: 6),
            _costChip(Icons.landscape, '${cost.stone}', Colors.grey[400]!),
          ],
          if (cost.coins > 0) ...[
            if (cost.stone > 0 || cost.wood > 0) const SizedBox(width: 6),
            _costChip(Icons.monetization_on, '${cost.coins}', Colors.amber),
          ],
          if (cost.isFree)
            Text(
              'FREE',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _costChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
