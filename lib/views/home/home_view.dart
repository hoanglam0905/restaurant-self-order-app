import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🏠 Header
              Text(
                "Bon Appétit",
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Serif',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "450 Le Van Viet Street, Tang Nhon Phu A Ward,\nDistrict 9",
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 16),

              /// 🎉 Banner
              Container(
                height: 160,
                width: double.infinity, // 🔥 thêm để full ngang
                margin: const EdgeInsets.symmetric(
                  vertical: 8,
                ), // thêm nhẹ cho thoáng
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/home/banner2.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),

                    /// 🔥 đổi overlay đen thành gradient cho đẹp hơn
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.3),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Up to 40% OFF",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24, // 🔥 tăng size cho nổi hơn
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "ON YOUR FIRST ORDER",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () {},
                          child: const Text("ORDER NOW"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// 👋 Greeting
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    const TextSpan(text: "Good Morning "),
                    TextSpan(
                      text: "Customer!",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "We will deliver your food to your table:",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("A6"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// ⚡ Action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.person,
                      title: "Call Staff",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.credit_card,
                      title: "Call Payment",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🍽️ View menu button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "View menu – Orders 🍽️",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 20),

              /// ⭐ Today Special
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Today’s Special",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),

              const SizedBox(height: 12),

              /// 🧁 Food list
              Row(
                children: [
                  Expanded(
                    child: _buildFoodItem(
                      image: "assets/images/home/TodaySpecial1.jpg",
                      category: "Cake",
                      name: "Lemon Macarons",
                      price: "10.99",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFoodItem(
                      image: "assets/images/home/TodaySpecial2.jpg",
                      category: "Meat",
                      name: "Beef-steak",
                      price: "10.99",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧩 Action Card
  Widget _buildActionCard({required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }

  /// 🍔 Food Item
  Widget _buildFoodItem({
    required String image,
    required String category,
    required String name,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 8),

          Text(category, style: TextStyle(color: Colors.grey)),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("\$$price"),
        ],
      ),
    );
  }
}
