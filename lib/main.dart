import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FreightApp());
}

class FreightApp extends StatelessWidget {
  const FreightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freight Rates',
      theme: ThemeData(
        primaryColor: const Color(0xFF0066FF),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const FreightSearchScreen(),
    );
  }
}

class FreightSearchScreen extends StatefulWidget {
  const FreightSearchScreen({super.key});

  @override
  State<FreightSearchScreen> createState() => _FreightSearchScreenState();
}

class _FreightSearchScreenState extends State<FreightSearchScreen> {
  final TextEditingController originController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  String? origin;
  String? destination;
  String? commodity;
  DateTime? cutOffDate;
  bool includeNearbyOrigin = false;
  bool includeNearbyDestination = false;
  bool isFCL = true;
  String? containerSize;
  int? boxCount;
  double? weight;

  Future<List<String>> _fetchSuggestions(String query) async {
    final response = await http.get(Uri.parse('https://countriesnow.space/api/v0.1/countries/cities/q?country=India'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data
          .map<String>((city) => city.toString())
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      return ['Could not suggest'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Search the best Freight Rates',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('History'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Origin Autocomplete
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: originController,
                  decoration: InputDecoration(
                    labelText: 'Origin',
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: Checkbox(
                      value: includeNearbyOrigin,
                      onChanged: (val) {
                        setState(() {
                          includeNearbyOrigin = val!;
                        });
                      },
                    ),
                  ),
                ),
                suggestionsCallback: _fetchSuggestions,
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(suggestion),
                ),
                onSuggestionSelected: (suggestion) {
                  originController.text = suggestion;
                  setState(() => origin = suggestion);
                },
                noItemsFoundBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No matches found'),
                ),
              ),
              const SizedBox(height: 16),

              // Destination Autocomplete
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: Checkbox(
                      value: includeNearbyDestination,
                      onChanged: (val) {
                        setState(() {
                          includeNearbyDestination = val!;
                        });
                      },
                    ),
                  ),
                ),
                suggestionsCallback: _fetchSuggestions,
                itemBuilder: (context, suggestion) => ListTile(
                  title: Text(suggestion),
                ),
                onSuggestionSelected: (suggestion) {
                  destinationController.text = suggestion;
                  setState(() => destination = suggestion);
                },
                noItemsFoundBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('No matches found'),
                ),
              ),
              const SizedBox(height: 16),

              // Commodity & Cut-off Date
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: commodity,
                      decoration: const InputDecoration(
                        labelText: 'Commodity',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Electronics', 'Furniture', 'Textile']
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => commodity = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => cutOffDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Cut-off Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cutOffDate == null
                                  ? 'Select date'
                                  : '${cutOffDate!.day}/${cutOffDate!.month}/${cutOffDate!.year}',
                            ),
                            const Icon(Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Shipment Type Toggle
              ToggleButtons(
                isSelected: [isFCL, !isFCL],
                onPressed: (index) {
                  setState(() => isFCL = index == 0);
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('FCL'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('LCL'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Container Info
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Container Size',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => containerSize = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Box Count',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => boxCount = int.tryParse(val)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => weight = double.tryParse(val)),
              ),

              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

