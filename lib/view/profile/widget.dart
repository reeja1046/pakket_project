import 'package:flutter/material.dart';
import 'package:pakket/core/constants/color.dart';

class HelpCenterList extends StatefulWidget {
  const HelpCenterList({super.key});

  @override
  State<HelpCenterList> createState() => _HelpCenterListState();
}

class _HelpCenterListState extends State<HelpCenterList> {
  List<bool> _isExpandedList = [false, false, false, false];
  int? selectedAddressIndex;

  final List<String> titles = [
    'Current Address details',
    'Your order history',
    'About us',
    'Contact us',
  ];

  final List<String> responses = [
    'Your saved address for deliveries.',
    'View products you have purchased.',
    'We are a team dedicated to quality.',
    'Reach us at help@pakket.com.',
  ];

  final List<String> savedAddresses = [
    'Home: 123 Street, Kochi',
    'Work: 456 Avenue, Bangalore',
    'Other: 789 Road, Delhi',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: titles.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final isAddressTile = index == 0;

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: _isExpandedList[index],

            trailing: isAddressTile
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: CustomColors.baseColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: const Text(
                        'Add New',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 10,
                    backgroundColor: CustomColors.baseColor,
                    child: Icon(
                      _isExpandedList[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titles[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF636260),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isAddressTile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: CustomColors.baseColor,
                        child: Center(
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
              ],
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpandedList[index] = expanded;
              });
            },
            children: [
              if (isAddressTile) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      for (int i = 0; i < savedAddresses.length; i++)
                        RadioListTile<int>(
                          title: Text(savedAddresses[i]),
                          value: i,
                          groupValue: selectedAddressIndex,
                          onChanged: (val) {
                            setState(() {
                              selectedAddressIndex = val;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: Text(
                    responses[index],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
