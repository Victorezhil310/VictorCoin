import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:victorcoin_app/theme/app_theme.dart';
import 'package:victorcoin_app/providers/app_state.dart';
import 'package:victorcoin_app/widgets/custom_bottom_nav.dart';
import 'package:victorcoin_app/screens/home_screen.dart';
import 'package:victorcoin_app/screens/market_screen.dart';
import 'package:victorcoin_app/screens/trade_screen.dart';
import 'package:victorcoin_app/screens/wallet_screen.dart';
import 'package:victorcoin_app/screens/staking_screen.dart';
import 'package:victorcoin_app/screens/owner_admin_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const VictorCoinApp(),
    ),
  );
}

class VictorCoinApp extends StatelessWidget {
  const VictorCoinApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VictorCoin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatelessWidget {
  const MainNavigationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final List<Widget> screens = [
      const HomeScreen(),
      const MarketScreen(),
      const TradeScreen(),
      const WalletScreen(),
      appState.isOwner ? const OwnerAdminScreen() : const StakingScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: appState.currentTab,
        children: screens,
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
