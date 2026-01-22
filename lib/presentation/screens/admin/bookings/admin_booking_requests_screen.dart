import 'package:flutter/material.dart';

class AdminBookingRequestsScreen extends StatefulWidget {
  const AdminBookingRequestsScreen({super.key});

  @override
  State<AdminBookingRequestsScreen> createState() =>
      _AdminBookingRequestsScreenState();
}

class _AdminBookingRequestsScreenState
    extends State<AdminBookingRequestsScreen> {
  // Sample booking data - will be replaced with backend data
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 1,
      'customerName': 'John Doe',
      'petName': 'Shephard',
      'requestDate': '2026-01-20',
      'status': 'Pending',
      'customerEmail': 'john.doe@example.com',
      'customerPhone': '+1-555-0123',
    },
    {
      'id': 2,
      'customerName': 'Jane Smith',
      'petName': 'Kaali',
      'requestDate': '2026-01-19',
      'status': 'Pending',
      'customerEmail': 'jane.smith@example.com',
      'customerPhone': '+1-555-0124',
    },
    {
      'id': 3,
      'customerName': 'Bob Wilson',
      'petName': 'Gori',
      'requestDate': '2026-01-18',
      'status': 'Approved',
      'customerEmail': 'bob.wilson@example.com',
      'customerPhone': '+1-555-0125',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_bookings.where((b) => b['status'] == 'Pending').length} Pending Requests',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontFamily: 'Afacad',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return _BookingRequestCard(
                  booking: booking,
                  onApprove: () {
                    setState(() {
                      _bookings[index]['status'] = 'Approved';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Request approved!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onReject: () {
                    setState(() {
                      _bookings[index]['status'] = 'Rejected';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Request rejected!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _BookingRequestCard({
    required this.booking,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['customerName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Afacad',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pet: ${booking['petName']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Afacad',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: booking['status'] == 'Pending'
                        ? Colors.orange.withValues(alpha: 0.2)
                        : booking['status'] == 'Approved'
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: booking['status'] == 'Pending'
                          ? Colors.orange
                          : booking['status'] == 'Approved'
                          ? Colors.green
                          : Colors.red,
                      fontFamily: 'Afacad',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontFamily: 'Afacad',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${booking['customerEmail']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'Afacad',
                    ),
                  ),
                  Text(
                    'Phone: ${booking['customerPhone']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontFamily: 'Afacad',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (booking['status'] == 'Pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
