import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.brown.shade900,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '© ${DateTime.now().year} Sheikh Bakery',
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Row(
            children: [
              FooterLink(
                text: 'About',
                onTap: () {
                  // Add navigation
                },
              ),
              const SizedBox(width: 24),
              FooterLink(
                text: 'Contact',
                onTap: () {
                  // Add navigation
                },
              ),
              const SizedBox(width: 24),
              FooterLink(
                text: 'Privacy',
                onTap: () {
                  // Add navigation
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const FooterLink({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Playfair Display',
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    );
  }
}
