import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/providers/visit_request_providers.dart';

class RequestVisitSheet extends ConsumerStatefulWidget {
  final String propertyId;
  const RequestVisitSheet({super.key, required this.propertyId});

  @override
  ConsumerState<RequestVisitSheet> createState() => _RequestVisitSheetState();
}

class _RequestVisitSheetState extends ConsumerState<RequestVisitSheet> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Request Visit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Text(
              _selectedDate == null ? 'Select Date' : _selectedDate!.toString(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedDate == null
                ? null
                : () {
                    ref
                        .read(myVisitRequestsProvider.notifier)
                        .create(
                          propertyId: widget.propertyId,
                          requestedDate: _selectedDate!,
                        );
                    Navigator.pop(context);
                  },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}
