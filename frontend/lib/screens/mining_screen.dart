import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/gold_button.dart';

class MiningScreen extends StatefulWidget {
  const MiningScreen({Key? key}) : super(key: key);

  @override
  State<MiningScreen> createState() => _MiningScreenState();
}

class _MiningScreenState extends State<MiningScreen> {
  double _unclaimedMined = 12.45;
  double _totalMined = 154.20;
  double _hashrate = 45.8;
  double _multiplier = 1.5;

  void _claimMinedRewards(AppState appState) {
    if (_unclaimedMined <= 0) return;

    double ownerTax = _unclaimedMined * 0.05; // 5% Owner royalty
    double netClaim = _unclaimedMined - ownerTax;

    setState(() {
      _totalMined += _unclaimedMined;
      _unclaimedMined = 0.0;
    });

    appState.claimRewards();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.greenPositive,
        content: Text(
          "Mined VCT Claimed! +${netClaim.toStringAsFixed(2)} VCT added to wallet (5% Owner Pool Tax applied)",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    double activeHashrate = _hashrate * _multiplier;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.bolt_rounded, color: AppTheme.primaryGold),
            SizedBox(width: 8),
            Text("Cloud PoS Mining", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hashrate Rig Status Card
              GlassCard(
                borderColor: AppTheme.primaryGold,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0x3300E676), shape: BoxShape.circle),
                              child: const Icon(Icons.speed_rounded, color: AppTheme.greenPositive, size: 24),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Mining Rig Status", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                Text("ACTIVE HARDWARE", style: TextStyle(color: AppTheme.greenPositive, fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: AppTheme.primaryGold.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "${_multiplier}X BOOST",
                            style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn("Hashrate Speed", "${activeHashrate.toStringAsFixed(1)} MH/s"),
                        _buildStatColumn("Daily Est. Yield", "${(activeHashrate * 0.54).toStringAsFixed(1)} VCT/day"),
                        _buildStatColumn("Owner Royalty Tax", "5% Pool Tax"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Unclaimed Mined VCT Card
              GlassCard(
                borderColor: AppTheme.primaryGold.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Unclaimed Mined VCT", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              _unclaimedMined.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(width: 8),
                            const Text("VCT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                          ],
                        ),
                        Text(
                          "≈ \$${(_unclaimedMined * 0.2458).toStringAsFixed(2)} USD",
                          style: const TextStyle(color: AppTheme.greenPositive, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GoldButton(
                      label: "Claim Mined VCT to Wallet",
                      icon: Icons.account_balance_wallet_rounded,
                      onPressed: () => _claimMinedRewards(appState),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rig Turbo Boost Options
              const Text("Turbo Boost Mining Rigs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      onTap: () {
                        setState(() => _multiplier = 2.0);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: AppTheme.primaryGold, content: Text("Mining Rig Boosted to 2.0X Turbo")),
                        );
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.flash_on_rounded, color: AppTheme.primaryGold, size: 28),
                          SizedBox(height: 6),
                          Text("2.0X Turbo Boost", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("Double Block Yield", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      onTap: () {
                        setState(() => _multiplier = 5.0);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: AppTheme.greenPositive, content: Text("Quantum Hashrate Boosted to 5.0X!")),
                        );
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.auto_awesome_rounded, color: AppTheme.greenPositive, size: 28),
                          SizedBox(height: 6),
                          Text("5.0X Quantum Rig", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text("Maximum Mining Output", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
