import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pakket/controller/product.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/model/product.dart';
import 'package:pakket/view/product/productdetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchDetails extends StatefulWidget {
  const SearchDetails({super.key});

  @override
  State<SearchDetails> createState() => _SearchDetailsState();
}

class _SearchDetailsState extends State<SearchDetails> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> fetchAllProducts() async {
    setState(() => isLoading = true);
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('https://pakket-dev.vercel.app/api/app/product'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allProducts = (data['products'] as List)..shuffle();
        setState(() => searchResults = allProducts.take(8).toList());
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> searchProducts(String query) async {
    setState(() => isLoading = true);
    if (query.isEmpty) return fetchAllProducts();

    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse(
          'https://pakket-dev.vercel.app/api/app/search?q=${Uri.encodeComponent(query)}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => searchResults = data['result']);
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildProductCard(dynamic product) {
    final option = (product['options'] != null && product['options'].isNotEmpty)
        ? product['options'][0]
        : null;

    return GestureDetector(
      onTap: () async {
        final detail = await fetchProductDetail(product['productId']);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetails(details: detail)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: CustomColors.textformfield,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: CustomColors.baseContainer,
              ),
              padding: const EdgeInsets.all(10),
              child: Image.network(
                product['thumbnail'] ?? '',
                height: 80,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            Text(
              product['title'] ?? 'No title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Divider(indent: 10, endIndent: 10),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    option?['unit'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const VerticalDivider(),
                  Text(
                    'Rs. ${option?['basePrice'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
              width: MediaQuery.of(context).size.width * 0.3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.baseColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  (product['options']?.length ?? 0) == 1
                      ? 'Add'
                      : '${product['options'].length} options',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextFormField(
                        controller: _searchController,
                        onChanged: searchProducts,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Image.asset('assets/home/icon.png'),
                          filled: true,
                          fillColor: CustomColors.textformfield,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
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
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 45,
                    width: 50,
                    decoration: BoxDecoration(
                      color: CustomColors.baseColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => searchProducts(_searchController.text),
                      icon: Image.asset('assets/home/setting-4.png'),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (searchResults.isEmpty)
                const Center(child: Text("No products found"))
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (_, i) => _buildProductCard(searchResults[i]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
