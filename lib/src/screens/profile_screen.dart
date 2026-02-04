import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      await UserService.uploadProfileImage(File(picked.path));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile photo updated ")));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _shortRefFromDocId(String docId) {
    final short = docId.replaceAll('-', '').toUpperCase();
    return 'BB-${short.length >= 6 ? short.substring(0, 6) : short}';
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return "$y-$m-$d  $hh:$mm";
    }
    return "N/A";
  }

  num _readNum(dynamic v) {
    if (v is num) return v;
    return num.tryParse((v ?? '0').toString()) ?? 0;
  }

  String _readSeats(Map<String, dynamic> data) {
    final seats = data['seats'];
    if (seats is List) {
      final list = seats.map((e) => e.toString()).toList();
      if (list.isEmpty) return "N/A";
      list.sort();
      return list.join(', ');
    }
    final seatNo = (data['seatNo'] ?? '').toString().trim();
    return seatNo.isEmpty ? "N/A" : seatNo;
  }

  num _readPrice(Map<String, dynamic> data) {
    return _readNum(data['totalPrice'] ?? data['price'] ?? 0);
  }

  // Prefer Firestore refNo, fallback to docId short
  String _readRefNo(String docId, Map<String, dynamic> data) {
    final ref = (data['refNo'] ?? '').toString().trim();
    if (ref.isNotEmpty) return ref;
    return _shortRefFromDocId(docId);
  }

  void _showTicketPopup({
    required String docId,
    required Map<String, dynamic> data,
  }) {
    final tripId = (data['tripId'] ?? '').toString();
    final route = (data['route'] ?? '').toString();
    final busNo = (data['busNo'] ?? '').toString();
    final createdAt = _formatDate(data['createdAt']);

    final seatsText = _readSeats(data);
    final totalPrice = _readPrice(data);
    final refNo = _readRefNo(docId, data);

    // Optional: show price per seat if exists
    final pricePerSeat = data.containsKey('pricePerSeat')
        ? _readNum(data['pricePerSeat'])
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined),
                  const SizedBox(width: 8),
                  const Text(
                    "Bus Ticket",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      refNo,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _ticketRow("Reference No", refNo),
                      _ticketRow("Trip ID", tripId.isEmpty ? "N/A" : tripId),
                      _ticketRow("Seat(s)", seatsText),
                      _ticketRow("Route", route.isEmpty ? "N/A" : route),
                      _ticketRow("Bus No", busNo.isEmpty ? "N/A" : busNo),

                      if (pricePerSeat != null)
                        _ticketRow("Price/Seat", "Rs. $pricePerSeat"),

                      _ticketRow("Total Price", "Rs. $totalPrice"),
                      _ticketRow("Booked At", createdAt),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text("OK"),
                ),
              ),

              const SizedBox(height: 6),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Reference: $refNo")),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text("Show Reference"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not signed in")));
    }

    final name = (user.displayName ?? '').trim();
    final email = (user.email ?? '').trim();
    final photoUrl = user.photoURL ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl.isEmpty
                        ? Text(
                            (name.isNotEmpty
                                    ? name[0]
                                    : email.isNotEmpty
                                    ? email[0]
                                    : '?')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: IconButton(
                      onPressed: _uploading ? null : _changePhoto,
                      icon: _uploading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : "No name",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(email),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "History",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('history')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text("No bookings yet"),
                    subtitle: Text("Tap booked seats here to view the ticket."),
                  ),
                );
              }

              return Column(
                children: docs.map((d) {
                  final data = d.data();

                  final seatsText = _readSeats(data);
                  final totalPrice = _readPrice(data);
                  final tripId = (data['tripId'] ?? '').toString();
                  final refNo = _readRefNo(d.id, data);

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_seat),
                      title: Text("Seat: $seatsText  •  Rs. $totalPrice"),
                      subtitle: Text(
                        "Trip: ${tripId.isEmpty ? 'N/A' : tripId}  •  Ref: $refNo",
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showTicketPopup(docId: d.id, data: data),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
