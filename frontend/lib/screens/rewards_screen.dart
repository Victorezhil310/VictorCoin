import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/gold_button.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rewards Center", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Matching Reference Image 2: Welcome Reward $5,000 Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF201B0B), Color(0xFF0F0D06)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.2),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "VictorCoin Hub",
                      style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Welcome Reward",
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      "\$5,000",
                      style: TextStyle(
                        color: AppTheme.primaryGold,
                        fontSize: 38,
                        fontWeight: FontWeight.black,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Special offer for new registered users",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    GoldButton(
                      label: "Claim Welcome Bonus",
                      width: 220,
                      height: 44,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: AppTheme.greenPositive, content: Text("Welcome Bonus Claimed!")),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Daily Streak Reward
              const Text("Daily Check-In Reward", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 10),
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Day 7 Streak Bonus", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        Text("+50 VCT Free Daily", style: TextStyle(color: AppTheme.greenPositive, fontSize: 12)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: AppTheme.greenPositive, content: Text("Claimed +50 VCT Daily Streak Reward!")),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
                      child: const Text("Check In", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Referral System
              const Text("Invite Friends & Earn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 10),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your Referral Link", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("https://victorcoin.io/ref/REF8F99A", style: TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
                          Icon(Icons.copy, color: AppTheme.primaryGold, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Earn 20% commission on every trade your referrals make!", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
