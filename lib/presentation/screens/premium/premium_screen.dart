import 'package:flutter/material.dart';
import 'widgets/benefit_card.dart';
import 'widgets/pricing_card.dart';
import '../../widgets/buttons/primary_button.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Go Premium'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Unlock Premium Features',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const BenefitCard(
                  icon: Icons.all_inclusive,
                  title: 'Unlimited Habits',
                  description: 'Create as many habits as you need',
                ),
                const SizedBox(height: 12),
                const BenefitCard(
                  icon: Icons.shield,
                  title: 'Streak Shields',
                  description: 'Protect your streaks with 3 shields per month',
                ),
                const SizedBox(height: 12),
                const BenefitCard(
                  icon: Icons.beach_access,
                  title: 'Vacation Mode',
                  description: '30 vacation days per year',
                ),
                const SizedBox(height: 12),
                const BenefitCard(
                  icon: Icons.block,
                  title: 'No Ads',
                  description: 'Enjoy ad-free experience',
                ),
                const SizedBox(height: 32),
                const PricingCard(
                  tier: 'Monthly',
                  price: '\$4.99',
                  period: 'per month',
                ),
                const SizedBox(height: 12),
                const PricingCard(
                  tier: 'Annual',
                  price: '\$39.99',
                  period: 'per year',
                  savings: 'Save 33%',
                  isPopular: true,
                ),
                const SizedBox(height: 12),
                const PricingCard(
                  tier: 'Lifetime',
                  price: '\$99.99',
                  period: 'one-time',
                  savings: 'Best Value',
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Start Free Trial',
                  onPressed: () {},
                  icon: Icons.rocket_launch,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
