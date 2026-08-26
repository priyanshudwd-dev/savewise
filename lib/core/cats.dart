import 'package:flutter/material.dart';

import 'theme.dart';

const catKeys = [
  'food',
  'shopping',
  'travel',
  'entertainment',
  'bills',
  'education',
  'home',
  'other',
];

const srcKeys = ['parents', 'salary', 'gift', 'refund', 'other'];

IconData catIcon(String k) => switch (k) {
      'food' => Icons.restaurant_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      'travel' => Icons.directions_car_rounded,
      'entertainment' => Icons.movie_rounded,
      'bills' => Icons.receipt_long_rounded,
      'education' => Icons.school_rounded,
      'home' => Icons.home_rounded,
      _ => Icons.category_rounded,
    };

Color catColor(String k) => switch (k) {
      'food' => C.orange,
      'shopping' => C.violet,
      'travel' => C.blue,
      'entertainment' => C.pink,
      'bills' => C.amber,
      'education' => C.teal,
      'home' => C.green,
      _ => C.subLight,
    };

Color catSoft(String k) => switch (k) {
      'food' => const Color(0xFFFEEADD),
      'shopping' => C.violetSoft,
      'travel' => C.blueSoft,
      'entertainment' => C.pinkSoft,
      'bills' => C.amberSoft,
      'education' => const Color(0xFFD6F2EF),
      'home' => C.greenSoft,
      _ => const Color(0xFFE9EDF3),
    };

IconData srcIcon(String k) => switch (k) {
      'parents' => Icons.family_restroom_rounded,
      'salary' => Icons.payments_rounded,
      'gift' => Icons.card_giftcard_rounded,
      'refund' => Icons.currency_exchange_rounded,
      _ => Icons.more_horiz_rounded,
    };

Color srcColor(String k) => switch (k) {
      'parents' => C.green,
      'salary' => C.blue,
      'gift' => C.pink,
      'refund' => C.violet,
      _ => C.subLight,
    };

Color srcSoft(String k) => switch (k) {
      'parents' => C.greenSoft,
      'salary' => C.blueSoft,
      'gift' => C.pinkSoft,
      'refund' => C.violetSoft,
      _ => const Color(0xFFE9EDF3),
    };
