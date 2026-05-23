import 'package:flutter/material.dart';

class ProposalCard extends StatelessWidget {
  final String destination;
  final String dates;
  final String notes;
  final Map<String, bool> memberVotes; // userId -> confirm status
  final int totalMembers;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;
  final bool hasVoted;

  // Converted to use modern super parameter syntax
  const ProposalCard({
    super.key,
    required this.destination,
    required this.dates,
    required this.notes,
    required this.memberVotes,
    required this.totalMembers,
    required this.onConfirm,
    required this.onDecline,
    required this.hasVoted,
  });

  @override
  Widget build(BuildContext context) {
    int confirmCount = memberVotes.values.where((v) => v == true).length;
    double progress = totalMembers > 0 ? confirmCount / totalMembers : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: const Color(0xffd99379).withValues(alpha: 0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xffd99379).withValues(alpha: 0.12),
              child: Row(
                children: [
                  const Icon(Icons.card_travel, color: Color(0xffd99379)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "NEW TRIP PROPOSAL",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffd99379),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          destination,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2d2d2d),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(dates, style: const TextStyle(color: Color(0xff616161))),
                    ],
                  ),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      notes,
                      // Fixed italic property assignment
                      style: const TextStyle(fontSize: 14, color: Color(0xff757575), fontStyle: FontStyle.italic),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Votes confirmed: $confirmCount/$totalMembers",
                        // Corrected invalid weight 'w640' to standard 'w600'
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffd99379)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xfff5f5f5),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffd99379)),
                    ),
                  ),
                  if (!hasVoted) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onDecline,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Decline"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffd99379),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Confirm"),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "✓ Vote Submitted",
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}