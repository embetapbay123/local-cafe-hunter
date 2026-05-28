import 'package:flutter/material.dart';

import '../shared/app_routes.dart';
import '../services/onboarding_service.dart';
import '../notifications/services/notification_center_service.dart';
import '../theme/cafe_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _onboardingService = OnboardingService();

  int _currentIndex = 0;
  bool _isCompleting = false;

  final List<_OnboardingStepData> _steps = const [
    _OnboardingStepData(
      eyebrow: 'WELCOME',
      title: 'Bat dau voi luong kham pha gon va ro rang.',
      description:
          'Mot lan dang nhap xong, app dan ban qua Home, Search, Saved va Profile ma khong can doan luong.',
      icon: Icons.coffee_rounded,
      bullets: [
        'Home shell la diem neo trung tam cho luong browse.',
        'Search, Saved va Profile da san sang de mo rong tiep.',
      ],
    ),
    _OnboardingStepData(
      eyebrow: 'LOCATION',
      title: 'Cho phep vi tri khi ban muon map gan day chinh xac hon.',
      description:
          'Ban co the xem app truoc, sau do bat location khi muon map explorer can diem dat hien tai hon.',
      icon: Icons.place_rounded,
      bullets: [
        'Nearby cafes se hop voi ban kinh hien co cua map.',
        'Tat location van browse duoc, chi mat do chinh xac gan day.',
      ],
    ),
    _OnboardingStepData(
      eyebrow: 'FIRST RUN',
      title: 'Len xong la vao ngay, khong them buoc phu.',
      description:
          'Sau khi chot man nay, app luu trang thai tren may va dua ban thang vao man chinh o lan sau.',
      icon: Icons.rocket_launch_rounded,
      bullets: [
        'Onboarding chi hien mot lan tren thiet bi nay.',
        'Bat dau kham pha luon voi danh sach cafe hien co.',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_isCompleting) return;

    if (_currentIndex < _steps.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finishOnboarding();
  }

  Future<void> _skip() async {
    if (_isCompleting) return;
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    setState(() {
      _isCompleting = true;
    });

    await _onboardingService.markCompleted();
    await NotificationCenterService().recordOnboardingComplete();

    if (!mounted) return;

    final callback = widget.onFinished;
    if (callback != null) {
      callback();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentIndex];
    final isLast = _currentIndex == _steps.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD2C0A7), Color(0xFFF0E6D8), CafeColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'LOCAL CAFE HUNTER',
                        style: TextStyle(
                          color: CafeColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isCompleting ? null : _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: CafeColors.dark,
                      ),
                      child: const Text(
                        'Bo qua',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _OnboardingHero(step: step),
                const SizedBox(height: 18),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      return _OnboardingStepCard(data: _steps[index]);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (index) {
                    final active = index == _currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 30 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: active ? CafeColors.dark : CafeColors.dark.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CafeColors.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: CafeColors.dark.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        step.eyebrow,
                        style: const TextStyle(
                          color: CafeColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLast ? 'San sang vao app' : 'Tiep tuc theo tung buoc',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isLast
                            ? 'Mot lan bam nua la luu xong trang thai va quay ve home.'
                            : 'Neu chua xong, bam tiep tuc de di qua trang tiep theo.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _isCompleting ? null : _next,
                        icon: _isCompleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.3,
                                  color: CafeColors.background,
                                ),
                              )
                            : Icon(
                                isLast
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                        label: Text(
                          _isCompleting
                              ? 'Dang luu...'
                              : isLast
                                  ? 'Vao Local Cafe Hunter'
                                  : 'Tiep tuc',
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
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({required this.step});

  final _OnboardingStepData step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A3525), Color(0xFF8A6238), Color(0xFFD0AA76)],
        ),
        boxShadow: [
          BoxShadow(
            color: CafeColors.dark.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(step.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.eyebrow,
                  style: const TextStyle(
                    color: Color(0xFFF8EEDF),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            step.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            step.description,
            style: const TextStyle(
              color: Color(0xFFF7EEDF),
              height: 1.45,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepCard extends StatelessWidget {
  const _OnboardingStepCard({required this.data});

  final _OnboardingStepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: CafeColors.dark.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.eyebrow,
            style: const TextStyle(
              color: CafeColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 18),
          ...data.bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeaturePill(label: bullet),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: CafeColors.background.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: CafeColors.dark,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: CafeColors.dark,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepData {
  const _OnboardingStepData({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.bullets,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<String> bullets;
}
