import 'package:flutter/material.dart';

import '../../home/home_screen.dart';
import '../../../shared/widgets/top_success_banner.dart';
import '../../../core/utils/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _tabController;
  late AnimationController _successBannerController;
  late AnimationController _loginExitController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _successBannerSlideAnimation;
  late Animation<Offset> _loginExitSlideAnimation;
  late Animation<double> _loginExitFadeAnimation;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLogin = true;
  bool _showSuccessBanner = false;
  bool _isLoginProcessing = false;

  static const _formPanelColor = Color(0xFFF2F2F5);
  static const _formInputColor = Color(0xFFF7F7FA);
  static const _formBorderColor = Color(0xFF8C8C96);
  static const _formMutedTextColor = Color(0xFF5A5A68);

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _tabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Smooth success banner animation controller (faster reveal)
    _successBannerController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // Banner slides in from above with easing
    _successBannerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),  // Start above screen
      end: Offset.zero,              // End at final position
    ).animate(
      CurvedAnimation(
        parent: _successBannerController,
        curve: Curves.easeOut,  // Smooth deceleration
      ),
    );

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _loginExitController = AnimationController(
      duration: const Duration(milliseconds: 620),
      vsync: this,
    );

    _loginExitSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.0),
    ).animate(
      CurvedAnimation(
        parent: _loginExitController,
        curve: Curves.easeInOut,
      ),
    );

    _loginExitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(
      CurvedAnimation(
        parent: _loginExitController,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    _tabController.dispose();
    _successBannerController.dispose();
    _loginExitController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginPressed() async {
    if (_isLoginProcessing) return;

    setState(() {
      _isLoginProcessing = true;
      _showSuccessBanner = true;
    });

    try {
      await _successBannerController.forward();
      await Future<void>.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;

      await _loginExitController.forward();

      if (!mounted) return;

      final isAdmin = _emailController.text.trim().toLowerCase() == 'admin';

      await Navigator.of(context).pushReplacement(
        _createHomeRevealTransition(
          HomeScreen(
            isAdmin: isAdmin,
            animateOnEntry: true,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _successBannerController.reset();
      _loginExitController.reset();
      setState(() {
        _showSuccessBanner = false;
        _isLoginProcessing = false;
      });
    }
  }

  PageRoute<dynamic> _createHomeRevealTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 120),
      reverseTransitionDuration: const Duration(milliseconds: 100),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ColoredBox(
          color: const Color(0xFF09092D),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF09092D),
      body: Stack(
        children: [
          SlideTransition(
            position: _loginExitSlideAnimation,
            child: FadeTransition(
              opacity: _loginExitFadeAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF09092D),
                      Color(0xFF09092D),
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = screenHeight < 760;
                      final topRatio = compact ? 0.19 : 0.33;
                      final headerRatio = compact ? 0.075 : 0.17;
                      final cardTop = (constraints.maxHeight * topRatio)
                        .clamp(155.0, 290.0)
                          .toDouble();
                      final headerTop = (constraints.maxHeight * headerRatio)
                        .clamp(92.0, 158.0)
                          .toDouble();

                      return Column(
                        children: [
                          SizedBox(
                            height: cardTop,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: compact ? -34 * scale : -24 * scale,
                                  left: 24,
                                  right: 24,
                                  child: _buildLogo(),
                                ),
                                Positioned(
                                  top: headerTop,
                                  left: 24,
                                  right: 24,
                                  child: _buildHeader(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: FadeTransition(
                              opacity: _contentFadeAnimation,
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: _formPanelColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: bottomInset),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 600),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24.0,
                                            vertical: compact ? 12.0 : 28.0,
                                        ),
                                        child: Column(
                                          children: [
                                            _buildTabBar(),
                                              SizedBox(height: compact ? 8 : 28),
                                            Expanded(
                                              child: AnimatedSwitcher(
                                                duration: const Duration(milliseconds: 250),
                                                transitionBuilder: (child, animation) =>
                                                    FadeTransition(opacity: animation, child: child),
                                                layoutBuilder: (currentChild, previousChildren) {
                                                  return Stack(
                                                    alignment: Alignment.topCenter,
                                                    children: [
                                                      ...previousChildren,
                                                      if (currentChild != null) currentChild,
                                                    ],
                                                  );
                                                },
                                                child: _isLogin
                                                    ? KeyedSubtree(
                                                        key: const ValueKey('login'),
                                                        child: _buildLoginForm(),
                                                      )
                                                    : KeyedSubtree(
                                                        key: const ValueKey('register'),
                                                        child: _buildRegisterForm(),
                                                      ),
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
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (_showSuccessBanner)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 44,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: TopSuccessBanner(
                  animation: _successBannerSlideAnimation,
                  maxWidth: 260,
                  height: 60,
                  fontSize: 17,
                  iconSize: 19,
                  horizontalMargin: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final media = MediaQuery.of(context);
    final shortestSide = media.size.shortestSide;
    final compact = media.size.height < 760;

    double logoWidth;
    if (shortestSide < 340) {
      logoWidth = compact ? 240 : 270;
    } else if (shortestSide < 390) {
      logoWidth = compact ? 270 : 310;
    } else if (shortestSide < 430) {
      logoWidth = compact ? 300 : 340;
    } else {
      logoWidth = compact ? 320 : 360;
    }

    logoWidth = logoWidth.clamp(220.0, media.size.width * 0.9);

    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        width: logoWidth,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildHeader() {
    final scale = ResponsiveLayout.scale(context, min: 0.9, max: 1.08);
    final compact = MediaQuery.sizeOf(context).height < 760;
    final titleSize = compact ? 26.0 : 29.0;
    final subtitleSize = compact ? 11.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Go ahead and set up\nyour account',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize * scale,
            fontWeight: FontWeight.bold,
            height: 1.3,
            letterSpacing: 1.9 * scale,
          ),
        ),
        SizedBox(height: (compact ? 10 : 14) * scale),
        Text(
          'Sign in-up to enjoy the bestmanaging experience',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: subtitleSize * scale,
              height: 1.5,
              letterSpacing: 1.0 * scale,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    final tabBarWidth = (MediaQuery.of(context).size.width * 0.64)
        .clamp(220.0, 300.0)
        .toDouble();

    return Column(
      children: [
        SizedBox(
          width: tabBarWidth,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!_isLogin) {
                      setState(() {
                        _isLogin = true;
                      });
                      _tabController.reverse();
                    }
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(
                      'Login',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_isLogin) {
                      setState(() {
                        _isLogin = false;
                      });
                      _tabController.forward();
                    }
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text(
                      'Register',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: tabBarWidth,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final halfWidth = constraints.maxWidth / 2;
              return SizedBox(
                height: 3,
                width: constraints.maxWidth,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      left: _isLogin ? (halfWidth - 45) / 2 : halfWidth + (halfWidth - 70) / 2,
                      child: Container(
                        height: 3,
                        width: _isLogin ? 45 : 70,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() { // 
    final screenHeight = MediaQuery.sizeOf(context).height;
    final formItemWidth = (MediaQuery.of(context).size.width * 0.86)
        .clamp(220.0, 310.0)
        .toDouble();
    final compact = screenHeight < 760;
    final fieldGap = compact ? 9.0 : 16.0;
    final rememberGap = compact ? 3.0 : 8.0;
    final fieldPaddingVertical = compact ? 12.0 : 16.0;

    Widget formItem(Widget child) {
      return SizedBox(
        width: formItemWidth,
        child: child,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        formItem(
          Container(
            decoration: BoxDecoration(
              color: _formInputColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2A2A2A), width: 1.1),
            ),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Enter Your Email',
                hintStyle: const TextStyle(
                  color: Color(0xFF17153C),
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF2A2A2A),
                  size: 24,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: fieldPaddingVertical,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: fieldGap),
        formItem(
          Container(
            decoration: BoxDecoration(
              color: _formInputColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF2A2A2A), width: 1.1),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Enter Your Password',
                hintStyle: const TextStyle(
                  color: Color(0xFF17153C),
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF2A2A2A),
                  size: 24,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF2A2A2A),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: fieldPaddingVertical,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: rememberGap),
        formItem(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      side: const BorderSide(color: _formBorderColor, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: const Color(0xFF09092D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Remember me',
                    style: TextStyle(
                      color: _formMutedTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: Color(0xFF17153C),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 36 : 52),
          formItem(
            ElevatedButton(
              onPressed: _isLoginProcessing ? null : _handleLoginPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF09092D),
                disabledBackgroundColor: const Color(0xFF09092D).withValues(alpha: 0.6),
                minimumSize: const Size(double.infinity, 66),
                padding: const EdgeInsets.symmetric(vertical: 21),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoginProcessing
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.8),
                    ),
                    strokeWidth: 2.5,
                  ),
                )
                : const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
            ),
          ),
        SizedBox(height: compact ? 2 : 6),
      ],
    );
  }

  Widget _buildRegisterForm() { 
    final screenHeight = MediaQuery.sizeOf(context).height;
    final formItemWidth = (MediaQuery.of(context).size.width * 0.86)
      .clamp(220.0, 310.0)
        .toDouble();
    final compact = screenHeight < 760;
    final fieldGap = compact ? 9.0 : 16.0;
    final fieldPaddingVertical = compact ? 12.0 : 16.0;

    Widget formItem(Widget child) => SizedBox(width: formItemWidth, child: child);

    Widget inputField({
      required TextEditingController controller,
      required String hint,
      required IconData prefixIconData,
      TextInputType keyboardType = TextInputType.text,
      bool obscure = false,
      VoidCallback? onToggleObscure,
    }) {
      return formItem(
        Container(
          decoration: BoxDecoration(
            color: _formInputColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1.1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF17153C),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                prefixIconData,
                color: const Color(0xFF2A2A2A),
                size: 24,
              ),
              suffixIcon: onToggleObscure != null
                  ? IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF2A2A2A),
                        size: 24,
                      ),
                      onPressed: onToggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: fieldPaddingVertical,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        inputField(
          controller: _usernameController,
          hint: 'Enter Your Username',
          prefixIconData: Icons.person_outline,
        ),
        SizedBox(height: fieldGap),
        inputField(
          controller: _regEmailController,
          hint: 'Enter Your Email',
          prefixIconData: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: fieldGap),
        inputField(
          controller: _regPasswordController,
          hint: 'Enter Your Password',
          prefixIconData: Icons.lock_outline,
          obscure: _obscureRegPassword,
          onToggleObscure: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
        ),
        SizedBox(height: fieldGap),
        inputField(
          controller: _confirmPasswordController,
          hint: 'Confirm Password',
          prefixIconData: Icons.lock_outline,
          obscure: _obscureConfirmPassword,
          onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
                SizedBox(height: compact ? 36 : 52),
        formItem(
          ElevatedButton(
            onPressed: () {
              // Handle register
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF09092D),
              minimumSize: const Size(double.infinity, 46),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Register',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 2 : 6),
      ],
    );
  }
}
