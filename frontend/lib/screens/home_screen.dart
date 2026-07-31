import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/owner_pin_dialog.dart';
import 'package:victorcoin_app/screens/mining_screen.dart';
import 'package:victorcoin_app/screens/rewards_screen.dart';
import 'package:victorcoin_app/screens/support_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

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
              _buildTopHeader(context, appState),
              const SizedBox(height: 18),
              _buildTotalBalanceCard(context, appState),
              const SizedBox(height: 20),
              _buildQuickNavigationGrid(context, appState),
              const SizedBox(height: 20),
              _buildStakingBanner(context, appState),
              const SizedBox(height: 22),
              _buildMarketOverviewSection(context, appState),
              const SizedBox(height: 22),
              _buildFeaturesRibbon(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, AppState appState) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.primaryGold,
          child: const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb"),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Hello, ${appState.username}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
              ],
            ),
            Text(
              appState.isOwner ? "👑 Owner Superuser" : "Welcome Back!",
              style: TextStyle(
                fontSize: 12,
                color: appState.isOwner ? AppTheme.primaryGold : AppTheme.textSecondary,
                fontWeight: appState.isOwner ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => const OwnerPinDialog(),
            );
          },
          icon: Icon(
            appState.isOwner ? Icons.workspace_premium : Icons.admin_panel_settings_outlined,
            color: appState.isOwner ? AppTheme.primaryGold : Colors.white70,
            size: 24,
          ),
          tooltip: "Owner Login PIN",
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppTheme.surface,
                content: Text("Notifications: Staking rewards payout +145.85 VCT credited"),
              ),
            );
          },
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 24),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, AppState appState) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppTheme.primaryGold.withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Balance",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.greenPositive.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_drop_up, color: AppTheme.greenPositive, size: 16),
                    Text(
                      "${appState.change24h}% (24h)",
                      style: const TextStyle(
                        color: AppTheme.greenPositive,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                appState.vctBalance.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "VCT",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "≈ \$${appState.fiatBalance.toStringAsFixed(2)} USD",
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, label: "Send", icon: Icons.arrow_upward_rounded, onTap: () => appState.setTab(3)),
              _buildActionButton(context, label: "Receive", icon: Icons.arrow_downward_rounded, onTap: () => appState.setTab(3)),
              _buildActionButton(context, label: "Buy", icon: Icons.add_circle_outline_rounded, onTap: () => appState.setTab(2)),
              _buildActionButton(context, label: "Swap", icon: Icons.swap_calls_rounded, onTap: () => appState.setTab(2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGold, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNavigationGrid(BuildContext context, AppState appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavGridItem(context, label: "Mining", icon: Icons.bolt_rounded, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MiningScreen()));
        }),
        _buildNavGridItem(context, label: "Staking", icon: Icons.savings_rounded, onTap: () => appState.setTab(4)),
        _buildNavGridItem(context, label: "Rewards", icon: Icons.card_giftcard_rounded, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RewardsScreen()));
        }),
        _buildNavGridItem(context, label: "Wallet", icon: Icons.account_balance_wallet_rounded, onTap: () => appState.setTab(3)),
      ],
    );
  }

  Widget _buildNavGridItem(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.darkCardGradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStakingBanner(BuildContext context, AppState appState) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppTheme.primaryGold.withOpacity(0.5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Stake VCT",
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Earn up to 18.5% APY",
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => appState.setTab(4),
                  child: Row(
                    children: const [
                      Text(
                        "Start Staking",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGold, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.goldGradient,
            ),
            child: const Center(
              child: Text(
                "V",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.black,
                  fontSize: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketOverviewSection(BuildContext context, AppState appState) {
    final featuredMarkets = appState.markets.take(3).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Market Overview",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () => appState.setTab(1),
              child: const Text(
                "View All",
                style: TextStyle(color: AppTheme.primaryGold, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...featuredMarkets.map((m) {
          final isPositive = (m['change'] as double) >= 0;
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () => appState.setTab(2),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Center(
                    child: Text(
                      m['icon'],
                      style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['name'],
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      m['symbol'],
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${m['price']}",
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "${isPositive ? '+' : ''}${m['change']}%",
                      style: TextStyle(
                        color: isPositive ? AppTheme.greenPositive : AppTheme.redNegative,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFeaturesRibbon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RibbonItem(
            icon: Icons.shield_outlined,
            label: "Secure Wallet",
            onTap: () => Provider.of<AppState>(context, listen: false).setTab(3),
          ),
          _RibbonItem(
            icon: Icons.flash_on_rounded,
            label: "Fast Tx",
            onTap: () => Provider.of<AppState>(context, listen: false).setTab(2),
          ),
          _RibbonItem(
            icon: Icons.percent_rounded,
            label: "Low Fees",
            onTap: () => Provider.of<AppState>(context, listen: false).setTab(1),
          ),
          _RibbonItem(
            icon: Icons.headset_mic_outlined,
            label: "24/7 Support",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _RibbonItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RibbonItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
