import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/data/models/booking_model.dart';
import 'package:pet_adoption_app/presentation/providers/booking_provider.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

class AdminBookingRequestsScreen extends ConsumerStatefulWidget {
  const AdminBookingRequestsScreen({super.key});

  @override
  ConsumerState<AdminBookingRequestsScreen> createState() =>
      _AdminBookingRequestsScreenState();
}

class _AdminBookingRequestsScreenState
    extends ConsumerState<AdminBookingRequestsScreen> {
  static const Color _accent = Color(0xFFF67D2C);
  String _selectedFilter = 'all';

  List<BookingModel> _filterBookings(List<BookingModel> bookings) {
    if (_selectedFilter == 'all') return bookings;
    return bookings.where((b) => b.status == _selectedFilter).toList();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _refresh() async {
    ref.invalidate(adminBookingsProvider);
    ref.invalidate(pendingBookingsProvider);
    await ref.read(adminBookingsProvider.future);
  }

  Future<void> _approveBooking(String bookingId) async {
    final notes = await showDialog<String?>(
      context: context,
      builder: (_) => const _ApprovalDialog(),
    );

    if (!mounted) return;

    final success = await ref
        .read(approveBookingProvider.notifier)
        .approveBooking(bookingId: bookingId, adminNotes: notes);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Booking approved' : 'Unable to approve booking',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      await _refresh();
    }
  }

  Future<void> _rejectBooking(String bookingId) async {
    final result = await showDialog<Map<String, String?>?>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );

    if (result == null || !mounted) return;

    final success = await ref
        .read(rejectBookingProvider.notifier)
        .rejectBooking(
          bookingId: bookingId,
          reason: result['reason'],
          adminNotes: result['notes'],
        );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Booking rejected' : 'Unable to reject booking',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(adminBookingsProvider);
    final pendingCountAsync = ref.watch(pendingBookingsProvider);

    return SafeArea(
      child: bookingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 44),
                const SizedBox(height: 12),
                const Text(
                  'Could not load booking requests',
                  style: TextStyle(
                    fontFamily: 'Afacad',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(backgroundColor: _accent),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (bookings) {
          final filtered = _filterBookings(bookings);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: pendingCountAsync.maybeWhen(
                          data: (pending) => Text(
                            '${pending.length} pending',
                            style: const TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Afacad',
                            ),
                          ),
                          orElse: () => const Text(
                            'Loading pending...',
                            style: TextStyle(
                              color: _accent,
                              fontFamily: 'Afacad',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${bookings.length} total',
                        style: const TextStyle(
                          fontFamily: 'Afacad',
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusFilters(
                  selected: _selectedFilter,
                  onChanged: (value) => setState(() => _selectedFilter = value),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? const _AdminEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final booking = filtered[index];
                            return _AdminBookingCard(
                              booking: booking,
                              formattedDate: _formatDate(booking.createdAt),
                              onApprove: booking.status == 'pending'
                                  ? () => _approveBooking(booking.id)
                                  : null,
                              onReject: booking.status == 'pending'
                                  ? () => _rejectBooking(booking.id)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _StatusFilters({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', 'All'),
      ('pending', 'Pending'),
      ('approved', 'Approved'),
      ('rejected', 'Rejected'),
      ('cancelled', 'Cancelled'),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = filters[index];
          final active = selected == value;
          return ChoiceChip(
            selected: active,
            onSelected: (_) => onChanged(value),
            label: Text(label),
            selectedColor: const Color(0xFFF67D2C),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
            labelStyle: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontFamily: 'Afacad',
            ),
          );
        },
      ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  final BookingModel booking;
  final String formattedDate;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _AdminBookingCard({
    required this.booking,
    required this.formattedDate,
    this.onApprove,
    this.onReject,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SmartPetImage(
                    imageSource: booking.petImageUrl,
                    width: 52,
                    height: 52,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.petName.isEmpty
                            ? 'Unknown Pet'
                            : booking.petName,
                        style: const TextStyle(
                          fontFamily: 'Afacad',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'By ${booking.userName.isEmpty ? 'Unknown User' : booking.userName}',
                        style: TextStyle(
                          fontFamily: 'Afacad',
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Requested: $formattedDate',
              style: TextStyle(
                fontFamily: 'Afacad',
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Email: ${booking.userEmail.isEmpty ? 'N/A' : booking.userEmail}',
              style: const TextStyle(fontFamily: 'Afacad', fontSize: 12),
            ),
            Text(
              'Phone: ${booking.userPhone.isEmpty ? 'N/A' : booking.userPhone}',
              style: const TextStyle(fontFamily: 'Afacad', fontSize: 12),
            ),
            if ((booking.reason ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${booking.reason!.trim()}',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontFamily: 'Afacad',
                  fontSize: 12,
                ),
              ),
            ],
            if ((booking.adminNotes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  booking.adminNotes!.trim(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'Afacad'),
                ),
              ),
            ],
            if (onApprove != null && onReject != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 16),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  const _AdminEmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 130),
        Icon(Icons.inbox_outlined, size: 72, color: Colors.grey),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No booking requests for this filter',
            style: TextStyle(
              fontFamily: 'Afacad',
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApprovalDialog extends StatefulWidget {
  const _ApprovalDialog();

  @override
  State<_ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<_ApprovalDialog> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve Booking'),
      content: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Optional admin notes',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _notesController.text.trim()),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Approve'),
        ),
      ],
    );
  }
}

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  late final TextEditingController _reasonController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Booking'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Admin notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'reason': _reasonController.text.trim(),
              'notes': _notesController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
