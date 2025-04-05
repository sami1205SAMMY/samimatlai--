// 📂 services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/produit.dart';
import '../models/commande.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // 📌 Récupérer tous les produits
  Future<List<Produit>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Produit.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des produits');
    }
  }

  // 📌 Ajouter un produit
  Future<void> addProduct(Produit produit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(produit.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout du produit');
    }
  }

  // 📌 Récupérer toutes les commandes
  Future<List<Commande>> getOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Commande.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des commandes');
    }
  }

  // 📌 Ajouter une commande
  Future<void> addOrder(Commande commande) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode(commande.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la création de la commande');
    }
  }
}