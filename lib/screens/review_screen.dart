import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cafes/models/review.dart';
import '../cafes/viewmodels/cafe_viewmodel.dart';
import '../theme/cafe_theme.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.cafeId,
  });

  final String cafeId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final TextEditingController _commentController;
  double _draftRating = 4;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeViewModel>(
      builder: (context, cafeViewModel, _) {
        final cafe = cafeViewModel.getCafeById(widget.cafeId);
        if (cafe == null) {
          return Scaffold(
            backgroundColor: CafeColors.background,
            appBar: AppBar(),
            body: const Center(
              child: Text('Khong tim thay review cua quan nay.'),
            ),
          );
        }

        final reviews = cafe.reviews;

        return Scaffold(
          backgroundColor: CafeColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: cafe.gradientColors),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REVIEW FEATURE',
                              style: TextStyle(
                                color: Color(0xFFF7EEDF),
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cafe.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${reviews.length} review . Gui review moi truc tiep tu man nay.',
                              style: const TextStyle(
                                color: Color(0xFFF7EEDF),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    children: [
                      _ReviewComposerCard(
                        rating: _draftRating,
                        controller: _commentController,
                        isSubmitting: _isSubmitting,
                        onRatingChanged: (value) {
                          setState(() => _draftRating = value);
                        },
                        onSubmit: () => _submitReview(context, cafeViewModel),
                      ),
                      const SizedBox(height: 16),
                      _ReviewSummaryCard(
                        reviewCount: reviews.length,
                        averageRating: cafe.rating,
                      ),
                      const SizedBox(height: 16),
                      ...reviews.map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ReviewCard(review: review),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReview(
    BuildContext context,
    CafeViewModel cafeViewModel,
  ) async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await cafeViewModel.addReview(
        cafeId: widget.cafeId,
        rating: _draftRating,
        comment: comment,
      );
      if (!mounted) return;
      _commentController.clear();
      setState(() => _draftRating = 4);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da gui review moi.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _ReviewComposerCard extends StatelessWidget {
  const _ReviewComposerCard({
    required this.rating,
    required this.controller,
    required this.isSubmitting,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final double rating;
  final TextEditingController controller;
  final bool isSubmitting;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Viet review nhanh', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(
            'Review-management se xu ly edit/delete sau. Branch nay tap trung vao feed va submit.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: List.generate(5, (index) {
              final star = index + 1;
              return ChoiceChip(
                selected: rating.round() == star,
                label: Text('$star sao'),
                onSelected: (_) => onRatingChanged(star.toDouble()),
              );
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Chia se tra nghiem cua ban ve quan nay...',
              filled: true,
              fillColor: CafeColors.background.withValues(alpha: 0.55),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: isSubmitting ? null : onSubmit,
            child: Text(isSubmitting ? 'Dang gui...' : 'Gui review'),
          ),
        ],
      ),
    );
  }
}

class _ReviewSummaryCard extends StatelessWidget {
  const _ReviewSummaryCard({
    required this.reviewCount,
    required this.averageRating,
  });

  final int reviewCount;
  final double averageRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$reviewCount review dang hien thi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              color: CafeColors.dark,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CafeColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.authorName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: CafeColors.dark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
