import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final List<String> messages;

  const DetailsScreen({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Cached Messages:', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(messages[index]));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
