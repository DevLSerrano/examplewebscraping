import 'package:chaleno/chaleno.dart';
import 'package:flutter/material.dart';

import 'model_chaleno_result.dart';
import 'webview.dart';

//Home
class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Webscraping'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Go To Webview'),
          onPressed: () async {
            await Navigator.push<ModelChalenoResult>(
              context,
              MaterialPageRoute<ModelChalenoResult>(
                builder: (BuildContext context) => InAppWebViewBrowser(),
              ),
            ).then((value) {
              //Resposta da pagina WebView
              print('O retorno foi: \n$value');
              if (value != null) {
                print(
                    'Element ID: \n${value.resultById?.text ?? value.resultById?.title}');
                for (Result item in value.resultsByClassName ?? []) {
                  print('Item: ${item.text} \n');
                }
              }
            });
          },
        ),
      ),
    );
  }
}
