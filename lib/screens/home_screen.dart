import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_storage/get_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = GetStorage();
  String _savedUrl = 'https://example.com'; // Default URL
  bool isError = false;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  // Load saved URL from GetStorage
  _loadSavedUrl() {
    setState(() {
      _savedUrl = box.read('savedText') ?? 'https://example.com';
    });
    print('Loaded saved URL: $_savedUrl');
  }

  Future<void> _refreshWebView() async {
    if (webViewController != null) {
      webViewController!.reload();
    }
  }

  // Validate URL
  bool _isValidUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  @override
  Widget build(BuildContext context) {
    // Concatenate _savedUrl with 'dashboard/simpleDashboard'
    final fullUrl = Uri.parse(_savedUrl).resolve('dashboard/simpleDashboard').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWebView,
          ),
        ],
      ),
      body: _isValidUrl(fullUrl) && !isError
          ? RefreshIndicator(
              onRefresh: _refreshWebView,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(fullUrl),
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  print('Page started loading: $url');
                },
                onLoadStop: (controller, url) async {
                  print('Page finished loading: $url');
                },
                onReceivedError: (controller, request, error) {
                  setState(() {
                    isError = true;
                  });
                  print('WebView Error: $error');
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  setState(() {
                    isError = true;
                  });
                  print('HTTP Error: $errorResponse');
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Please set a valid hostname or make sure your device is connected.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isError = false;
                      });
                      _refreshWebView();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
    );
  }
}