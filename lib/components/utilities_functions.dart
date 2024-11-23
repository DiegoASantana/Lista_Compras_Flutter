import 'package:flutter/material.dart';
import 'package:lista_compras_flutter/data/premium_service.dart';

class Dialogs {
  static Future<void> showPremiumRequiredDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 30,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Recurso Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 30,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Adquira agora seu acesso premium e tenha acesso a essa e outras funções especiais!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 130,
                height: 140,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset('assets/images/stick_premium.png',
                        fit: BoxFit.cover)), // Corrigido para usar uma imagem padrão se vazio
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('Acesso vitalício por apenas R\$ 4,99',
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  bool success = await PremiumService.purchasePremiumAccess();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compra realizada com sucesso!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Falha ao realizar a compra.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Adquirir Acesso Premium'),
              ),
            ),
          ],
        );
      },
    );
  }
}
