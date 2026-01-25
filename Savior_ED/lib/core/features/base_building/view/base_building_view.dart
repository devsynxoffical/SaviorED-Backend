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

class _BaseBuildingViewState extends State<BaseBuildingView>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _mapAreaKey = GlobalKey();
  bool _isInventoryOpen = false;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

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

      // Sync update callback
      viewModel.onCastleDataUpdated = (data) {
        castleViewModel.updateFromData(data);
      };

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
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark base for the image overlay
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
              // 0. GLOBAL INFINITE JUNGLE BACKGROUND
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/seamless_grass.png'),
                      repeat: ImageRepeat.repeat,
                      scale: 0.8,
                      colorFilter: ColorFilter.mode(
                        Colors.black26,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
              ),

              // 1. Interactive Content
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
      minScale:
          fitScale, // LOCK ZOOM OUT: User cannot zoom out more than the initial fit
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
              color: Colors.transparent, // Removed solid green background
              alignment: Alignment.center, // CRITICAL: Center contents
              child: Stack(
                alignment: Alignment.center, // CRITICAL: Center stack items
                children: [
                  // 1. Infinite Jungle Background (Tiled covers EVERYTHING)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/env_jungle_corner.png',
                          ),
                          repeat: ImageRepeat.repeat,
                          scale: 0.8, // Adjusted scale for better density
                          colorFilter: ColorFilter.mode(
                            Colors.black54, // Darker filter for better contrast
                            BlendMode.darken,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. "Clearing" Effect (Radial Mask behind grid)
                  Center(
                    child: Container(
                      width: mapSize * 0.8,
                      height: mapSize * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF689F38), // Blend into map bg
                            blurRadius: 100,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Playable Grid
                  Center(
                    child: Container(
                      width: gridSize * cellSize,
                      height: gridSize * cellSize,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF8BC34A,
                        ).withOpacity(0.5), // Semi-transparent green grid
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

        final int inStock = castleViewModel.castle?.inventory[templateId] ?? 0;

        if (cost.isFree || inStock > 0) {
          viewModel.placeItem(
            itemType: 'building',
            itemId: templateId,
            gridX: leftX,
            gridY: topY,
          );
        } else {
          // Check & Spend Logic (Purchase)
          castleViewModel
              .spendResources(
                coins: cost.coins,
                wood: cost.wood,
                stone: cost.stone,
                itemId: templateId, // Record purchase
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
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.zero,
              border: null,
            ),
            child: Transform.flip(
              flipX: viewModel.isFlippedGlobal,
              child: Image.asset(
                AssetHelper.getAssetPath(templateId),
                fit: BoxFit.contain,
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

      final int inStock = castleViewModel.castle?.inventory[templateId] ?? 0;

      if (cost.isFree || inStock > 0) {
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
              itemId: templateId, // Record purchase
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
      completion = progress.calculateCompletionPercentage(
        viewModel.currentLevelConfig.requirements,
      );
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
          if (viewModel.levelProgress?.isCompleted ?? false)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _handleLevelUp(context);
              },
              child: const Text(
                'LEVEL UP!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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

  Future<void> _handleLevelUp(BuildContext context) async {
    final castleViewModel = Provider.of<CastleGroundsViewModel>(
      context,
      listen: false,
    );
    final baseViewModel = Provider.of<BaseBuildingViewModel>(
      context,
      listen: false,
    );

    // Optimistic UI or Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.amber)),
    );

    final success = await castleViewModel.levelUp();

    if (context.mounted) {
      Navigator.pop(context); // Close loading

      if (success) {
        // Refresh base data to get new level limits
        baseViewModel.loadBase();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFF8E1),
            title: const Text('🎉 LEVEL UP! 🎉', textAlign: TextAlign.center),
            content: Text(
              'Congratulations! You have reached Level ${castleViewModel.castle?.level ?? "?"}!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('AWESOME'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to level up. Check connection.'),
          ),
        );
      }
    }
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
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10.sp,
                        ),
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
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.zero,
              border: null,
            ),
            child: Transform.flip(
              flipX: viewModel.isFlippedGlobal,
              child: Image.asset(
                AssetHelper.getAssetPath(templateId),
                fit: BoxFit.contain,
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
    // Determine Required Level for the Next Tier
    int requiredLevel = 1;
    if (nextTier.contains('medium') ||
        nextTier.contains('watch') ||
        nextTier.contains('shed'))
      requiredLevel = 2;
    else if (nextTier.contains('strong') ||
        nextTier.contains('defense') ||
        nextTier.contains('armory'))
      requiredLevel = 3;
    else if (nextTier.contains('fortress') ||
        nextTier.contains('battle') ||
        nextTier.contains('complex'))
      requiredLevel = 4;
    else if (nextTier.contains('master') || nextTier.contains('advanced'))
      requiredLevel = 5;
    else if (nextTier.contains('legendary'))
      requiredLevel = 6;

    // STRICT LEVEL GATING
    if (viewModel.currentLevel < requiredLevel) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFF5E6CA),
          title: const Text(
            'UPGRADE LOCKED',
            style: TextStyle(
              color: Color(0xFF5D4037),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, size: 50, color: Colors.grey.shade600),
              const SizedBox(height: 15),
              Text(
                'You must upgrade your Castle to Level $requiredLevel to unlock this building upgrade.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
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
      return;
    }

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
}

/// Custom Painter for the background environment (River, Mountains, Ripples, Fireflies)
class EnvironmentPainter extends CustomPainter {
  final double mapSize;
  final double animationValue;

  EnvironmentPainter({required this.mapSize, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = mapSize / 2;

    // --- DRAW WESTERN RIVER ---
    final riverPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final riverPath = Path();
    riverPath.moveTo(0, center - 400);

    // Create organic winding path
    for (double i = 0; i < center + 500; i += 20) {
      double waveOffset =
          math.sin((i / 100) + (animationValue * 2 * math.pi)) * 10;
      riverPath.lineTo(40 + waveOffset, center - 400 + i);
    }
    riverPath.lineTo(0, mapSize);
    riverPath.close();
    canvas.drawPath(riverPath, riverPaint);

    // --- WATER RIPPLES ---
    final ripplePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 8; i++) {
      double rPos = ((animationValue + (i / 8)) % 1.0) * (mapSize / 2);
      double rX = 20 + math.sin(rPos / 50) * 10;
      double rY = center - 300 + rPos;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(rX, rY), width: 30, height: 10),
        ripplePaint
          ..color = Colors.white.withOpacity(
            0.3 * (1.0 - (rPos / (mapSize / 2))),
          ),
      );
    }

    // --- DRAW EASTERN MOUNTAINS ---
    for (int i = 0; i < 6; i++) {
      final mX = mapSize - 150 - (i * 120);
      final mY = center - 300 + (i * 140);
      final mHeight = 150.0 + (i * 30);

      final mPath = Path();
      mPath.moveTo(mX, mY);
      mPath.lineTo(mX + 150, mY + 80);
      mPath.lineTo(mX + 300, mY);
      mPath.lineTo(mX + 150, mY - mHeight); // Peak
      mPath.close();

      final shadowPaint = Paint()
        ..color = Colors.brown.withOpacity(0.3 + (i * 0.05));
      canvas.drawPath(mPath, shadowPaint);

      // Snow cap
      final capPath = Path();
      capPath.moveTo(mX + 150 - 30, mY - mHeight + 40);
      capPath.lineTo(mX + 150, mY - mHeight);
      capPath.lineTo(mX + 150 + 30, mY - mHeight + 40);
      capPath.close();
      canvas.drawPath(capPath, Paint()..color = Colors.white.withOpacity(0.7));
    }

    // --- DYNAMIC FIREFLIES ---
    final fireflyPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      double fAngle = (animationValue * 2 * math.pi) + (i * 2.0);

      // Distribute fireflies mostly around North/Jungle
      double fx =
          (center + math.cos(fAngle) * (mapSize / 3)) +
          (math.sin(fAngle * 2) * 20);
      double fy = (center / 2 + math.sin(fAngle) * 200);

      double opacity = (0.5 + 0.5 * math.sin(fAngle * 3)).clamp(0.0, 1.0);
      fireflyPaint.color = Colors.yellowAccent.withOpacity(opacity * 0.8);

      // Inner glow
      canvas.drawCircle(Offset(fx, fy), 3, fireflyPaint);
      // Outer glow
      canvas.drawCircle(
        Offset(fx, fy),
        8,
        Paint()..color = Colors.yellowAccent.withOpacity(opacity * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(EnvironmentPainter oldDelegate) => true;
}

/// Animated Tree widget that sways in the wind
class _AnimatedTree extends StatefulWidget {
  final int delay;
  const _AnimatedTree({required this.delay});

  @override
  State<_AnimatedTree> createState() => _AnimatedTreeState();
}

class _AnimatedTreeState extends State<_AnimatedTree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.skewX(_controller.value * 0.05),
          child: Opacity(
            opacity: 0.85,
            child: Image.asset(
              'assets/images/tree_isometric.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.forest, color: Colors.green, size: 40),
            ),
          ),
        );
      },
    );
  }
}
