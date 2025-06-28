import 'package:flutter/material.dart';
import 'package:pakket/controller/cart.dart';
import 'package:pakket/model/product.dart';
import 'package:pakket/view/checkout/checkout.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/widget/snackbar.dart';

void showProductOptionBottomSheet({
  required BuildContext context,
  required ProductDetail product,
}) {
  List<int> quantities = List.filled(product.options.length, 0);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              colors: [Color(0xFFE9ECDB), Color(0xFFE8EBD5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.94, 1.0],
            ),
          ),
          child: _OptionBottomSheetContent(
            product: product,
            quantities: quantities,
          ),
        ),
      );
    },
  );
}

class _OptionBottomSheetContent extends StatefulWidget {
  final ProductDetail product;
  final List<int> quantities;

  const _OptionBottomSheetContent({
    Key? key,
    required this.product,
    required this.quantities,
  }) : super(key: key);

  @override
  State<_OptionBottomSheetContent> createState() =>
      _OptionBottomSheetContentState();
}

class _OptionBottomSheetContentState extends State<_OptionBottomSheetContent> {
  double getTotalAmount() {
    double total = 0.0;
    for (int i = 0; i < widget.product.options.length; i++) {
      total += widget.quantities[i] * widget.product.options[i].offerPrice;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.product.options.length,
            itemBuilder: (context, index) {
              final option = widget.product.options[index];

              return ListTile(
                leading: Image.network(
                  widget.product.thumbnail,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
                title: Text(widget.product.title, maxLines: 1),
                subtitle: IntrinsicHeight(
                  child: Row(
                    children: [
                      Text(
                        option.unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const VerticalDivider(),
                      Text(
                        'Rs.${option.offerPrice.floor()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: widget.quantities[index] == 0
                    ? GestureDetector(
                        onTap: () =>
                            setState(() => widget.quantities[index] = 1),
                        child: Container(
                          height: 30,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: CustomColors.baseColor,
                          ),
                          child: const Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => setState(() {
                              if (widget.quantities[index] > 1) {
                                widget.quantities[index]--;
                              } else {
                                widget.quantities[index] = 0;
                              }
                            }),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '${widget.quantities[index]}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() => widget.quantities[index]++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CustomColors.baseColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Item total: Rs.${getTotalAmount().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () async {
                bool anyAdded = false;

                for (int i = 0; i < widget.product.options.length; i++) {
                  final option = widget.product.options[i];
                  final qty = widget.quantities[i];

                  if (qty > 0) {
                    final response = await addToCart(
                      itemId: widget.product.id,
                      optionId: option.id,
                      quantity: qty,
                    );

                    if (response != null && response.success) {
                      anyAdded = true;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            response?.message ?? 'Failed to add ${option.unit}',
                          ),
                        ),
                      );
                    }
                  }
                }

                if (anyAdded) {
                  showSuccessSnackbar(context, 'Added to cart successfully!');

                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(fromBottomNav: false),
                    ),
                  );
                } else {
                  Navigator.of(context).pop();
                  showSuccessSnackbar(
                    context,
                    'Please select at least one option',
                  );
                }
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
