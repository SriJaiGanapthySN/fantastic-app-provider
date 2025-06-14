import 'package:fantastic_app_riverpod/utils/blur_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/nav_provider.dart';
import '../screens/main_screen.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return BlurContainer(
      blur: 17.51,
      borderRadius: 54.71,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
              context, 'assets/icons/chat.svg', 0, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/route.svg', 1, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/search.svg', 2, selectedIndex, ref),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String iconPath, int index,
      int selectedIndex, WidgetRef ref) {
    final isSelected = index == selectedIndex;
    final pageController = ref.read(pageControllerProvider);

    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Make all measurements responsive
    final buttonSize = screenWidth * 0.13; // 13% of screen width
    final iconSize = buttonSize * 0.48; // 48% of button size
    final blurValue = screenWidth * 0.02; // 2% of screen width
    final borderRadiusValue = buttonSize * 0.75; // 75% of button size
    final alphaValue = (screenWidth * 0.13)
        .clamp(40, 80)
        .toInt(); // Responsive alpha with min/max bounds

    return GestureDetector(
      onTap: () {
        // Update the selectedTabProvider state
        ref.read(selectedTabProvider.notifier).state = index;

        // Directly control the PageView
        pageController.jumpToPage(index);
      },
      child: BlurContainer(
        blur: blurValue,
        borderRadius: borderRadiusValue,
        color: isSelected ? Colors.white : Colors.black.withAlpha(alphaValue),
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
    );
  }
}
