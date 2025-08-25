// all_grocery_controller.dart
import 'package:get/get.dart';
import 'package:pakket/controller/category.dart';
import 'package:pakket/controller/randomproduct.dart';
import 'package:pakket/model/allcategory.dart';

class AllGroceryController extends GetxController {
  var categories = <Category>[].obs;
  var products = <CategoryProduct>[].obs;
  var selectedCategoryId = ''.obs;
  var selectedCategoryName = ''.obs;
  var isLoading = true.obs;

  String initialCategory;

  AllGroceryController({required this.initialCategory});

  @override
  void onInit() {
    fetchInitialData();
    super.onInit();
  }

  Future<void> fetchInitialData() async {
    try {
      final fetchedCategories = await fetchCategories();
      categories.value = fetchedCategories;

      final matchingCategory = fetchedCategories.firstWhere(
        (category) =>
            category.name.toLowerCase() == initialCategory.toLowerCase(),
        orElse: () => fetchedCategories.first,
      );

      selectedCategoryId.value = matchingCategory.id;
      selectedCategoryName.value = matchingCategory.name;

      if (matchingCategory.name.toLowerCase() == 'all items') {
        await fetchAllProducts().then((fetchedProducts) {
          products.value = fetchedProducts;
          isLoading.value = false;
        });
      } else {
        await fetchProductsByCategory(matchingCategory.id).then((
          fetchedProducts,
        ) {
          products.value = fetchedProducts;
          isLoading.value = false;
        });
      }
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<void> fetchProducts(String categoryId, String categoryName) async {
    isLoading.value = true;
    selectedCategoryId.value = categoryId;
    selectedCategoryName.value = categoryName;

    try {
      if (categoryName.toLowerCase() == 'all items') {
        final fetchedProducts = await fetchRandomProducts(8);
        products.value = fetchedProducts;
      } else {
        final fetchedProducts = await fetchProductsByCategory(categoryId);
        products.value = fetchedProducts;
      }
    } catch (e) {
      Get.snackbar('Error!!','Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
