import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_adoption_app/data/models/booking_model.dart';
import 'package:pet_adoption_app/presentation/providers/booking_provider.dart';
import 'package:pet_adoption_app/presentation/widgets/smart_pet_image.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
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
    ref.invalidate(userBookingsProvider);
    await ref.read(userBookingsProvider.future);
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel booking request for ${booking.petName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !mounted) return;

    final ok = await ref
        .read(cancelBookingProvider.notifier)
        .cancelBooking(booking.id);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not cancel booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Afacad',
          ),
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
          ),
        ),
        error: (error, _) =>
            _ErrorState(message: error.toString(), onRetry: _refresh),
        data: (bookings) {
          final filtered = _filterBookings(bookings);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                const SizedBox(height: 12),
                _StatusFilters(
                  selected: _selectedFilter,
                  onChanged: (value) => setState(() => _selectedFilter = value),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final booking = filtered[index];
                            return _BookingTile(
                              booking: booking,
                              formattedDate: _formatDate(booking.createdAt),
                              onCancel:
                                  booking.status == 'pending' ||
                                      booking.status == 'approved'
                                  ? () => _cancelBooking(booking)
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
          final isActive = selected == value;
          return ChoiceChip(
            label: Text(label),
            selected: isActive,
            onSelected: (_) => onChanged(value),
            labelStyle: TextStyle(
              fontFamily: 'Afacad',
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: const Color(0xFFF67D2C),
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
          );
        },
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final BookingModel booking;
  final String formattedDate;
  final VoidCallback? onCancel;

  const _BookingTile({
    required this.booking,
    required this.formattedDate,
    this.onCancel,
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
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
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
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested on $formattedDate',
                        style: TextStyle(
                          fontFamily: 'Afacad',
                          fontSize: 12,
                          color: Colors.grey.shade600,
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
            if ((booking.adminNotes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  booking.adminNotes!.trim(),
                  style: const TextStyle(fontFamily: 'Afacad', fontSize: 12),
                ),
              ),
            ],
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
            if (onCancel != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel Request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 110),
        Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No bookings in this filter',
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

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 46),
            const SizedBox(height: 12),
            Text(
              'Could not load bookings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => onRetry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF67D2C),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
