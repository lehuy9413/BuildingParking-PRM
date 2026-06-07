import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ai_suggestion.dart';
import '../controllers/booking_controller.dart';

class AiSuggestionScreen extends ConsumerStatefulWidget {
  const AiSuggestionScreen({super.key});

  @override
  ConsumerState<AiSuggestionScreen> createState() => _AiSuggestionScreenState();
}

class _AiSuggestionScreenState extends ConsumerState<AiSuggestionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(bookingControllerProvider);
      if (state.aiSuggestions.isEmpty && !state.isLoading) {
        ref.read(bookingControllerProvider.notifier).loadAiSuggestions();
      }
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(bookingControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6366F1), size: 24),
            const SizedBox(width: 10),
            Text(
              'AI Suggestions',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? _buildLoading(isDark)
          : state.aiSuggestions.isEmpty
              ? _buildEmpty(isDark)
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildSuggestions(state.aiSuggestions, isDark),
                ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF6366F1).withOpacity(0.15)
                  : const Color(0xFF6366F1).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing parking data...',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding the best spot for you',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No suggestions available',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a vehicle type and date first',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(List<AiSuggestion> suggestions, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header info ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF6366F1).withOpacity(0.3) : const Color(0xFFC7D2FE),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6366F1), size: 36),
                const SizedBox(height: 12),
                Text(
                  'Top ${suggestions.length} Optimal Spots',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on occupancy, location and walking distance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Suggestion Cards ──
          ...List.generate(suggestions.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SuggestionCard(
                suggestion: suggestions[index],
                rank: index + 1,
                isDark: isDark,
                onSelect: () {
                  ref.read(bookingControllerProvider.notifier)
                      .selectAiSuggestion(suggestions[index]);
                  Navigator.of(context).pop();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Suggestion Card ─────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.rank,
    required this.isDark,
    required this.onSelect,
  });

  final AiSuggestion suggestion;
  final int rank;
  final bool isDark;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final slot = suggestion.recommendedSlot;
    final confidencePercent = (suggestion.confidenceScore * 100).toInt();
    final isTop = rank == 1;

    Color rankColor;
    IconData rankIcon;
    String rankLabel;

    switch (rank) {
      case 1:
        rankColor = const Color(0xFFF59E0B);
        rankIcon = Icons.emoji_events_rounded;
        rankLabel = 'Best Match';
        break;
      case 2:
        rankColor = const Color(0xFF94A3B8);
        rankIcon = Icons.workspace_premium_rounded;
        rankLabel = 'Alternative';
        break;
      default:
        rankColor = const Color(0xFFCD7F32);
        rankIcon = Icons.workspace_premium_rounded;
        rankLabel = 'Alternative';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isTop
            ? Border.all(color: rankColor.withOpacity(0.5), width: 2)
            : Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
        boxShadow: [
          BoxShadow(
            color: isTop
                ? rankColor.withOpacity(isDark ? 0.3 : 0.15)
                : Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: isTop ? 24 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Rank Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(isDark ? 0.15 : 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(rankIcon, color: rankColor, size: 22),
                const SizedBox(width: 10),
                Text(
                  rankLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: rankColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$confidencePercent% confidence',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: rankColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slot info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F4C5C).withOpacity(0.25)
                            : const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_parking_rounded,
                        color: Color(0xFF0F4C5C),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.slotNumber,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            slot.floor ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    _statChip(
                      Icons.directions_walk_rounded,
                      '~${suggestion.estimatedWalkTimeMinutes} min',
                      'Walk time',
                      isDark,
                    ),
                    const SizedBox(width: 12),
                    _statChip(
                      Icons.pie_chart_rounded,
                      '${(suggestion.occupancyRate * 100).toInt()}%',
                      'Occupancy',
                      isDark,
                    ),
                    const SizedBox(width: 12),
                    _statChip(
                      Icons.payments_rounded,
                      '\$${slot.pricePerHour.toStringAsFixed(0)}/hr',
                      'Rate',
                      isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reason
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF374151).withOpacity(0.5) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    suggestion.reason,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Advantages
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestion.advantages.map((adv) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1B998B).withOpacity(0.15)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF1B998B), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            adv,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B998B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Select button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: isTop ? const Color(0xFF0F4C5C) : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: isTop ? 4 : 0,
                      shadowColor: const Color(0xFF0F4C5C).withOpacity(0.3),
                    ),
                    child: Text(
                      isTop ? 'Select This Slot' : 'Select',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isTop ? Colors.white : (isDark ? Colors.white : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151).withOpacity(0.4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
