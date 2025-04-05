// 📂 models/produit.dart

class Produit {
  String name;
  double price;

  Produit({required this.name, required this.price});

  // Convertir un JSON en objet Produit
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      name: json['name'],
      price: json['price'].toDouble(),
    );
  }

  // Convertir un objet Produit en JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}