import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ai_financial_orb.dart';

class AiActionButton {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  AiActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AppTheme.purple,
  });
}

class AiMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final List<AiActionButton>? actionButtons;
  final bool isThinking;

  const AiMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.actionButtons,
    this.isThinking = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14, left: 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.purple, Color(0xFF5A4AD1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.purple.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    // AI Message
    return Container(
      margin: const EdgeInsets.only(bottom: 18, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const AiFinancialOrb(size: 20, isPulsing: false),
              const SizedBox(width: 8),
              const Text(
                'FINPILOT AI COPILOT',
                style: TextStyle(
                  color: AppTheme.cyan,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              if (timestamp != null)
                Text(
                  '${timestamp!.hour.toString().padLeft(2, '0')}:${timestamp!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Message Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isThinking)
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.cyan,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Analyzing financial telemetry...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else
                  _buildFormattedContent(message),

                // Action Buttons
                if (actionButtons != null && actionButtons!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: actionButtons!.map((btn) {
                      return ElevatedButton.icon(
                        onPressed: btn.onTap,
                        icon: Icon(btn.icon, size: 14),
                        label: Text(
                          btn.label,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btn.color.withValues(alpha: 0.15),
                          foregroundColor: btn.color,
                          side: BorderSide(color: btn.color.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedContent(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Check for Section Titles like SHORT ANSWER, WHY, YOUR NUMBERS, RECOMMENDATION, ACTION PLAN
      if (trimmed.startsWith('SHORT ANSWER') ||
          trimmed.startsWith('WHY') ||
          trimmed.startsWith('YOUR NUMBERS') ||
          trimmed.startsWith('RECOMMENDATION') ||
          trimmed.startsWith('ACTION PLAN') ||
          trimmed.startsWith('AFFORDABILITY ANALYSIS')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              trimmed,
              style: const TextStyle(
                color: AppTheme.cyan,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('•') || trimmed.startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppTheme.purple, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    trimmed.substring(1).trim(),
                    style: const TextStyle(color: AppTheme.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${RegExp(r'^\d+\.').firstMatch(trimmed)!.group(0)} ',
                  style: const TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                    style: const TextStyle(color: AppTheme.white, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Text(
            trimmed,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
