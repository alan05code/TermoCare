import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:termostato/termostato_View.dart';

class TermListViewDialog extends StatelessWidget {
  TermListViewDialog({super.key});

  final Map<String, Map<String, String>> arrTermostati = {
    "Alan": {
      "url": dotenv.env['AIO_URL']!,
      "user": dotenv.env['AIO_USER_ALAN']!,
      "psw": dotenv.env['AIO_PSW_ALAN']!,
    },
    "Davide": {
      "url": dotenv.env['AIO_URL']!,
      "user": dotenv.env['AIO_USER_DAVIDE']!,
      "psw": dotenv.env['AIO_PSW_DAVIDE']!,
    },
    "Marco": {
      "url": dotenv.env['AIO_URL']!,
      "user": dotenv.env['AIO_USER_MARCO']!,
      "psw": dotenv.env['AIO_PSW_MARCO']!,
    },
  };

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      content: Column(
        children: [
          ListTile(
            title: const Text("Termostato di Alan"),
            trailing: FloatingActionButton.extended(
              heroTag: "Alan",
              onPressed: () {
                var curTermostato = arrTermostati['Alan']!;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                      TermostatoView(
                        name: "Alan",
                        url: curTermostato["url"]!,
                        user: curTermostato["user"]!,
                        psw: curTermostato["psw"]!,
                      ),
                  ),
                ).then((_) {
                  // Rimuovi la freccia per tornare indietro
                  Future.delayed(Duration.zero, () {
                    Navigator.pop(context);
                  });
                });
              },
              label: const Icon(Icons.arrow_forward),
            ),
          ),
          ListTile(
            title: const Text("Termostato di Davide"),
            trailing: FloatingActionButton.extended(
              heroTag: "Davide",
              onPressed: () {
                var curTermostato = arrTermostati['Davide']!;
                showDialog(
                  context: context,
                  builder: (_) => TermostatoView(
                        name: "Davide",
                        url: curTermostato["url"]!,
                        user: curTermostato["user"]!,
                        psw: curTermostato["psw"]!,
                      )
                ).then((_) {
                  // Rimuovi la freccia per tornare indietro
                  Future.delayed(Duration.zero, () {
                    Navigator.pop(context);
                  });
                });
              },
              label: const Icon(Icons.arrow_forward),
            ),
          ),
          ListTile(
            title: const Text("Termostato di Berta"),
            trailing: FloatingActionButton.extended(
              heroTag: "Marco",
              onPressed: () {
                var curTermostato = arrTermostati['Marco']!;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                      TermostatoView(
                        name: "Marco",
                        url: curTermostato["url"]!,
                        user: curTermostato["user"]!,
                        psw: curTermostato["psw"]!,
                      ),
                  ),
                ).then((_) {
                  // Rimuovi la freccia per tornare indietro
                  Future.delayed(Duration.zero, () {
                    Navigator.pop(context);
                  });
                });
              },
              label: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}
