import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/search/widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchDetails extends StatefulWidget {
  const SearchDetails({super.key});

  @override
  State<SearchDetails> createState() => _SearchDetailsState();
}

class _SearchDetailsState extends State<SearchDetails> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  Future<void>? _currentRequest;

  @override
  void initState() {
    super.initState();
    _fetchAllProducts();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> _fetchAllProducts() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('https://pakket-dev.vercel.app/api/app/product'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final products = (data['products'] ?? []) as List;
        products.shuffle();
        if (mounted) {
          setState(() => searchResults = products.take(8).toList());
        }
      }
    } catch (e) {
      Get.snackbar('Error!!', "Error fetching products: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _searchProducts(String query) async {
    if (_currentRequest != null) return; // prevent multiple API calls

    if (query.isEmpty) {
      _fetchAllProducts();
      return;
    }

    setState(() => isLoading = true);
    final token = await _getToken();

    _currentRequest = http
        .get(
          Uri.parse(
            'https://pakket-dev.vercel.app/api/app/search?q=${Uri.encodeComponent(query)}',
          ),
          headers: {'Authorization': 'Bearer $token'},
        )
        .then((response) {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (mounted) {
              setState(() => searchResults = data['result'] ?? []);
            }
          }
        })
        .catchError((e) {
          Get.snackbar('Error!!', "Search error: $e");
        })
        .whenComplete(() {
          _currentRequest = null;
          if (mounted) setState(() => isLoading = false);
        });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent screen resize
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColors.scaffoldBgClr,
        title: const Text(
          'Search in detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.withOpacity(0.3), height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            SizedBox(
              height: 45,
              child: TextFormField(
                controller: searchController,
                onChanged: _searchProducts,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Image.asset('assets/home/icon.png'),
                  filled: true,
                  fillColor: CustomColors.textformfield,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: CustomColors.baseColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product Grid
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchResults.isEmpty
                  ? const Center(child: Text("No products found"))
                  : OrientationBuilder(
                      builder: (context, orientation) {
                        final isPortrait = orientation == Orientation.portrait;
                        final crossAxisCount = isPortrait ? 2 : 3;
                        final aspectRatio = isPortrait ? 0.68 : 1.1;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: searchResults.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: aspectRatio,
                              ),
                          itemBuilder: (_, i) =>
                              buildProductCard(searchResults[i], context),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
