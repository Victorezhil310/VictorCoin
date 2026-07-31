import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  String _selectedSide = "buy"; // buy or sell
  String _orderType = "Limit Order";
  String _selectedTimeframe = "1D";

  final TextEditingController _priceController = TextEditingController(text: "0.2458");
  final TextEditingController _amountController = TextEditingController(text: "100.0");

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    double price = double.tryParse(_priceController.text) ?? 0.2458;
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double totalUsdt = price * amount;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pair Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Trade",
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                      Text(
                        "VCT / USDT",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        "0.2458",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.greenPositive),
                      ),
                      Text(
                        "+8.32%",
                        style: TextStyle(fontSize: 12, color: AppTheme.greenPositive, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Timeframe Selectors
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ["1H", "1D", "1W", "1M", "1Y"].map((tf) {
                  final isSel = _selectedTimeframe == tf;
                  return InkWell(
                    onTap: () => setState(() => _selectedTimeframe = tf),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.surfaceLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSel ? Border.all(color: AppTheme.cardBorder) : null,
                      ),
                      child: Text(
                        tf,
                        style: TextStyle(
                          color: isSel ? AppTheme.primaryGold : AppTheme.textSecondary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Candlestick / Line Chart Container
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 0.220),
                          FlSpot(1, 0.228),
                          FlSpot(2, 0.225),
                          FlSpot(3, 0.235),
                          FlSpot(4, 0.230),
                          FlSpot(5, 0.242),
                          FlSpot(6, 0.2458),
                        ],
                        isCurved: true,
                        color: AppTheme.greenPositive,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.greenPositive.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Buy / Sell Selector
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedSide = "buy"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedSide == "buy" ? AppTheme.greenPositive : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedSide == "buy" ? AppTheme.greenPositive : AppTheme.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Buy",
                            style: TextStyle(
                              color: _selectedSide == "buy" ? Colors.black : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedSide = "sell"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedSide == "sell" ? AppTheme.redNegative : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedSide == "sell" ? AppTheme.redNegative : AppTheme.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Sell",
                            style: TextStyle(
                              color: _selectedSide == "sell" ? Colors.white : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Form inputs
              GlassCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _orderType,
                      dropdownColor: AppTheme.surface,
                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        labelText: "Order Type",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: InputBorder.none,
                      ),
                      items: ["Limit Order", "Market Order", "Stop Order"].map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (v) => setState(() => _orderType = v!),
                    ),
                    const Divider(color: AppTheme.cardBorder),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: "Price (USDT)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const Divider(color: AppTheme.cardBorder),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: "Amount (VCT)",
                        labelStyle: TextStyle(color: AppTheme.textSecondary),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const Divider(color: AppTheme.cardBorder),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total (USDT)", style: TextStyle(color: AppTheme.textSecondary)),
                          Text(
                            totalUsdt.toStringAsFixed(2),
                            style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Available Balance", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        Text(
                          "${appState.usdtBalance.toStringAsFixed(2)} USDT",
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Execute Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    bool success = await appState.executeTrade(_selectedSide, amount, price);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success ? AppTheme.greenPositive : AppTheme.redNegative,
                          content: Text(
                            success
                                ? "Trade Executed: ${_selectedSide.toUpperCase()} $amount VCT @ \$${price}"
                                : "Order Failed: Insufficient Balance",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedSide == "buy" ? AppTheme.greenPositive : AppTheme.redNegative,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "${_selectedSide.toUpperCase()} VCT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _selectedSide == "buy" ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
