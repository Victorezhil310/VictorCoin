import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/glass_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _selectedCategory = "All";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final markets = appState.markets.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m['code'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Market",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 14),
              // Search Input
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: "Search Coin",
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryGold),
                  filled: true,
                  fillColor: AppTheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primaryGold),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Category Filters
              Row(
                children: ["All", "Favourite", "Top Gainers"].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      selectedColor: AppTheme.primaryGold,
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryGold : AppTheme.cardBorder,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Markets List
              Expanded(
                child: ListView.builder(
                  itemCount: markets.length,
                  itemBuilder: (context, index) {
                    final item = markets[index];
                    final isPositive = (item['change'] as double) >= 0;
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      onTap: () => appState.setTab(2), // Jump to Trade
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: Center(
                              child: Text(
                                item['icon'],
                                style: const TextStyle(
                                  color: AppTheme.primaryGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                item['code'],
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${item['price']}",
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                    color: isPositive ? AppTheme.greenPositive : AppTheme.redNegative,
                                    size: 16,
                                  ),
                                  Text(
                                    "${item['change']}%",
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
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
