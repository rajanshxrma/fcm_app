import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FCMService _fcmService = FCMService();

  String _statusText = 'waiting for a cloud message...';
  String _imagePath = 'assets/images/default.png';
  String? _token;
  final List<Map<String, String>> _messageLog = [];

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    await _fcmService.initialize(onData: _handleMessage);
    final token = await _fcmService.getToken();
    setState(() {
      _token = token;
    });
    debugPrint('fcm token: $token');
  }

  void _handleMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'no title';
    final body = message.notification?.body ?? 'no body';
    final asset = message.data['asset'] ?? 'default';

    setState(() {
      _statusText = title;
      _imagePath = 'assets/images/$asset.png';
      _messageLog.insert(0, {
        'title': title,
        'body': body,
        'asset': asset,
        'action': message.data['action'] ?? '',
      });
    });
  }

  void _copyToken() {
    if (_token != null) {
      Clipboard.setData(ClipboardData(text: _token!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('token copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Activity #14'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // token card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('device token', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _token ?? 'loading...',
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _copyToken,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('copy token'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('message status', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_statusText, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // image card — swaps based on payload asset key
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: const Text('payload image', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Image.asset(
                    _imagePath,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.orange.shade100,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, size: 48, color: Colors.orange),
                              SizedBox(height: 8),
                              Text('image will appear here after a message'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // message log
            const Text('message log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            if (_messageLog.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('no messages received yet — send one from firebase console'),
                ),
              )
            else
              ..._messageLog.map((msg) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(msg['title'] ?? ''),
                      subtitle: Text(
                        '${msg['body']}\nasset: ${msg['asset']}  action: ${msg['action']}',
                      ),
                      isThreeLine: true,
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
