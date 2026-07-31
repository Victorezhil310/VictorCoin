import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';

class OwnerPinDialog extends StatefulWidget {
  const OwnerPinDialog({Key? key}) : super(key: key);

  @override
  State<OwnerPinDialog> createState() => _OwnerPinDialogState();
}

class _OwnerPinDialogState extends State<OwnerPinDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _submitPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.loginAsOwner(pin);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.primaryGold,
            content: Text(
              "👑 OWNER ACCESS GRANTED - All Elevated Control Unlocked",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = "Invalid Owner PIN. Access Denied.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0x22FFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: AppTheme.primaryGold, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Owner Security Login",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter secret owner PIN to unlock global controls & ad-free superuser mode.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 8,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "••••••",
                hintStyle: TextStyle(color: Colors.white24, letterSpacing: 8),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryGold),
                ),
              ),
              onSubmitted: (_) => _submitPin(),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppTheme.redNegative, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text(
                        "UNLOCK OWNER CONTROLS",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
