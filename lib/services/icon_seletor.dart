import 'package:flutter/material.dart';

class IconSeletor {
  static IconData getIconForTitle(String title) {
    if (title.toLowerCase().contains('car')) {
      return Icons.directions_car;
    } else if (title.toLowerCase().contains('house')) {
      return Icons.house;
    } else if (title.toLowerCase().contains('vacation') ||
        title.toLowerCase().contains('travel')) {
      return Icons.beach_access;
    } else if (title.toLowerCase().contains('education') ||
        title.toLowerCase().contains('study')) {
      return Icons.school;
    } else if (title.toLowerCase().contains('health') ||
        title.toLowerCase().contains('fitness')) {
      return Icons.health_and_safety;
    } else if (title.toLowerCase().contains('wedding')) {
      return Icons.favorite;
    } else if (title.toLowerCase().contains('retirement')) {
      return Icons.hourglass_empty;
    } else if (title.toLowerCase().contains('investment')) {
      return Icons.trending_up;
    } else if (title.toLowerCase().contains('business')) {
      return Icons.business_center;
    } else if (title.toLowerCase().contains('family')) {
      return Icons.family_restroom;
    } else if (title.toLowerCase().contains('charity') ||
        title.toLowerCase().contains('donation')) {
      return Icons.volunteer_activism;
    } else if (title.toLowerCase().contains('gadgets') ||
        title.toLowerCase().contains('tech')) {
      return Icons.devices;
    } else if (title.toLowerCase().contains('shopping')) {
      return Icons.shopping_cart;
    } else if (title.toLowerCase().contains('home improvement')) {
      return Icons.build;
    } else if (title.toLowerCase().contains('garden') ||
        title.toLowerCase().contains('yard')) {
      return Icons.grass;
    } else if (title.toLowerCase().contains('pet')) {
      return Icons.pets;
    } else if (title.toLowerCase().contains('hobby')) {
      return Icons.sports_handball;
    } else if (title.toLowerCase().contains('art')) {
      return Icons.brush;
    } else if (title.toLowerCase().contains('photography') ||
        title.toLowerCase().contains('camera')) {
      return Icons.camera_alt;
    } else if (title.toLowerCase().contains('music') ||
        title.toLowerCase().contains('instrument')) {
      return Icons.music_note;
    } else if (title.toLowerCase().contains('books') ||
        title.toLowerCase().contains('reading')) {
      return Icons.book;
    } else if (title.toLowerCase().contains('cooking') ||
        title.toLowerCase().contains('kitchen')) {
      return Icons.kitchen;
    } else if (title.toLowerCase().contains('exercise') ||
        title.toLowerCase().contains('gym')) {
      return Icons.fitness_center;
    } else if (title.toLowerCase().contains('hiking') ||
        title.toLowerCase().contains('outdoor')) {
      return Icons.terrain;
    } else if (title.toLowerCase().contains('debt') ||
        title.toLowerCase().contains('loan')) {
      return Icons.attach_money;
    } else if (title.toLowerCase().contains('saving')) {
      return Icons.savings;
    } else if (title.toLowerCase().contains('insurance')) {
      return Icons.security;
    } else if (title.toLowerCase().contains('furniture')) {
      return Icons.chair;
    } else if (title.toLowerCase().contains('movie') ||
        title.toLowerCase().contains('film')) {
      return Icons.movie;
    } else if (title.toLowerCase().contains('event') ||
        title.toLowerCase().contains('party')) {
      return Icons.event;
    } else if (title.toLowerCase().contains('makeup') ||
        title.toLowerCase().contains('beauty')) {
      return Icons.face;
    } else if (title.toLowerCase().contains('clothes') ||
        title.toLowerCase().contains('fashion')) {
      return Icons.checkroom;
    } else if (title.toLowerCase().contains('child') ||
        title.toLowerCase().contains('baby')) {
      return Icons.child_care;
    } else if (title.toLowerCase().contains('mortgage')) {
      return Icons.real_estate_agent;
    } else if (title.toLowerCase().contains('boat') ||
        title.toLowerCase().contains('marine')) {
      return Icons.sailing;
    } else if (title.toLowerCase().contains('bike') ||
        title.toLowerCase().contains('cycle')) {
      return Icons.directions_bike;
    } else if (title.toLowerCase().contains('gaming') ||
        title.toLowerCase().contains('console')) {
      return Icons.videogame_asset;
    } else if (title.toLowerCase().contains('job') ||
        title.toLowerCase().contains('career')) {
      return Icons.work;
    } else if (title.toLowerCase().contains('internship')) {
      return Icons.school_outlined;
    } else if (title.toLowerCase().contains('counseling') ||
        title.toLowerCase().contains('therapy')) {
      return Icons.psychology;
    } else if (title.toLowerCase().contains('social') ||
        title.toLowerCase().contains('friends')) {
      return Icons.people;
    } else if (title.toLowerCase().contains('environment') ||
        title.toLowerCase().contains('green')) {
      return Icons.eco;
    } else if (title.toLowerCase().contains('organization')) {
      return Icons.account_tree;
    } else if (title.toLowerCase().contains('freelancing')) {
      return Icons.business;
    } else if (title.toLowerCase().contains('camping')) {
      return Icons.local_florist;
    } else if (title.toLowerCase().contains('baking')) {
      return Icons.cake;
    }
    // Default icon
    return Icons.star;
  }
}
