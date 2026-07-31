import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/gold_button.dart';

class OwnerAdminScreen extends StatefulWidget {
  const OwnerAdminScreen({Key? key}) : super(key: key);

  @override
  State<OwnerAdminScreen> createState() => _OwnerAdminScreenState();
}

class _OwnerAdminScreenState extends State<OwnerAdminScreen> {
  final List<Map<String, dynamic>> _members = [
    {"id": 1, "name": "Victor (Owner)", "email": "owner@victorcoin.io", "role": "owner", "adFree": true},
    {"id": 2, "name": "Alex Executive", "email": "ceo@victorcoin.io", "role": "ceo", "adFree": true},
    {"id": 3, "name": "Sarah Ops", "email": "manager@victorcoin.io", "role": "manager", "adFree": true},
    {"id": 4, "name": "CryptoTrader99", "email": "trader@gmail.com", "role": "user", "adFree": false},
    {"id": 5, "name": "GlobalMerchant", "email": "pay@merchant.io", "role": "merchant", "adFree": false},
  ];

  double _ownerTradeCommission = 458900.0;
  double _ownerMiningRoyalty = 124500.0;
  double _ownerAdRoyalty = 24580.0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.workspace_premium, color: AppTheme.primaryGold),
            SizedBox(width: 8),
            Text("Owner Control Center", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner Status Banner
              GlassCard(
                borderColor: AppTheme.primaryGold,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Owner Privilege Level", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primaryGold, borderRadius: BorderRadius.circular(6)),
                          child: const Text("SUPERUSER ACTIVE", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text("Full Governance & Platform Royalty Control", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    const Text("Uninhibited permissions to promote roles, mint treasury, manage platform parameters, and sweep owner commissions.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Owner Royalties & Commissions Hub
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Owner Commissions & Earnings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text("5% Royalty Rate", style: TextStyle(color: AppTheme.greenPositive, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              GlassCard(
                borderColor: AppTheme.greenPositive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommissionRow("Trading Fee Cuts (5%)", "${_ownerTradeCommission.toStringAsFixed(0)} VCT", "\$${(_ownerTradeCommission * 0.2458).toStringAsFixed(2)}"),
                    const Divider(color: AppTheme.cardBorder),
                    _buildCommissionRow("Mining Pool Royalty (5%)", "${_ownerMiningRoyalty.toStringAsFixed(0)} VCT", "\$${(_ownerMiningRoyalty * 0.2458).toStringAsFixed(2)}"),
                    const Divider(color: AppTheme.cardBorder),
                    _buildCommissionRow("Ad Revenue Share", "-", "\$${_ownerAdRoyalty.toStringAsFixed(2)} USD"),
                    const SizedBox(height: 14),
                    GoldButton(
                      label: "Withdraw Commissions to Owner Wallet",
                      icon: Icons.payments_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppTheme.greenPositive,
                            content: Text("Swept Owner Commissions to Wallet successfully!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Platform Analytics & Treasury
              const Text("Platform Analytics & Treasury", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetricCard("24h Volume", "\$1,458,920")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard("Total Users", "4,580")),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildMetricCard("Treasury Pool", "500M VCT")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard("Active Rigs", "1,240 Hash Rigs")),
                ],
              ),
              const SizedBox(height: 22),

              // Role Promotion & Management
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Member Role Promotions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text("Owner Privileges", style: TextStyle(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),

              ..._members.map((member) {
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(member['name'], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                              if (member['adFree']) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.star_rounded, color: AppTheme.primaryGold, size: 14),
                              ],
                            ],
                          ),
                          Text(member['email'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        ],
                      ),
                      DropdownButton<String>(
                        value: member['role'],
                        dropdownColor: AppTheme.surface,
                        style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
                        underline: const SizedBox(),
                        items: ["owner", "ceo", "manager", "admin", "merchant", "user"].map((r) {
                          return DropdownMenuItem(value: r, child: Text(r.toUpperCase()));
                        }).toList(),
                        onChanged: (newRole) {
                          if (newRole != null) {
                            setState(() {
                              member['role'] = newRole;
                              if (newRole == "ceo" || newRole == "manager" || newRole == "owner") {
                                member['adFree'] = true;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppTheme.primaryGold,
                                content: Text("Promoted ${member['name']} to ${newRole.toUpperCase()}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),

              // Mint Treasury Button
              GoldButton(
                label: "Mint VCT to Treasury Pool",
                icon: Icons.monetization_on_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: AppTheme.greenPositive, content: Text("Minted 10,000,000 VCT to Treasury")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionRow(String title, String vctVal, String usdVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(vctVal, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(usdVal, style: const TextStyle(color: AppTheme.greenPositive, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
