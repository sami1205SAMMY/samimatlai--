// 📂 models/commande.dart

class Commande {
  String product;
  int quantity;

  Commande({required this.product, required this.quantity});

  // Convertir un JSON en objet Commande
  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      product: json['product'],
      quantity: json['quantity'],
    );
  }

  // Convertir un objet Commande en JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'quantity': quantity,
    };
  }
}