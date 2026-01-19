import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../viewmodels/base_building_viewmodel.dart';
import '../widgets/isometric_grid.dart';
import '../widgets/inventory_widget.dart';
import '../models/placed_item_model.dart';
import '../utils/asset_helper.dart';
import '../../authentication/viewmodels/auth_viewmodel.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../inventory/viewmodels/inventory_viewmodel.dart';
import '../../castle_grounds/viewmodels/castle_grounds_viewmodel.dart';
import '../../base_building/config/building_cost_config.dart';
import '../models/resource_cost_model.dart';

import 'dart:math' as math; // For random decorations

/// Base Building View - Isometric 2.5D
class BaseBuildingView extends StatefulWidget {
  const BaseBuildingView({super.key});

  @override
  State<BaseBuildingView> createState() => _BaseBuildingViewState();
}

class _BaseBuildingViewState extends State<BaseBuildingView> {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _mapAreaKey = GlobalKey();
  bool _isInventoryOpen = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<BaseBuildingViewModel>(
        context,
        listen: false,
      );
      final profileViewModel = Provider.of<ProfileViewModel>(
        context,
        listen: false,
      );
      final inventoryViewModel = Provider.of<InventoryViewModel>(
        context,
        listen: false,
      );
      final castleViewModel = Provider.of<CastleGroundsViewModel>(
        context,
        listen: false,
      );

      viewModel.loadBase();
      profileViewModel.loadProfile();
      inventoryViewModel.getInventory();
      castleViewModel.getMyCastle(); // Load fresh resource data

      // Center the view and set initial zoom level
      final size = MediaQuery.of(context).size;
      // Use logical width/height assuming landscape
      final double logicalWidth = math.max(size.width, size.height);
      final double logicalHeight = math.min(size.width, size.height);

      // Calculate padding and sizes
      final double desiredGridWidth = logicalWidth * 1.5;
      final double mapSize = desiredGridWidth + 200;

      // Calculate scale to fit the WHOLE MAP into the screen (letterboxed)
      // We take the minimum of width/height ratios to ensure it fits entirely
      final double scaleX = logicalWidth / mapSize;
      final double scaleY = logicalHeight / mapSize;
      final double fitScale = math.min(scaleX, scaleY);

      // Initial scale is fitScale, so we see everything at start
      final double initialScale = fitScale;

      final double scaledMapSize = mapSize * initialScale;

      // Center based on the scaled map size vs screen size
      final double initialX = (logicalWidth - scaledMapSize) / 2;
      final double initialY = (logicalHeight - scaledMapSize) / 2;

