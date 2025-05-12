import 'package:fantastic_app_riverpod/utils/blur_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/nav_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return BlurContainer(
      blur: 17.51,
      borderRadius: 54.71,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
              context, 'assets/icons/chat.svg', 0, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/route.svg', 1, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/heart.svg', 2, selectedIndex, ref),
          _buildNavButton(
              context, 'assets/icons/search.svg', 3, selectedIndex, ref),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String iconPath, int index,
      int selectedIndex, WidgetRef ref) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => ref.read(selectedTabProvider.notifier).state = index,
      child: BlurContainer(
        blur: 8,
        borderRadius: 54.71,
        color: isSelected ? Colors.white : Colors.black.withAlpha(51),
        width: 64,
        height: 64,
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              isSelected ? Colors.black : Colors.white,
              BlendMode.srcIn,
            ),
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
