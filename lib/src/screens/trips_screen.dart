import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TripsScreen extends StatelessWidget {
  final Map<String, dynamic>? args;
  const TripsScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final passedArgs =
        args ??
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final from = (passedArgs?['from'] ?? '').toString();
    final to = (passedArgs?['to'] ?? '').toString();

    // Dummy trips list
    final trips = List.generate(
      5,
      (i) => {'id': 'trip_$i', 'time': '${8 + i}:00', 'fare': 200 + (i * 50)},
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final t = trips[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text('$from → $to • ${t['time']}'),
              subtitle: Text('Fare: Rs. ${t['fare']}'),
              trailing: ElevatedButton(
                child: const Text('Select seats'),
                onPressed: () {
                  context.push(
                    '/seatmap',
                    extra: {
                      'tripId': t['id'],
                      'from': from,
                      'to': to,
                      'price': t['fare'],
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