      _transformationController.value = Matrix4.identity()
        ..scale(initialScale, initialScale, 1.0)
        ..setTranslationRaw(initialX, initialY, 0.0);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF689F38,
      ), // Matched to map/decoration layer
      floatingActionButton: Consumer<BaseBuildingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isVisitorMode ||
              viewModel.isPlacementMode ||
              viewModel.selectedPlacedItemId != null ||
              _isInventoryOpen) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => setState(() => _isInventoryOpen = true),
            label: const Text(
              'BUILD',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            icon: const Icon(Icons.handyman),
            backgroundColor: const Color(0xFFE65100),
            foregroundColor: Colors.white,
          );
        },
      ),
      body: Consumer<BaseBuildingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => viewModel.isVisitorMode
                          ? Navigator.pop(context)
                          : viewModel.loadBase(),
                      child: Text(
                        viewModel.isVisitorMode ? "GO BACK" : "RETRY",
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              _build2DView(viewModel),
              if (viewModel.isVisitorMode && viewModel.placedItems.isEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "THIS KINGDOM IS CURRENTLY EMPTY",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              _buildTopBar(viewModel),
              // Controls removed as requested

              // Horizontal Inventory Overlay
              if (_isInventoryOpen && !viewModel.isPlacementMode)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: InventoryWidget(
                    onClose: () => setState(() => _isInventoryOpen = false),
                  ),
                ),

              // Building Management Bar (Selected Item) - Hidden in Visitor Mode
              if (viewModel.selectedPlacedItemId != null &&
                  !viewModel.isVisitorMode)
                _buildManagementBar(viewModel),

              if (viewModel.isPlacementMode)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Tap on grid to place",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () => viewModel.cancelPlacementMode(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text("CANCEL"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleMapTap(BaseBuildingViewModel viewModel) {
    if (_isInventoryOpen) {
      setState(() => _isInventoryOpen = false);
    }
    if (viewModel.selectedPlacedItemId != null) {
      viewModel.selectPlacedItem(null);
    }
  }

  Widget _build2DView(BaseBuildingViewModel viewModel) {
    final Size size = MediaQuery.of(context).size;
    final double logicalWidth = math.max(size.width, size.height);
    final double logicalHeight = math.min(size.width, size.height);

    final double desiredGridWidth = logicalWidth * 1.5;
    final double mapSize = desiredGridWidth + 200;

    // Fit Scale: Fits the whole map into the screen bounds
    final double scaleX = logicalWidth / mapSize;
    final double scaleY = logicalHeight / mapSize;
    final double fitScale = math.min(scaleX, scaleY);

    const int gridSize = 40;
    final double cellSize = desiredGridWidth / gridSize;

    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: fitScale,
      maxScale: 4.0,
      // Add margin to allow centering if scaled content is smaller than screen
      boundaryMargin: const EdgeInsets.all(double.infinity),
      constrained: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          _handleMapTap(viewModel);
          _handleTap(details, viewModel, mapSize, cellSize);
        },
        child: DragTarget<Map<String, dynamic>>(
          onMove: (details) {
            _handleDragMove(details, viewModel, mapSize, cellSize);
          },
          onLeave: (data) {
            viewModel.updateDragPreview(null, null, null);
          },
          onAcceptWithDetails: (details) {
            viewModel.updateDragPreview(null, null, null);
            _handleDrop(details, viewModel, mapSize, cellSize);
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              key: _mapAreaKey,
              width: mapSize,
              height: mapSize,
              color: const Color(0xFF689F38),
              alignment: Alignment.center, // CRITICAL: Center contents
              child: Stack(
                alignment: Alignment.center, // CRITICAL: Center stack items
                children: [
                  // 1. Decorations (Trees/Jungle outside grid)
                  ..._buildDecorations(mapSize, 20, desiredGridWidth / 2 + 20),

                  // 2. Playable Grid
                  Center(
                    child: Container(
                      width: gridSize * cellSize,
                      height: gridSize * cellSize,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8BC34A),
                        border: Border.all(
                          color: const Color(0xFF33691E),
                          width: 2,
                        ),
                      ),
                      child: IsometricGrid(
                        gridSize: gridSize,
                        cellSize: cellSize,
                      ),
                    ),
                  ),
                  ...([
                    ...viewModel.placedItems,
                  ]..sort((a, b) => a.gridY.compareTo(b.gridY))).map(
                    (item) =>
                        _buildPlacedItem(item, viewModel, mapSize, cellSize),
                  ),
                  if (viewModel.isPlacementMode && !viewModel.isDragging)
                    _buildPlacementGhost(viewModel, mapSize, cellSize),
                  if (viewModel.isDragging)
                    _buildDragPreviewGhost(viewModel, mapSize, cellSize),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleDragMove(
    DragTargetDetails<Map<String, dynamic>> details,
    BaseBuildingViewModel viewModel,
    double mapSize,
    double cellSize,
  ) {
    final RenderBox? renderBox =
        _mapAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final localPos = renderBox.globalToLocal(details.offset);
    final centerX = mapSize / 2;
    final centerY = mapSize / 2;
    final double dx = localPos.dx - centerX;
    final double dy = localPos.dy - centerY;
    const int gridSize = 40;
    // Dynamic cell size is passed in, so no need to hardcode

    final int gridX = ((dx / cellSize) + gridSize / 2).floor();
    final int gridY = ((dy / cellSize) + gridSize / 2).floor();
    if (gridX >= 0 && gridX < gridSize && gridY >= 0 && gridY < gridSize) {
      final templateId = details.data['templateId'] ?? '';
      final String? itemId = details.data['itemId'];
      final int size = viewModel.getItemSize(templateId);

      // Center the preview on the cursor
      final int topY = gridY - (size / 2).floor();
      final int leftX = gridX - (size / 2).floor();

      viewModel.updateDragPreview(leftX, topY, templateId, excludeId: itemId);
    } else {
      viewModel.updateDragPreview(null, null, null);
    }
  }

  void _handleDrop(
    DragTargetDetails<Map<String, dynamic>> details,
    BaseBuildingViewModel viewModel,
    double mapSize,
    double cellSize,
  ) {
    final RenderBox? renderBox =
        _mapAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final localPos = renderBox.globalToLocal(details.offset);
    final centerX = mapSize / 2;
    final centerY = mapSize / 2;
    final double dx = localPos.dx - centerX;
    final double dy = localPos.dy - centerY;
    const int gridSize = 40;
    final int gridX = ((dx / cellSize) + gridSize / 2).floor();
    final int gridY = ((dy / cellSize) + gridSize / 2).floor();

    if (gridX >= 0 && gridX < gridSize && gridY >= 0 && gridY < gridSize) {
      final data = details.data;
      final templateId = data['templateId'] ?? '';
      final int size = viewModel.getItemSize(templateId);

      // Center placement on dropped cell
      final int topY = gridY - (size / 2).floor();
      final int leftX = gridX - (size / 2).floor();

      if (data['type'] == 'new') {
        final castleViewModel = Provider.of<CastleGroundsViewModel>(
          context,
          listen: false,
        );
        final cost = BuildingCostConfig.getCost(templateId);

        if (cost.isFree) {
          viewModel.placeItem(
            itemType: 'building',
            itemId: templateId,
            gridX: leftX,
            gridY: topY,
          );
        } else {
          // Check & Spend Logic
          castleViewModel
              .spendResources(
                coins: cost.coins,
                wood: cost.wood,
                stone: cost.stone,
              )
              .then((success) {
                if (success) {
                  viewModel.placeItem(
                    itemType: 'building',
                    itemId: templateId,
                    gridX: leftX,
                    gridY: topY,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not enough resources to build!'),
                    ),
                  );
                }
              });
        }
      } else if (data['type'] == 'move') {
        final String itemId = data['itemId'];
        if (!viewModel.isAreaOccupied(leftX, topY, size, excludeId: itemId)) {
          viewModel.updateItem(itemId: itemId, gridX: leftX, gridY: topY);
        }
      }
    }
  }

  Widget _buildPlacedItem(
    PlacedItemModel item,
    BaseBuildingViewModel viewModel,
    double mapSize,
    double cellSize,
  ) {
    final centerX = mapSize / 2;
    final centerY = mapSize / 2;
    const int gridSize = 40;
    final double posX = (item.gridX - gridSize / 2) * cellSize;
    final double posY = (item.gridY - gridSize / 2) * cellSize;
    final int gridScale = item.itemId.contains('gate')
        ? 7
        : (item.itemId.contains('wall') ? 2 : 5);
    final double scaleFactor = item.itemId.contains('wall') ? 2.8 : 1.8;
    final double renderSize = cellSize * (gridScale * scaleFactor);
    final left = centerX + posX + (cellSize * gridScale - renderSize) / 2;
    final top = centerY + posY + (cellSize * gridScale - renderSize) / 2;

    return Positioned(
      left: left,
      top: top,
      child: viewModel.isVisitorMode
          ? GestureDetector(
              onTap: () {
                // Safe selection in visitor mode if we want to show info (but management bar is hidden)
                viewModel.selectPlacedItem(item.id);
              },
              child: Container(
                width: renderSize,
                height: renderSize,
                alignment: Alignment.bottomCenter,
                child: Transform.flip(
                  flipX: item.isFlipped,
                  child: _buildItemImage(item, cellSize),
                ),
              ),
            )
          : Draggable<Map<String, dynamic>>(
              data: {
                'type': 'move',
                'itemId': item.id,
                'templateId': item.itemId,
              },
              dragAnchorStrategy: pointerDragAnchorStrategy,
              onDragStarted: () {
                viewModel.selectPlacedItem(item.id);
                if (_isInventoryOpen) {
                  setState(() => _isInventoryOpen = false);
                }
              },
              feedback: const SizedBox.shrink(),
              childWhenDragging: Opacity(
                opacity: 0.2,
                child: SizedBox(
                  width: renderSize,
                  height: renderSize,
                  child: _buildItemImage(item, cellSize),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  viewModel.selectPlacedItem(item.id);
                  if (_isInventoryOpen) {
                    setState(() => _isInventoryOpen = false);
                  }
                },
                child: Container(
                  width: renderSize,
                  height: renderSize,
                  alignment: Alignment.bottomCenter,
                  child: Transform.flip(
                    flipX: item.isFlipped,
                    child: _buildItemImage(item, cellSize),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPlacementGhost(
    BaseBuildingViewModel viewModel,
    double mapSize,
    double cellSize,
  ) {
    final templateId = viewModel.selectedItemTemplateId ?? '';
    final int gridScale = templateId.contains('gate')
        ? 7
        : (templateId.contains('wall') ? 2 : 5);
    final double scaleFactor = templateId.contains('wall') ? 2.8 : 1.8;
    final double renderSize = cellSize * (gridScale * scaleFactor);
    final centerX = mapSize / 2;
    final centerY = mapSize / 2;

    return Positioned(
      left: centerX - renderSize / 2 + (cellSize * gridScale / 2),
      top: centerY - renderSize / 2 + (cellSize * gridScale / 2),
      child: Draggable<Map<String, dynamic>>(
        data: {'type': 'new', 'templateId': templateId},
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: SizedBox(
          width: renderSize,
          height: renderSize,
          child: Opacity(
            opacity: 0.7,
            child: Transform.flip(
              flipX: viewModel.isFlippedGlobal,
              child: Image.asset(
                AssetHelper.getAssetPath(templateId),
                fit: BoxFit.contain,
                color: const Color(0xFF8BC34A),
                colorBlendMode: BlendMode.multiply,
              ),
            ),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        child: Opacity(
          opacity: 0.5,
          child: Container(
            width: renderSize,
            height: renderSize,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueAccent, width: 3),
            ),
            child: Transform.flip(
              flipX: viewModel.isFlippedGlobal,
              child: Image.asset(
                AssetHelper.getAssetPath(templateId),
                fit: BoxFit.contain,
                color: const Color(0xFF8BC34A),
                colorBlendMode: BlendMode.multiply,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemImage(PlacedItemModel item, double cellSize) {
    return Image.asset(
      AssetHelper.getAssetPath(item.itemId),
      fit: BoxFit.contain,
      color: const Color(0xFF8BC34A),
      colorBlendMode: BlendMode.multiply,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  void _handleTap(
    TapUpDetails details,
    BaseBuildingViewModel viewModel,
    double mapSize,
    double cellSize,
  ) {
    if (!viewModel.isPlacementMode) return;
    final centerX = mapSize / 2;
    final centerY = mapSize / 2;
    final double dx = details.localPosition.dx - centerX;
    final double dy = details.localPosition.dy - centerY;
    const int gridSize = 40;
    final int gridX = ((dx / cellSize) + gridSize / 2).floor();
    final int gridY = ((dy / cellSize) + gridSize / 2).floor();

    if (gridX >= 0 && gridX < gridSize && gridY >= 0 && gridY < gridSize) {
      final templateId = viewModel.selectedItemTemplateId!;
      final int size = viewModel.getItemSize(templateId);

      // Center placement on tap
      final int topY = gridY - (size / 2).floor();
      final int leftX = gridX - (size / 2).floor();

      // Enforce Cost Check for Tap Placement
      final castleViewModel = Provider.of<CastleGroundsViewModel>(
        context,
        listen: false,
      );
      final cost = BuildingCostConfig.getCost(templateId);

      if (cost.isFree) {
        viewModel.placeItem(
          itemType: 'building',
          itemId: templateId,
          gridX: leftX,
          gridY: topY,
        );
        viewModel.cancelPlacementMode();
      } else {
        castleViewModel
            .spendResources(
              coins: cost.coins,
              wood: cost.wood,
              stone: cost.stone,
            )
            .then((success) {
              if (success) {
                viewModel.placeItem(
                  itemType: 'building',
                  itemId: templateId,
                  gridX: leftX,
                  gridY: topY,
                );
                viewModel.cancelPlacementMode();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Not enough resources to build!'),
                  ),
                );
              }
            });
      }
      viewModel.cancelPlacementMode();
    }
  }

  Widget _buildTopBar(BaseBuildingViewModel viewModel) {
    // Access live data providers
    final authViewModel = Provider.of<AuthViewModel>(context);
    final castleViewModel = Provider.of<CastleGroundsViewModel>(context);

    // Get unified resources from CastleGroundsViewModel
    // This ensures they match the CastleGroundsView exactly
    final castle = castleViewModel.castle;
    final int woodCount = castle?.wood ?? 0;
    final int stoneCount = castle?.stones ?? 0;
    final int userCoins = castle?.coins ?? 0;

    final userName = authViewModel.user?.name ?? 'COMMANDER';

    final progress = viewModel.levelProgress;
    // Calculate completion safely
    double completion = 0.0;
    if (progress != null) {
      final totalRequired = viewModel
          .currentLevelConfig
          .requirements
          .requiredItems
          .fold(0, (sum, item) => sum + item.quantity);
      completion = progress.calculateCompletionPercentage(totalRequired);
    }
    completion = completion.clamp(0.0, 1.0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section: Back, Profile, Progress
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
                  if (viewModel.isVisitorMode) {
                    viewModel.clearVisitorMode();
                  }
                  Navigator.pop(context);
                },
              ),
              SizedBox(width: 1.w),
              if (viewModel.isVisitorMode) ...[
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "VISITING ${viewModel.visitorName?.toUpperCase()}'S KINGDOM",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10
                                      .sp, // Slightly smaller for narrow screens
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 14, // Slightly smaller
                          backgroundColor: Colors.grey.shade800,
                          backgroundImage: authViewModel.user?.avatar != null
                              ? NetworkImage(authViewModel.user!.avatar!)
                              : null,
                          child: authViewModel.user?.avatar == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userName.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp, // Slightly smaller
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            GestureDetector(
                              onTap: () => _showRequirementsDialog(viewModel),
                              child: Container(
                                width: 100, // Slightly narrower
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: completion,
                                          backgroundColor: Colors.grey.shade700,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.greenAccent),
                                          minHeight: 4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${(completion * 100).toInt()}%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],

              // Right Section: Resources
              _buildResourceChip(
                Icons.monetization_on,
                userCoins,
                Colors.amber,
              ),
              SizedBox(width: 1.w),
              _buildResourceChip(Icons.forest, woodCount, Colors.brown),
              SizedBox(width: 1.w),
              _buildResourceChip(Icons.landscape, stoneCount, Colors.grey),
              SizedBox(width: 2.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceChip(IconData icon, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showRequirementsDialog(BaseBuildingViewModel viewModel) {
    final progress = viewModel.levelProgress;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5E6CA),
        title: Text(
          'Requirements for Level ${viewModel.currentLevel + 1}',
          style: const TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...viewModel.currentLevelConfig.requirements.requiredItems.map((
              req,
            ) {
              final current = progress?.placedItems[req.itemTemplateId] ?? 0;
              final isMet = current >= req.quantity;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isMet ? Icons.check_circle : Icons.circle_outlined,
                      color: isMet ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getReadableName(req.itemTemplateId),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isMet ? Colors.black87 : Colors.grey.shade700,
                          decoration: isMet ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    Text(
                      '$current/${req.quantity}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isMet ? Colors.green : Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF5D4037)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementBar(BaseBuildingViewModel viewModel) {
    final item = viewModel.selectedPlacedItem;
    if (item == null) return const SizedBox.shrink();
    final name = _getReadableName(item.itemId);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 140, // Fixed height to avoid overflow
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LVL ${viewModel.currentLevel} $name'.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp, // Slightly smaller
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'STURDY FORTIFICATION',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => viewModel.selectPlacedItem(null),
                ),
              ],
            ),
            const Spacer(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildManagementAction(
                    icon: Icons.flip_camera_android,
                    label: 'FLIP',
                    onPressed: () => viewModel.updateItem(
                      itemId: item.id,
                      isFlipped: !item.isFlipped,
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final nextTier = BuildingCostConfig.getNextTier(
                        item.itemId,
                      );
                      final canUpgrade = nextTier != null;

                      return _buildManagementAction(
                        icon: Icons.arrow_upward,
                        label: 'UPGRADE',
                        color: canUpgrade ? Colors.orangeAccent : Colors.grey,
                        onPressed: () {
                          if (!canUpgrade) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Max level reached for this item!',
                                ),
                              ),
                            );
                            return;
                          }
                          _showUpgradeDialog(
                            context,
                            viewModel,
                            item,
                            nextTier!,
                          );
                        },
                      );
                    },
                  ),
                  _buildManagementAction(
                    icon: Icons.delete_forever,
                    label: 'REMOVE',
                    color: Colors.redAccent,
                    onPressed: () => viewModel.removeItem(item.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReadableName(String templateId) {
    return templateId
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildDragPreviewGhost(
    BaseBuildingViewModel viewModel,
    double mapSize,
    double cellSize,
  ) {
    if (viewModel.previewGridX == null || viewModel.previewGridY == null) {
      return const SizedBox.shrink();
    }
    final centerX = mapSize / 2;
    final centerY = mapSize / 2;
    final templateId = viewModel.previewTemplateId ?? '';
    final int gridScale = viewModel.getItemSize(templateId);
    final double scaleFactor = templateId.contains('wall') ? 2.8 : 1.8;
    final double renderSize = cellSize * (gridScale * scaleFactor);

    const int gridSize = 40;
    // Precise centering for the ghost
    final double left =
        centerX +
        (viewModel.previewGridX! - gridSize / 2) * cellSize +
        (cellSize * gridScale - renderSize) / 2;
    final double top =
        centerY +
        (viewModel.previewGridY! - gridSize / 2) * cellSize +
        (cellSize * gridScale - renderSize) / 2;

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.4,
          child: Container(
            width: renderSize,
            height: renderSize,
            decoration: BoxDecoration(
              color: viewModel.isPreviewValid
                  ? Colors.blue.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: viewModel.isPreviewValid
                    ? Colors.blueAccent
                    : Colors.redAccent,
                width: 2,
              ),
            ),
            child: Transform.flip(
              flipX: viewModel.isFlippedGlobal,
              child: Image.asset(
                AssetHelper.getAssetPath(templateId),
                fit: BoxFit.contain,
                color: const Color(0xFF8BC34A),
                colorBlendMode: BlendMode.multiply,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(
    BuildContext context,
    BaseBuildingViewModel viewModel,
    PlacedItemModel item,
    String nextTier,
  ) {
    final cost = BuildingCostConfig.getCost(nextTier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5E6CA),
        title: Text(
          'UPGRADE TO\n${_getReadableName(nextTier).toUpperCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'REQUIRED RESOURCES:',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cost.isFree)
                  const Text(
                    'FREE',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                if (cost.wood > 0) ...[
                  _buildCostDisplay(Icons.forest, cost.wood, Colors.brown),
                  const SizedBox(width: 15),
                ],
                if (cost.stone > 0) ...[
                  _buildCostDisplay(
                    Icons.construction,
                    cost.stone,
                    Colors.grey,
                  ),
                  const SizedBox(width: 15),
                ],
                if (cost.coins > 0) ...[
                  _buildCostDisplay(
                    Icons.monetization_on,
                    cost.coins,
                    Colors.amber,
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D4037),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _performUpgrade(context, viewModel, item, nextTier, cost);
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  Widget _buildCostDisplay(IconData icon, int amount, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          '$amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: const Color(0xFF5D4037),
          ),
        ),
      ],
    );
  }

  void _performUpgrade(
    BuildContext context,
    BaseBuildingViewModel viewModel,
    PlacedItemModel item,
    String nextTier,
    ResourceCost cost,
  ) {
    final castleViewModel = Provider.of<CastleGroundsViewModel>(
      context,
      listen: false,
    );

    if (cost.isFree) {
      viewModel.upgradeItem(item.id, nextTier);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upgraded to ${_getReadableName(nextTier)}!')),
      );
    } else {
      castleViewModel
          .spendResources(coins: cost.coins, wood: cost.wood, stone: cost.stone)
          .then((success) {
            if (success) {
              viewModel.upgradeItem(item.id, nextTier);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Upgraded to ${_getReadableName(nextTier)}!'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not enough resources to upgrade!'),
                ),
              );
            }
          });
    }
  }

  /// Generate random decorations outside the central grid area
  List<Widget> _buildDecorations(double mapSize, int count, double minRadius) {
    final random = math.Random(12345); // Fixed seed for consistent placement
    final widgets = <Widget>[];
    final centerX = mapSize / 2;
    final centerY = mapSize / 2;

    for (int i = 0; i < count; i++) {
      // Generate random position
      double dx = (random.nextDouble() - 0.5) * mapSize;
      double dy = (random.nextDouble() - 0.5) * mapSize;

      // Check distance from center
      final distance = math.sqrt(dx * dx + dy * dy);

      // Only keep if outside the main grid area (plus a buffer)
      if (distance > minRadius) {
        final isTree = random.nextBool();
        widgets.add(
          Positioned(
            left: centerX + dx,
            top: centerY + dy,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                isTree
                    ? 'assets/images/tree_1.png'
                    : 'assets/images/bush_1.png',
                width: isTree ? 80 : 40,
                height: isTree ? 80 : 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if assets don't exist
                  return Icon(
                    Icons.forest,
                    color: Colors.green.shade800.withOpacity(0.5),
                    size: 40,
                  );
                },
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}
