import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';
import 'package:victorcoin_app/widgets/gold_button.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({Key? key}) : super(key: key);

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  String _selectedDoc = "Aadhaar Card";
  bool _isSubmitted = false;
  final TextEditingController _docNumController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("KYC Verification", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
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
              // KYC Status Header
              GlassCard(
                borderColor: _isSubmitted ? AppTheme.greenPositive : AppTheme.primaryGold,
                child: Row(
                  children: [
                    Icon(
                      _isSubmitted ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                      color: _isSubmitted ? AppTheme.greenPositive : AppTheme.primaryGold,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSubmitted ? "Identity Verified" : "Verification Required",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Text(
                          _isSubmitted ? "Security Level: Level 3 (Verified)" : "Complete KYC to unlock unlimited withdrawals",
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Timeline Tracker
              const Text("Verification Timeline", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              _buildTimelineStep(step: 1, title: "Select Document Type", isDone: true),
              _buildTimelineStep(step: 2, title: "Liveness Face Scan & Selfie", isDone: _isSubmitted),
              _buildTimelineStep(step: 3, title: "AI Auto Verification Engine", isDone: _isSubmitted),
              _buildTimelineStep(step: 4, title: "Full Tier Unlocked", isDone: _isSubmitted),
              const SizedBox(height: 22),

              if (!_isSubmitted) ...[
                const Text("Select Identity Document", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedDoc,
                  dropdownColor: AppTheme.surface,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                  ),
                  items: ["Aadhaar Card", "Passport", "Driving License", "National ID"].map((d) {
                    return DropdownMenuItem(value: d, child: Text(d));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDoc = val!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _docNumController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Document Number",
                    labelStyle: const TextStyle(color: AppTheme.primaryGold),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                  ),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Face Liveness Camera Scan Completed")),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_front_rounded, color: AppTheme.primaryGold, size: 24),
                      SizedBox(width: 10),
                      Text("Start Liveness Face Scan", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GoldButton(
                  label: "Submit Verification",
                  onPressed: () {
                    setState(() => _isSubmitted = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: AppTheme.greenPositive, content: Text("KYC Approved! Tier 3 Verified")),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({required int step, required String title, required bool isDone}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isDone ? AppTheme.greenPositive : AppTheme.surfaceLight,
            child: isDone
                ? const Icon(Icons.check, color: Colors.black, size: 16)
                : Text("$step", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDone ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
