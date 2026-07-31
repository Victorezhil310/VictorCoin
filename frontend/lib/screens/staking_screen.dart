import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/gold_button.dart';

class StakingScreen extends StatelessWidget {
  const StakingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Staking Vaults",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                "Earn passive yield on your VictorCoin holdings",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Active Staking Summary Card
              GlassCard(
                borderColor: AppTheme.primaryGold,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Staked", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Text(
                          "${appState.totalStaked.toStringAsFixed(2)} VCT",
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        const Text("Earned Rewards", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Text(
                          "+${appState.earnedRewards.toStringAsFixed(2)} VCT",
                          style: const TextStyle(color: AppTheme.greenPositive, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: appState.earnedRewards > 0 ? () => appState.claimRewards() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Claim Rewards", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Available Pools",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),

              _buildPoolCard(
                context,
                title: "365 Days Diamond Vault",
                apy: "18.5% APY",
                badge: "HIGHEST YIELD",
                lockPeriod: "365 Days",
                minStake: "2,500 VCT",
                onStake: () => _showStakeDialog(context, appState, 2500.0),
              ),
              _buildPoolCard(
                context,
                title: "90 Days Gold Vault",
                apy: "15.2% APY",
                badge: "POPULAR",
                lockPeriod: "90 Days",
                minStake: "1,000 VCT",
                onStake: () => _showStakeDialog(context, appState, 1000.0),
              ),
              _buildPoolCard(
                context,
                title: "30 Days Vault",
                apy: "12.0% APY",
                badge: "SHORT TERM",
                lockPeriod: "30 Days",
                minStake: "500 VCT",
                onStake: () => _showStakeDialog(context, appState, 500.0),
              ),
              _buildPoolCard(
                context,
                title: "Flexible Staking",
                apy: "8.5% APY",
                badge: "INSTANT UNLOCK",
                lockPeriod: "0 Days",
                minStake: "100 VCT",
                onStake: () => _showStakeDialog(context, appState, 100.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoolCard(
    BuildContext context, {
    required String title,
    required String apy,
    required String badge,
    required String lockPeriod,
    required String minStake,
    required VoidCallback onStake,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Estimated APY", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Text(
                    apy,
                    style: const TextStyle(color: AppTheme.greenPositive, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Lock Period", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Text(lockPeriod, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Min Stake", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  Text(minStake, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          GoldButton(
            label: "Stake Now",
            height: 42,
            onPressed: onStake,
          ),
        ],
      ),
    );
  }

  void _showStakeDialog(BuildContext context, AppState appState, double defaultAmount) {
    final controller = TextEditingController(text: defaultAmount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.primaryGold),
        ),
        title: const Text("Stake VCT", style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Available VCT: ${appState.vctAvailable.toStringAsFixed(2)}",
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: "Amount (VCT)",
                labelStyle: const TextStyle(color: AppTheme.primaryGold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              double amt = double.tryParse(controller.text) ?? 0.0;
              if (appState.stakeVct(amt)) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.greenPositive,
                    content: Text("Staked $amt VCT successfully!", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.redNegative,
                    content: Text("Insufficient VCT available balance"),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
            child: const Text("Confirm Stake"),
          ),
        ],
      ),
    );
  }
}
