import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../services/user_service.dart';

class SeatMapScreen extends StatefulWidget {
  final String? tripId;

  // route details come from Search
  final String? from;
  final String? to;

  // optional (trip fare)
  final num? price;

  const SeatMapScreen({super.key, this.tripId, this.from, this.to, this.price});

  @override
  State<SeatMapScreen> createState() => _SeatMapScreenState();
}

class _SeatMapScreenState extends State<SeatMapScreen> {
  final int rows = 4;
  final int cols = 10;
  final Set<String> selected = {};

  bool _booking = false;

  final num defaultSeatPrice = 250;

  String _generateBusNo() {
    final r = Random();
    return (r.nextInt(9000) + 1000).toString(); // 1000 - 9999
  }

  String _generateRefNo(String busNo) {
    final r = Random();
    final suffix = (r.nextInt(9000) + 1000).toString();
    return "BB-$busNo-$suffix"; // example: BB-9087-1734
  }

  Future<void> _proceedToCheckout() async {
    // must be logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to book seats")),
      );
      context.go('/signin');
      return;
    }

    final from = (widget.from ?? '').trim();
    final to = (widget.to ?? '').trim();

    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Route not found. Please search From and To again."),
        ),
      );
      return;
    }

    final route = "$from → $to";
    final busNo = _generateBusNo();
    final refNo = _generateRefNo(busNo);

    final seatPrice = widget.price ?? defaultSeatPrice;
    final seats = selected.toList()..sort();
    final totalPrice = seatPrice * seats.length;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: Text(
          "Reference: $refNo\n"
          "Route: $route\n"
          "Bus No: $busNo\n"
          "Trip: ${widget.tripId ?? 'N/A'}\n"
          "Seats: ${seats.join(', ')}\n"
          "Price per seat: Rs. $seatPrice\n"
          "Total: Rs. $totalPrice\n\n"
          "Confirm booking?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _booking = true);

    try {
      //Save ONE history ticket
      await UserService.addTicketHistory(
        tripId: widget.tripId ?? '',
        from: from,
        to: to,
        route: route,
        busNo: busNo,
        refNo: refNo,
        seats: seats,
        pricePerSeat: seatPrice,
        totalPrice: totalPrice,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booked Ref: $refNo")));

      setState(() => selected.clear());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booking failed: $e")));
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final from = (widget.from ?? '').trim();
    final to = (widget.to ?? '').trim();
    final routeText = (from.isNotEmpty && to.isNotEmpty)
        ? "$from → $to"
        : "Route: N/A";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Seats${widget.tripId != null ? ' • ${widget.tripId}' : ''}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.route),
                title: Text(routeText),
                subtitle: Text(
                  "Price/seat: Rs. ${widget.price ?? defaultSeatPrice}",
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: 1.2,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final seatNo = 'S${index + 1}';
                  final isSelected = selected.contains(seatNo);

                  return GestureDetector(
                    onTap: _booking
                        ? null
                        : () => setState(() {
                            if (isSelected) {
                              selected.remove(seatNo);
                            } else {
                              selected.add(seatNo);
                            }
                          }),
                    child: Card(
                      color: isSelected ? Colors.green : Colors.grey[200],
                      child: Center(
                        child: Text(
                          seatNo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "Selected: ${selected.toList()..sort()}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selected.isEmpty || _booking)
                    ? null
                    : _proceedToCheckout,
                child: _booking
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
