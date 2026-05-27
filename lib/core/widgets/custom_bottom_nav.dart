import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.navBackground,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowStrong,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              icon: Icons.bookmark_outline_rounded,
              activeIcon: Icons.bookmark_rounded,
              label: 'Заметки',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month_rounded,
              label: 'Календарь',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          margin: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? AppColors.navSelected
                      : AppColors.navUnselected,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppColors.navSelected
                      : AppColors.navUnselected,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
