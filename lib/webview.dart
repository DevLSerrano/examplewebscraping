import 'dart:collection';
import 'dart:io';
import 'package:chaleno/chaleno.dart';
import 'package:examplewebscraping/model_chaleno_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppWebViewBrowser extends StatefulWidget {
  const InAppWebViewBrowser({Key? key}) : super(key: key);
  @override
  _InAppWebViewBrowserState createState() => _InAppWebViewBrowserState();
}

class _InAppWebViewBrowserState extends State<InAppWebViewBrowser> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;
  String url = '';
  double progress = 0;
  final urlController = TextEditingController();
  String urlToLoading = '';

  @override
  void initState() {
    super.initState();

    //Aqui o url da pagina que quer testar
    urlToLoading =
        'https://www.santander.pt/campanhas/credito/credito-pessoal/simulador-credito';

    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          androidId: 1,
          iosId: '1',
          title: 'Special',
          action: () async {
            debugPrint('Menu item Special clicked!');
            debugPrint(await webViewController?.getSelectedText());
            await webViewController?.clearFocus();
          },
        )
      ],
      options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
      onCreateContextMenu: (hitTestResult) async {
        debugPrint('onCreateContextMenu');
        debugPrint(hitTestResult.extra);
        debugPrint(
          await webViewController?.getSelectedText(),
        );
      },
      onHideContextMenu: () {
        debugPrint('onHideContextMenu');
      },
      onContextMenuActionItemClicked: (contextMenuItemClicked) async {
        var id = (Platform.isAndroid)
            ? contextMenuItemClicked.androidId
            : contextMenuItemClicked.iosId;
        debugPrint('onContextMenuActionItemClicked: ' +
            id.toString() +
            ' ' +
            contextMenuItemClicked.title);
      },
    );

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.indigo[900]!),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  String? decodeQR;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () async {
            //Aqui coletamos os dados com as funcoes disponeis do package

            var parser = await Chaleno().load(url);
            Result? result = parser?.getElementById('montante');
            List<Result>? results = parser?.getElementsByClassName('onlyMoney');

            //retornamos o resultado.
            Navigator.of(context).pop(
              ModelChalenoResult(
                resultById: result,
                resultsByClassName: results,
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    key: webViewKey,
                    //contextMenu: contextMenu,
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(
                        urlToLoading.isEmpty
                            ? 'https://sygpoint.com/index.html#'
                            : urlToLoading,
                      ),
                    ),
                    initialUserScripts: UnmodifiableListView<UserScript>([]),
                    initialOptions: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT,
                      );
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                      var uri = navigationAction.request.url!;

                      if (![
                        'http',
                        'https',
                        'file',
                        'chrome',
                        'data',
                        'javascript',
                        'about'
                      ].contains(uri.scheme)) {
                        if (await canLaunch(url)) {
                          // Launch the App
                          await launch(
                            url,
                          );
                          // and cancel the request
                          return NavigationActionPolicy.CANCEL;
                        }
                      }

                      return NavigationActionPolicy.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                        this.progress = progress / 100;
                        urlController.text = url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      debugPrint(consoleMessage.message);
                    },
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: const Icon(Icons.arrow_back),
                  onPressed: () {
                    webViewController?.goBack();
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    webViewController?.goForward();
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () {
                    webViewController?.reload();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
