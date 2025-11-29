import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinema_uygulamasi/components/get_promotions.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final List<Promotion> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasPurchased = prefs.getBool('hasPurchasedTicket') ?? false;

    List<Promotion> loadedPromotions = [];

    if (!hasPurchased) {
      loadedPromotions.add(
        Promotion(
          title: '30% Off Your First Ticket',
          description:
              'Enjoy an instant 30% discount on the very first movie ticket you purchase in the app. Don’t miss out!',
          imagePath: 'assets/images/promotion_firstbuy.png',
          backgroundColor: const Color(0xffd94d43),
        ),
      );
    }

    loadedPromotions.add(
      Promotion(
        title: 'Popcorn & Drink Combo 200 TL',
        description:
            'Large popcorn plus a medium drink for only 200 TL. Add it to your order for the full cinema experience.',
        imagePath: 'assets/images/popcorn_coke.png',
        backgroundColor: const Color(0xff3a8c8c),
      ),
    );

    loadedPromotions.add(
      Promotion(
        title: 'Wednesday Fan Day',
        description:
            'Every Wednesday all showtimes are a single discounted price. Grab a budget-friendly midweek movie!',
        imagePath: 'assets/images/cinema_woman.png',
        backgroundColor: const Color(0xffa168a3),
      ),
    );

    // Update local state once promotions are ready
    setState(() {
      _promotions.addAll(loadedPromotions);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Promotions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ) // Show loading indicator while fetching promotions
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _promotions.length,
              itemBuilder: (context, index) {
                final promotion = _promotions[index];
                return PromotionCard(
                  promotion: promotion,
                ); // Render a card for each promotion
              },
            ),
    );
  }
}

// Dedicated widget to display each promotion nicely
class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: promotion.backgroundColor,
      elevation: 8.0,
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              promotion.imagePath,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              // Provide a graceful fallback if the image cannot be loaded
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white54, size: 50),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  promotion.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Use Offer'),
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
