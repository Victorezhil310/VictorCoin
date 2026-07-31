import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentIndex = appState.currentTab;

    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          top: BorderSide(color: AppTheme.cardBorder, width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, index: 0, icon: Icons.home_rounded, label: "Home", isSelected: currentIndex == 0),
          _buildNavItem(context, index: 1, icon: Icons.bar_chart_rounded, label: "Market", isSelected: currentIndex == 1),
          _buildCenterVButton(context),
          _buildNavItem(context, index: 3, icon: Icons.account_balance_wallet_rounded, label: "Wallet", isSelected: currentIndex == 3),
          _buildNavItem(
            context,
            index: 4,
            icon: appState.isOwner ? Icons.workspace_premium_rounded : Icons.savings_rounded,
            label: appState.isOwner ? "Owner" : "Staking",
            isSelected: currentIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required int index, required IconData icon, required String label, required bool isSelected}) {
    final appState = Provider.of<AppState>(context, listen: false);
    return InkWell(
      onTap: () => appState.setTab(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryGold : AppTheme.textSecondary,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryGold : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterVButton(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isSelected = appState.currentTab == 2;

    return InkWell(
      onTap: () => appState.setTab(2), // Jump to Trade Screen
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.goldGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(isSelected ? 0.6 : 0.3),
              blurRadius: isSelected ? 16 : 10,
              spreadRadius: isSelected ? 3 : 1,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "V",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.black,
              fontSize: 26,
            ),
          ),
        ),
      ),
    );
  }
}
