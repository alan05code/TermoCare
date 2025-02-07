import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:termostato/termostato_View.dart';

class TermListView extends StatelessWidget {
  TermListView({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("SELEZIONE DEL TERMOSTATO")),
        foregroundColor: Colors.deepPurpleAccent,
        backgroundColor: Colors.black,
      ),

      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.add_alert),
            title: const Text("Termostato di Alan"),
            subtitle: const Text("Termostato fatto bene"),
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
                );
              },
              icon: const Icon(Icons.add_alert_rounded),
              label: const Text("Go!"),
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
            leading: const Icon(Icons.add_alert),
            title: const Text("Termostato di Berta"),
            subtitle: const Text("Termostato Work in Progress"),
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
                );
              },
              label: const Icon(Icons.accessible),
            ),
          ),
        ],
      ),
    );
  }
}