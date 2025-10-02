import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/theme.dart';
import '../helper/helper_functions.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? extraActions;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final bool showProfileButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.extraActions,
    this.onBackPressed,
    this.centerTitle = false,
    this.showProfileButton = true,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userData = await AppBarAuthHelper.loadUserData(currentUser);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          // fontWeight: FontWeight.w900,
        ),
      ),
      centerTitle: widget.centerTitle,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
      ),
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: [
        // Extra actions if provided
        if (widget.extraActions != null) ...widget.extraActions!,
        
        // Authentication menu
        widget.showProfileButton == false
          ? const SizedBox.shrink() // No auth menu on pages with back button
          : PopupMenuButton<String>(
          onSelected: (value) => AppBarAuthHelper.handleMenuAction(
            value,
            context,
            onStateChange: () {
              setState(() {
                currentUser = null;
                userData = null;
              });
              _checkCurrentUser();
            },
          ),
          itemBuilder: (context) {
            final menuItems = AppBarAuthHelper.buildMenuItems(currentUser, userData);
            return menuItems.map((item) {
              // Create custom styled popup menu items
              if (item is PopupMenuItem<String>) {
                final originalChild = item.child;
                if (originalChild is Row) {
                  return PopupMenuItem<String>(
                    value: item.value,
                    child: Row(
                      children: [
                        // Extract and style the icon
                        Theme(
                          data: Theme.of(context).copyWith(
                            iconTheme: IconThemeData(
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          child: originalChild.children.first, // The icon
                        ),
                        const SizedBox(width: 12),
                        // Extract and style the text
                        Expanded(
                          child: DefaultTextStyle(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ) ?? const TextStyle(),
                            child: originalChild.children.last, // The text
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              return item;
            }).toList();
          },
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              currentUser != null
                  ? Icons.account_circle
                  : Icons.account_circle_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}