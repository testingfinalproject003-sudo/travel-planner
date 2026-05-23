import 'package:flutter/material.dart';

class PendingRequestModel {
  final String id;
  final String senderName;
  final String avatarUrl;

  // Removed super.key since this is a data class model, not a Widget
  const PendingRequestModel({
    required this.id,
    required this.senderName,
    required this.avatarUrl,
  });
}

class FriendRequestsScreen extends StatefulWidget {
  // Added the missing modern super parameter key here
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final List<PendingRequestModel> _pendingRequests = [
    const PendingRequestModel(id: "req1", senderName: "", avatarUrl: ""),
    const PendingRequestModel(id: "req2", senderName: "", avatarUrl: ""),
  ];

  void _acceptInvite(String id, String name) {
    setState(() {
      _pendingRequests.removeWhere((element) => element.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You are now connected with $name! Chat unlock active."),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _declineInvite(String id) {
    setState(() {
      _pendingRequests.removeWhere((element) => element.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Friend Inbound Invites", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2d2d2d),
        elevation: 0,
      ),
      body: _pendingRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 48, color: const Color(0xffd99379).withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  const Text("Inbox clean. No unhandled invites pending.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingRequests.length,
              itemBuilder: (context, index) {
                final request = _pendingRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xfffafafa),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffe0e0e0).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xffd99379).withValues(alpha: 0.2),
                        foregroundColor: const Color(0xffd99379),
                        child: Text(request.senderName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          request.senderName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff2d2d2d)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                        onPressed: () => _declineInvite(request.id),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Color(0xffd99379)),
                        onPressed: () => _acceptInvite(request.id, request.senderName),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}