import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bluetoothairmousekeyboard/data/database_box.dart';
import 'package:bluetoothairmousekeyboard/data/databases.dart';
import 'package:bluetoothairmousekeyboard/in_app_purchase/general_values.dart';

// Your existing helper classes and functions (DatabaseBox, getTitleFromProductId, etc.)
// should be available in your project for this to work.

class DialogDetailsActivePlan extends StatefulWidget {
  const DialogDetailsActivePlan({super.key});

  @override
  State<DialogDetailsActivePlan> createState() =>
      _DialogDetailsActivePlanState();
}

class _DialogDetailsActivePlanState extends State<DialogDetailsActivePlan> {
  PurchaseDetailsSave? _activePlan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivePlan();
  }

  Future<void> _loadActivePlan() async {
    final plan = await DatabaseBox.getActivePlanWithRenewal();
    setState(() {
      _activePlan = plan;
      _loading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd MMM yyyy, hh:mm a").format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Gradient
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.primary,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Active Subscription",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoTile(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    label: "Subscribed Plan",
                    value: getTitleFromProductId(_activePlan!.productID),
                  ),
                  // _buildInfoTile(
                  //   context,
                  //   icon: Icons.receipt_long_outlined,
                  //   label: "Purchase ID",
                  //   value: _activePlan!.purchaseID.toString(),
                  // ),
                  if (Platform.isIOS)
                    _buildInfoTile(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: "Transaction Date",
                      value: _formatDate(_activePlan!.transactionDate),
                    ),
                  if (Platform.isIOS)
                    _buildInfoTile(
                      context,
                      icon: Icons.date_range_outlined,
                      label: "Expiry Date",
                      value: _formatDate(_activePlan!.expireDate),
                    ),
                  _buildInfoTile(
                    context,
                    icon: Icons.check_circle_outline,
                    label: "Status",
                    value: _activePlan!.status ? "✅ Active" : "❌ Expired",
                    trailing: _activePlan!.status
                        ? const Chip(
                            label: Text("Active"),
                            backgroundColor: Colors.teal,
                          )
                        : const Chip(
                            label: Text("Expired"),
                            backgroundColor: Colors.redAccent,
                          ),
                  ),

                  if (_activePlan!.autoRenewProductId.isNotEmpty &&
                      Platform.isIOS) ...[
                    const Divider(height: 32),
                    Text(
                      "Next Renewal",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.update,
                      label: "Upcoming Plan",
                      value: getTitleFromProductId(
                        _activePlan!.autoRenewProductId,
                      ),
                    ),
                    _buildInfoTile(
                      context,
                      icon: Icons.next_plan_outlined,
                      label: "Renewal Date",
                      value: _formatDate(_activePlan!.nextRenewalDate),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
