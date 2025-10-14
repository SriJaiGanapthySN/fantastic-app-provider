import 'package:fantastic_app_riverpod/core/utils/blur_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/nav_provider.dart';
import '../../../main_screen.dart';

class BottomNavBar extends ConsumerWidget {
  final PageController? pageController;

  const BottomNavBar({super.key, this.pageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);
    if (selectedIndex == 0) {
      // Hide the bottom nav bar for chat screen
      return const SizedBox.shrink();
    }
    return BlurContainer(
      blur: 20,
      borderRadius: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
              context, 'assets/icons/chat.svg', 0, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/heart.svg', 1, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/route.svg', 2, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/search.svg', 3, selectedIndex, ref),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String iconPath, int index,
      int selectedIndex, WidgetRef ref) {
    final isSelected = index == selectedIndex;
    final controller = ref.read(pageControllerProvider);

    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Make all measurements responsive
    final buttonSize = screenWidth * 0.16; // 25% of screen width
    final iconSize = buttonSize * 0.33; // 60% of button size
    final blurValue = screenWidth * 0.01; // 2% of screen width
    final borderRadiusValue = buttonSize * 0.75; // 75% of button size
    final alphaValue = (screenWidth * 0.12)
        .clamp(40, 80)
        .toInt(); // Responsive alpha with min/max bounds

    return GestureDetector(
      onTap: () {
        print('Navigation: $iconPath → Page $index');

        try {
          // Update the selectedTabProvider state first
          ref.read(selectedTabProvider.notifier).state = index;
          print('Updated selectedTabProvider to: $index');

          // Then control the PageView with animation
          // controller?.animateToPage(
          //   index,
          //   duration: const Duration(milliseconds: 300),
          //   curve: Curves.easeInOut,
          // );
          // print('Animating to page: $index');
        } catch (e) {
          print('Navigation error: $e');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 7), // Small top padding
          BlurContainer(
            blur: blurValue,
            borderRadius: borderRadiusValue,
            color:
                isSelected ? Colors.white : Colors.black.withAlpha(alphaValue),
            width: buttonSize,
            height: buttonSize,
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.black : Colors.white,
                  BlendMode.srcIn,
                ),
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
          SizedBox(height: 7),
        ],
      ),
    );
  }
}
