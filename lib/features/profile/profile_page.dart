import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/utils/responsive_layout.dart';

import '../authentication/screens/splash_screen.dart';
import '../../shared/widgets/custom_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.bookmarkCount,
    required this.onOpenBookmarks,
  });

  static const _pageBg = Color(0xFF09092D);
  final int bookmarkCount;
  final VoidCallback onOpenBookmarks;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfileData _profileData = const _ProfileData(
    username: 'hendrik Timang',
    email: 'hendriktimangpky@gmail.com',
    photoUrl: '',
  );

  Future<void> _openEditProfile() async {
    final updatedData = await Navigator.push<_ProfileData>(
      context,
      PageRouteBuilder<_ProfileData>(
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 230),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _EditProfilePage(initialData: _profileData),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.12, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );

    if (!mounted || updatedData == null) {
      return;
    }

    setState(() {
      _profileData = updatedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ProfilePage._pageBg,
      child: Column(
        children: [
          const CustomHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  _ProfileCard(
                    bookmarkCount: widget.bookmarkCount,
                    onOpenBookmarks: widget.onOpenBookmarks,
                    profileData: _profileData,
                    onEditTap: _openEditProfile,
                  ),
                  const SizedBox(height: 20),
                  _LogoutButton(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.bookmarkCount,
    required this.onOpenBookmarks,
    required this.profileData,
    required this.onEditTap,
  });

  final int bookmarkCount;
  final VoidCallback onOpenBookmarks;
  final _ProfileData profileData;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final cardHeight =
        (MediaQuery.sizeOf(context).height * 0.46).clamp(320.0, 380.0).toDouble();

    return Container(
      width: double.infinity,
      height: cardHeight,
      margin: EdgeInsets.symmetric(horizontal: 18 * scale),
      padding: EdgeInsets.symmetric(horizontal: 22 * scale, vertical: 24 * scale),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(
            photoUrl: profileData.photoUrl,
            onEditTap: onEditTap,
          ),
          SizedBox(height: 14 * scale),
          Text(
            profileData.username,
            style: TextStyle(
              color: const Color(0xFF09092D),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            profileData.email,
            style: TextStyle(
              color: const Color(0xFF888888),
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            'Bookmarks',
            style: TextStyle(
              color: const Color(0xFF888888),
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6 * scale),
          InkWell(
            onTap: onOpenBookmarks,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
              child: Text(
                '$bookmarkCount',
                style: TextStyle(
                  color: const Color(0xFF09092D),
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.photoUrl,
    required this.onEditTap,
  });

  final String photoUrl;
  final VoidCallback onEditTap;

  Widget _buildAvatarImage() {
    if (photoUrl.trim().isEmpty) {
      return const Icon(
        Icons.person,
        size: 64,
        color: Color(0xFF09092D),
      );
    }

    return ClipOval(
      child: Image.network(
        photoUrl.trim(),
        width: 98,
        height: 98,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 98,
            height: 98,
            color: const Color(0xFFD9D9D9),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              size: 64,
              color: Color(0xFF09092D),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: _buildAvatarImage(),
          ),
          Positioned(
            right: -2,
            bottom: -1,
            child: Material(
              color: const Color(0xFF1A1A40),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onEditTap,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfilePage extends StatefulWidget {
  const _EditProfilePage({required this.initialData});

  final _ProfileData initialData;

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  static const _bg = Color(0xFF09092D);
  static const _panel = Color(0xFF1A1A40);
  static const _panelBorder = Color(0xFF2A2A55);
  static const _inputFill = Color(0xFF22224D);
  static const _accent = Color(0xFFFECF06);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _photoUrlController;

  String _livePhotoUrl = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialData.username);
    _emailController = TextEditingController(text: widget.initialData.email);
    _photoUrlController = TextEditingController(text: widget.initialData.photoUrl);
    _livePhotoUrl = widget.initialData.photoUrl;
    _photoUrlController.addListener(_handlePhotoUrlChanged);
  }

  @override
  void dispose() {
    _photoUrlController.removeListener(_handlePhotoUrlChanged);
    _usernameController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _handlePhotoUrlChanged() {
    setState(() {
      _livePhotoUrl = _photoUrlController.text.trim();
    });
  }

  InputDecoration _inputDecoration(String hint, {required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8F8FB2), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFFACAFD8), size: 20),
      filled: true,
      fillColor: _inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _panelBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accent, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    Navigator.pop(
      context,
      _ProfileData(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: _photoUrlController.text.trim(),
      ),
    );
  }

  Widget _previewAvatar() {
    if (_livePhotoUrl.isEmpty) {
      return Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: Color(0xFFD9D9D9),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.person,
          size: 52,
          color: Color(0xFF09092D),
        ),
      );
    }

    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        _livePhotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.person,
              size: 52,
              color: Color(0xFF09092D),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          const CustomHeader(showNotificationButton: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.maybePop(context),
                            borderRadius: BorderRadius.circular(999),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        'Edit ur profile  with ur imagination',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      decoration: BoxDecoration(
                        color: _panel.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _panelBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.24),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: _previewAvatar(),
                          ),
                          const SizedBox(height: 16),
                          _fieldLabel('Edit Username'),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Enter username',
                              icon: Icons.person_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Edit Email'),
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                              'Enter email',
                              icon: Icons.mail_outline_rounded,
                            ),
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'Email is required';
                              }
                              if (!trimmed.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Edit Photo'),
                          TextFormField(
                            controller: _photoUrlController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.url,
                            decoration: _inputDecoration(
                              'https://example.com/profile.jpg',
                              icon: Icons.link_rounded,
                            ),
                          ),
                          const SizedBox(height: 18),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFECF06), Color(0xFFE7BA00)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: const Color(0xFF1A1A40),
                                shadowColor: Colors.transparent,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileData {
  const _ProfileData({
    required this.username,
    required this.email,
    required this.photoUrl,
  });

  final String username;
  final String email;
  final String photoUrl;
}

class _LogoutButton extends StatefulWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF9B3D5B).withValues(alpha: 0.24),
            const Color(0xFF5A3E86).withValues(alpha: 0.24),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() {
              _isPressed = value;
            });
          },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 140),
            opacity: _isPressed ? 0.9 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: const Color(0xFFFF5F5F).withValues(alpha: 0.25)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.logout,
                      color: Color(0xFFFF5F5F),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Log out',
                    style: TextStyle(
                      color: Color(0xFFFF5F5F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }
}