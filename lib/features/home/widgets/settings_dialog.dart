import 'package:flutter/material.dart';
import '../../../shared/services/audio_service.dart';
import '../../../shared/services/progress_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _audio = AudioService();
  final _progress = ProgressService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        '⚙️ Settings',
        style: TextStyle(fontFamily: 'Fredoka', fontSize: 28),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Music toggle
          _SettingRow(
            icon: Icons.music_note_rounded,
            label: 'Music',
            value: _audio.musicEnabled,
            onChanged: (v) {
              _audio.toggleMusic();
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          // SFX toggle
          _SettingRow(
            icon: Icons.volume_up_rounded,
            label: 'Sound Effects',
            value: _audio.sfxEnabled,
            onChanged: (v) {
              _audio.toggleSfx();
              setState(() {});
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          // Parent area hint
          const Text(
            'Parent Area',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _ProgressSummary(progress: _progress),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showResetConfirm(context),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Reset Progress',
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 16),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 20),
          ),
        ),
      ],
    );
  }

  void _showResetConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Reset all progress?',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: 22),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'All stars will be lost.',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'Fredoka', fontSize: 18)),
          ),
          TextButton(
            onPressed: () async {
              await _progress.resetProgress();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Reset',
                style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 18,
                    color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 20),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final ProgressService progress;

  const _ProgressSummary({required this.progress});

  @override
  Widget build(BuildContext context) {
    final summary = progress.getSummary();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressRow('Total Stars', summary['totalStars'] as int),
        _ProgressRow('Letter Sounds', summary['letterSoundStars'] as int),
        _ProgressRow('Counting', summary['countingStars'] as int),
        _ProgressRow('Letter Match', summary['letterMatchStars'] as int),
        _ProgressRow('Memory Flip', summary['memoryFlipStars'] as int),
        _ProgressRow('Color Sort', summary['colorSortStars'] as int),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int stars;

  const _ProgressRow(this.label, this.stars);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 16)),
          const Spacer(),
          Icon(Icons.star_rounded,
              color: Colors.amber.shade600, size: 18),
          const SizedBox(width: 2),
          Text('$stars',
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 16)),
        ],
      ),
    );
  }
}
