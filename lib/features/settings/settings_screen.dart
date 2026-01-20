import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/tts/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.tts,
  });

  final TtsService tts;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _rate = 0.45;
  double _pitch = 1.0;

  @override
  void initState() {
    super.initState();
    _rate = widget.tts.speechRate;
    _pitch = widget.tts.pitch;
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.12)),
        ),
        child: child,
      ),
    );
  }

  Widget _rowTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.9),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: AnimatedBuilder(
        animation: widget.tts,
        builder: (_, __) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 18),
            children: [
              _sectionTitle("VOICE"),

              _card(
                child: Row(
                  children: [
                    const Icon(Icons.volume_up_rounded,
                        color: AppColors.textPrimary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _rowTitle(
                        "Voice responses",
                        widget.tts.enabled
                            ? "Orion will speak replies"
                            : "Orion will stay silent",
                      ),
                    ),
                    Switch(
                      value: widget.tts.enabled,
                      onChanged: (v) => widget.tts.setEnabled(v),
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowTitle("Speech rate", "How fast Orion speaks"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _rate.clamp(0.1, 1.0),
                            min: 0.1,
                            max: 1.0,
                            divisions: 18,
                            onChanged: (v) async {
                              setState(() => _rate = v);
                              await widget.tts.setSpeechRate(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.12)),
                          ),
                          child: Text(
                            _fmt(_rate),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowTitle("Pitch", "Higher = sharper voice"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _pitch.clamp(0.5, 2.0),
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            onChanged: (v) async {
                              setState(() => _pitch = v);
                              await widget.tts.setPitch(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.12)),
                          ),
                          child: Text(
                            _fmt(_pitch),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await widget.tts.speak(
                                "Hello! This is Orion. Voice settings test.",
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text("Test voice"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent.withOpacity(0.22),
                              foregroundColor: AppColors.textPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.tts.isSpeaking
                                ? () async => widget.tts.stop()
                                : null,
                            icon: const Icon(Icons.stop_rounded),
                            label: const Text("Stop"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(
                                color: AppColors.accent.withOpacity(0.20),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          widget.tts.isSpeaking
                              ? Icons.graphic_eq_rounded
                              : Icons.check_circle_rounded,
                          color: widget.tts.isSpeaking
                              ? AppColors.accent
                              : AppColors.textSecondary.withOpacity(0.8),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.tts.isSpeaking ? "Speaking…" : "Idle",
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.9),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _sectionTitle("ABOUT"),
              _card(
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.textPrimary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _rowTitle(
                        "Orion Settings",
                        "More options coming soon",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
