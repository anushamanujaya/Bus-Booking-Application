import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget destinationCard(String from, String to, {String? imageUrl}) {
      return GestureDetector(
        onTap: () => context.push('/search', extra: {'from': from, 'to': to}),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 36,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 36,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$from → $to',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to search',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bus Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/search'),
              child: const Text('Search Routes'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.push('/search', extra: {'type': 'Luxury'}),
                  child: const Text('Luxury'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      context.push('/search', extra: {'type': 'Semi Luxury'}),
                  child: const Text('Semi Luxury'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      context.push('/search', extra: {'type': 'Normal'}),
                  child: const Text('Normal'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Popular Destinations',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        destinationCard(
                          'Colombo',
                          'Kandy',
                          imageUrl:
                              'https://asocialnomad.com/wp-content/uploads/2024/03/Colombo-to-Kandy.jpg',
                        ),
                        const SizedBox(width: 12),
                        destinationCard(
                          'Galle',
                          'Matara',
                          imageUrl:
                              'https://img.12go.asia/0/fit/1024/0/ce/1/plain/s3://12go-web-static/static/images/upload-media/4302.jpeg',
                        ),
                        const SizedBox(width: 12),
                        destinationCard(
                          'Jaffna',
                          'Anuradhapura',
                          imageUrl:
                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0T0H9INtd89eB6rfrtlhimr6ML-ATVuzxHQ&s',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: const Text(
                        'Plan your trip',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Quickly search routes and book seats',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => context.push('/search'),
                        child: const Text('Start'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://assets.isu.pub/document-structure/221019065736-d333f5dc3bcbec32d8d111b73f9f1175/v1/a236aedac144eba5ec0260a3cb8a8ec5.jpeg',
                      fit: BoxFit.cover,
                      height: 160,
                      width: double.infinity,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        height: 160,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 36,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
