// 📂 main.dart

import 'models/produit.dart';
import 'models/commande.dart';
import 'services/api_service.dart';

void main() async {
  final String baseUrl = 'http://localhost:3000';
  final ApiService apiService = ApiService(baseUrl: baseUrl);

  try {
    // 📢 Récupération des produits
    List<Produit> produits = await apiService.getProducts();
    print('📦 Produits disponibles:');
    for (var produit in produits) {
      print('🛒 ${produit.name} - 💰 ${produit.price} DH');
    }

    // ➕ Ajout d'un produit
    final Produit newProduit = Produit(name: 'MacBook Air', price: 15000);
    await apiService.addProduct(newProduit);
    print('✅ Produit ajouté avec succès!');

    // 📢 Récupération des commandes
    List<Commande> commandes = await apiService.getOrders();
    print('📜 Commandes existantes:');
    for (var commande in commandes) {
      print('📦 Produit: ${commande.product}, Quantité: ${commande.quantity}');
    }

    // ➕ Ajout d'une commande
    final Commande newCommande = Commande(product: 'MacBook Air', quantity: 1);
    await apiService.addOrder(newCommande);
    print('✅ Commande créée avec succès!');

  } catch (e) {
    print('❌ Erreur: $e');
  }
}