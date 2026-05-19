import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../models/user_model.dart';
import '../../providers/friend_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_loader.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _emailController = TextEditingController();
  UserModel? _foundUser;
  bool _isSearching = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_emailController.text.trim().isEmpty) return;

    setState(() => _isSearching = true);
    final friendProvider = context.read<FriendProvider>();
    final user = await friendProvider.searchUserByEmail(_emailController.text.trim());
    setState(() {
      _foundUser = user;
      _isSearching = false;
    });
  }

  Future<void> _sendRequest() async {
    if (_foundUser == null) return;
    final friendProvider = context.read<FriendProvider>();
    await friendProvider.sendFriendRequest(_foundUser!.uid);

    if (mounted) {
      if (friendProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent!')),
        );
        setState(() => _foundUser = null);
        _emailController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendProvider.error!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('Add Friend')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find by email', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              AppInput(
                controller: _emailController,
                hintText: 'Enter friend\'s email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.search,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Search',
                onPressed: _search,
                isLoading: _isSearching,
              ),
              const SizedBox(height: 24),
              if (_isSearching)
                const AppLoader()
              else if (_foundUser != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      AppAvatar(
                        imageUrl: _foundUser!.photoURL,
                        initials: _foundUser!.initials,
                        size: AppDimensions.avatarXl,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _foundUser!.name,
                        style: AppTextStyles.heading3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _foundUser!.email,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Send friend request',
                        onPressed: _sendRequest,
                      ),
                    ],
                  ),
                )
              else if (_emailController.text.isNotEmpty && !_isSearching)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: AppColors.textMuted.withValues(alpha:0.4)),
                      const SizedBox(height: 12),
                      Text(
                        'No user found with this email',
                        style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
