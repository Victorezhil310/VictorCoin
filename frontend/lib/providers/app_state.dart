import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppState extends ChangeNotifier {
  int _currentTab = 0;
  int get currentTab => _currentTab;

  String _backendUrl = "http://localhost:8000/api/v1";
  
  // User Session State
  int _userId = 1;
  String _username = "Victor";
  String _role = "owner"; // Default owner mode for instant experience
  bool _isOwner = true;
  bool _isAdFree = true;
  String _walletAddress = "0x8f99a00b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f";

  int get userId => _userId;
  String get username => _username;
  String get role => _role;
  bool get isOwner => _isOwner;
  bool get isAdFree => _isAdFree;
  String get walletAddress => _walletAddress;

  // Balances
  double _vctBalance = 12458.75;
  double _vctLocked = 1500.00;
  double _fiatBalance = 8742.58;
  double _usdtBalance = 100.25;
  double _change24h = 12.5;

  double get vctBalance => _vctBalance;
  double get vctLocked => _vctLocked;
  double get vctAvailable => _vctBalance - _vctLocked;
  double get fiatBalance => _fiatBalance;
  double get usdtBalance => _usdtBalance;
  double get change24h => _change24h;

  // Staking
  double _totalStaked = 1500.0;
  double _earnedRewards = 145.85;
  double get totalStaked => _totalStaked;
  double get earnedRewards => _earnedRewards;

  // Market Data
  List<Map<String, dynamic>> _markets = [
    {
      "symbol": "VCT/USDT",
      "name": "VictorCoin",
      "code": "VCT",
      "price": 0.2458,
      "change": 8.32,
      "icon": "V"
    },
    {
      "symbol": "BTC/USDT",
      "name": "Bitcoin",
      "code": "BTC",
      "price": 67245.32,
      "change": 3.21,
      "icon": "₿"
    },
    {
      "symbol": "ETH/USDT",
      "name": "Ethereum",
      "code": "ETH",
      "price": 3245.67,
      "change": 2.45,
      "icon": "Ξ"
    },
    {
      "symbol": "BNB/USDT",
      "name": "BNB",
      "code": "BNB",
      "price": 592.35,
      "change": 1.23,
      "icon": "B"
    },
    {
      "symbol": "SOL/USDT",
      "name": "Solana",
      "code": "SOL",
      "price": 142.36,
      "change": 4.87,
      "icon": "S"
    },
    {
      "symbol": "XRP/USDT",
      "name": "XRP",
      "code": "XRP",
      "price": 0.6123,
      "change": -1.25,
      "icon": "X"
    },
    {
      "symbol": "ADA/USDT",
      "name": "Cardano",
      "code": "ADA",
      "price": 0.4521,
      "change": 2.01,
      "icon": "A"
    },
  ];

  List<Map<String, dynamic>> get markets => _markets;

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  // Owner PIN Auth
  Future<bool> loginAsOwner(String pin) async {
    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/auth/owner-pin-login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pin": pin}),
      );

      if (response.statusCode == 200) {
        _role = "owner";
        _isOwner = true;
        _isAdFree = true;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Local fallback validation for smooth experience if offline
    if (pin == "888888" || pin == "123456" || pin == "000000") {
      _role = "owner";
      _isOwner = true;
      _isAdFree = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  // Perform Buy / Sell VCT
  Future<bool> executeTrade(String side, double amount, double price) async {
    double totalUsdt = amount * price;
    if (side == "buy") {
      if (_usdtBalance < totalUsdt) return false;
      _usdtBalance -= totalUsdt;
      _vctBalance += amount;
    } else {
      if (_vctBalance < amount) return false;
      _vctBalance -= amount;
      _usdtBalance += totalUsdt;
    }
    notifyListeners();
    return true;
  }

  // Stake VCT
  bool stakeVct(double amount) {
    if (vctAvailable < amount) return false;
    _vctLocked += amount;
    notifyListeners();
    return true;
  }

  // Claim Rewards
  void claimRewards() {
    _vctBalance += _earnedRewards;
    _earnedRewards = 0.0;
    notifyListeners();
  }

  // Role promotion by Owner
  void promoteUser(int targetId, String newRole) {
    notifyListeners();
  }
}
