import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_success.dart';

class UpgradesScreen extends StatefulWidget {
  final VoidCallback? onPremiumStatusChanged;
  
  const UpgradesScreen({
    super.key,
    this.onPremiumStatusChanged,
  });

  @override
  State<UpgradesScreen> createState() => _UpgradesScreenState();
}

class _UpgradesScreenState extends State<UpgradesScreen> {
  late Razorpay _razorpay;
  static const String _premiumKey = 'is_premium';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
    
    if (mounted) {
      // Notify parent about premium status change
      widget.onPremiumStatusChanged?.call();
      
      // Pop the upgrades screen first
      Navigator.pop(context);
      
      // Show success dialog
      if (mounted) {
        await PremiumSuccessDialog.show(context);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${response.message}')),
      );
    }
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Dummy Razorpay test key
      'amount': 10000, // Amount in paise (100 INR)
      'name': 'Premium Features',
      'description': 'Unlock all premium features',
      'prefill': {
        'email': 'test@example.com',
        'name': 'Test User'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient or image can be added here
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.star, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Fabulous Premium",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Learn about benefits\nexclusive to premium\nmembers",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "When you cancel premium, your membership remains active until your final billing period. Afterward, you'll lose access to:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureItem(
                  "Coaching Series",
                  "Access collections of coachings on key topics available at all times.",
                  Icons.school,
                ),
                _buildFeatureItem(
                  "Daily coaching",
                  "Receive 3 min motivational coaching in the morning, mid-day and at night.",
                  Icons.access_time,
                ),
                _buildFeatureItem(
                  "Premium journeys",
                  "Unlock bespoke journeys which help you build life skills beyond foundational such as mental fitness.",
                  Icons.map,
                ),
                _buildFeatureItem(
                  "Unlimited habits",
                  "Customize your routines by adding more habits. Free users can add only a maximum of 3 habits.",
                  Icons.repeat,
                ),
                _buildFeatureItem(
                  "Guided trainings",
                  "Find motivation on the go with access to hundreds of curated guided trainings.",
                  Icons.fitness_center,
                ),
                _buildFeatureItem(
                  "Save your progress",
                  "New phone? Accidentally deleted the app? Pick up where you left off with data backup.",
                  Icons.backup,
                ),
                _buildFeatureItem(
                  "Routines",
                  "Keep track of your habits and check them off daily. Add custom routines and edit existing routines based on your preferences.",
                  Icons.checklist,
                ),
                _buildFeatureItem(
                  "Challenges",
                  "Challenge your friends and family to take action and push everyone — including yourself — to new heights.",
                  Icons.emoji_events,
                ),
                _buildFeatureItem(
                  "Circles",
                  "Join communities where you can give and receive support from other members like you.",
                  Icons.group,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      "Get Premium for just ₹100",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 