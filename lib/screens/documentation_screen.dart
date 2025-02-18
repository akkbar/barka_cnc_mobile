import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DocumentationScreen extends StatefulWidget {
  const DocumentationScreen({super.key});

  @override
  _DocumentationScreenState createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen> {
  bool isError = false;
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading page. Please check your internet connection.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isError = false;
                      });
                      webViewController?.reload();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://cloud.barka-industries.com/documentation'),
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                ),
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  isError = true;
                });
              },
              onLoadHttpError: (controller, url, statusCode, description) {
                setState(() {
                  isError = true;
                });
              },
            ),
    );
  }
}