import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aura_frontend/screens/property_page.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.house_fill,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Your location",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.location_solid,
                              color: Colors.black, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "San Francisco, CA",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_down, size: 14),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.bell, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white10
                            : Colors.grey.shade100.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              style: theme.textTheme.bodyMedium,
                              decoration: const InputDecoration(
                                hintText: "Search properties...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.slider_horizontal_3),
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  children: [
                    // HEADER TEXT
                    Text(
                      "Discover\nmodern listings",
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PROPERTY CARDS
                    ...List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: PropertyCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                                pageBuilder: (_, __, ___) =>
                                    PropertyPage(image: "assets/img1.jpg"),
                                transitionsBuilder:
                                    (_, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 0.08);
                                  const end = Offset.zero;
                                  final curve = Curves.easeInOutCubic;

                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: HomeBottomNavBar(),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key, this.onTap});
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: "property-image-$hashCode",
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.asset(
                  "assets/img1.jpg",
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Modern Villa in California",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.location_solid,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Malibu Beach • 2.3 km",
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.bed_double, size: 16),
                      const SizedBox(width: 4),
                      Text("3 Beds", style: theme.textTheme.bodySmall),
                      const SizedBox(width: 16),
                      const Icon(CupertinoIcons.battery_0, size: 16),
                      const SizedBox(width: 4),
                      Text("2 Baths", style: theme.textTheme.bodySmall),
                      const Spacer(),
                      Text(
                        "\$250,000",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
