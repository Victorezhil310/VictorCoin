import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/gold_button.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

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
                "My Wallet",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 14),

              // Wallet Address & QR Quick Card
              GlassCard(
                borderColor: AppTheme.primaryGold,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Wallet Address", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              "${appState.walletAddress.substring(0, 10)}...${appState.walletAddress.substring(34)}",
                              style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: AppTheme.primaryGold, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Wallet address copied to clipboard")),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAssetRow("VCT", "${appState.vctBalance.toStringAsFixed(2)} VCT", "\$${(appState.vctBalance * 0.2458).toStringAsFixed(2)}"),
                        _buildAssetRow("USDT", "${appState.usdtBalance.toStringAsFixed(2)} USDT", "\$${appState.usdtBalance.toStringAsFixed(2)}"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Quick Action Buttons
              Row(
                children: [
                  Expanded(
                    child: GoldButton(
                      label: "Deposit",
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: () => _showDepositModal(context, appState),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GoldButton(
                      label: "Receive QR",
                      isOutlined: true,
                      icon: Icons.qr_code_rounded,
                      onPressed: () => _showQrModal(context, appState),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Payment Gateway Providers
              const Text(
                "Supported Payment Gateways",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ["UPI Instant", "Razorpay", "Paytm", "PhonePe", "Google Pay", "Bank Transfer"].map((gw) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payment_rounded, color: AppTheme.primaryGold, size: 16),
                          const SizedBox(width: 6),
                          Text(gw, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),

              // Transaction History
              const Text(
                "Transaction History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildTxItem(type: "Deposit", amount: "+5,000.00 VCT", status: "Completed", date: "2026-07-30 14:22"),
              _buildTxItem(type: "Staking Reward", amount: "+145.85 VCT", status: "Completed", date: "2026-07-29 10:15"),
              _buildTxItem(type: "Buy Order", amount: "+100.00 VCT", status: "Completed", date: "2026-07-28 18:40"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetRow(String code, String balance, String usdValue) {
    return Column(
      children: [
        Text(code, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 2),
        Text(balance, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(usdValue, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12)),
      ],
    );
  }

  Widget _buildTxItem({required String type, required String amount, required String status, required String date}) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppTheme.surfaceLight, shape: BoxShape.circle),
                child: const Icon(Icons.swap_vert_rounded, color: AppTheme.primaryGold, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(date, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: AppTheme.greenPositive, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(status, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  void _showDepositModal(BuildContext context, AppState appState) {
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.primaryGold)),
        title: const Text("Deposit USD / Fiat", style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: "Amount (USD)",
                labelStyle: TextStyle(color: AppTheme.primaryGold),
              ),
            ),
            const SizedBox(height: 12),
            const Text("Select Gateway: Razorpay / UPI / Paytm / Card", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: AppTheme.greenPositive, content: Text("Deposit order initiated successfully!")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black),
            child: const Text("Proceed Payment"),
          ),
        ],
      ),
    );
  }

  void _showQrModal(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.primaryGold)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Receive VictorCoin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: QrImageView(
                  data: appState.walletAddress,
                  version: QrVersions.auto,
                  size: 180.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(appState.walletAddress, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 11)),
              const SizedBox(height: 16),
              GoldButton(label: "Close", height: 40, onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }
}
