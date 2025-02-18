import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({super.key});

  @override
  _AppSettingScreenState createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  final TextEditingController _controller = TextEditingController();
  final box = GetStorage();
  String _savedText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedText();
  }

  _loadSavedText() async {
    setState(() {
      _isLoading = true;
    });
    try {
      setState(() {
        _savedText = box.read('savedText') ?? '';
        _controller.text = _savedText;
      });
      print('Loaded saved text: $_savedText');
    } catch (e) {
      print('Error loading saved text: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _saveText() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await box.write('savedText', _controller.text);
      setState(() {
        _savedText = _controller.text;
      });
      print('Saved text: $_savedText');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text saved successfully!')),
      );
    } catch (e) {
      print('Error saving text: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save text. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _clearText() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await box.remove('savedText');
      setState(() {
        _savedText = '';
        _controller.clear();
      });
      print('Cleared saved text');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text cleared successfully!')),
      );
    } catch (e) {
      print('Error clearing text: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear text. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter hostname',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _saveText,
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _clearText,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Text('Saved: $_savedText'),
          ],
        ),
      ),
    );
  }
}