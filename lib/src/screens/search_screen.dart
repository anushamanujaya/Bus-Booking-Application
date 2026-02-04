import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();

  DateTime? _date;
  String? _selectedClass;
  bool _initialized = false;

  @override
  void dispose() {
    fromCtrl.dispose();
    toCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // If you ever pass "type" from somewhere else, keep this
      final passed =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (passed != null && passed['type'] != null) {
        _selectedClass = passed['type'] as String?;
      }
      _initialized = true;
    }
  }

  num _getPriceByClass(String? type) {
    return switch (type) {
      'Luxury' => 500,
      'Semi Luxury' => 350,
      'Normal' => 250,
      _ => 250,
    };
  }

  void _search() {
    final from = fromCtrl.text.trim();
    final to = toCtrl.text.trim();

    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter From and To")));
      return;
    }

    if (_selectedClass == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a class")));
      return;
    }

    if (_date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please choose a date")));
      return;
    }

    final price = _getPriceByClass(_selectedClass);

    context.push(
      '/trips',
      extra: {
        'from': from,
        'to': to,
        'date': _date!.toIso8601String(),
        'type': _selectedClass,
        'price': price,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Routes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: fromCtrl,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: toCtrl,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Luxury'),
                      selected: _selectedClass == 'Luxury',
                      onSelected: (s) =>
                          setState(() => _selectedClass = s ? 'Luxury' : null),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Semi Luxury'),
                      selected: _selectedClass == 'Semi Luxury',
                      onSelected: (s) => setState(
                        () => _selectedClass = s ? 'Semi Luxury' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Normal'),
                      selected: _selectedClass == 'Normal',
                      onSelected: (s) =>
                          setState(() => _selectedClass = s ? 'Normal' : null),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _date == null
                            ? 'Select date'
                            : _date!.toLocal().toString().split(' ')[0],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                      child: const Text('Choose'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  "Price: Rs. ${_getPriceByClass(_selectedClass)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 16),

                ElevatedButton(onPressed: _search, child: const Text('Search')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
