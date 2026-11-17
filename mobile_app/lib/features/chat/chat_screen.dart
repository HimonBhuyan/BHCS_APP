import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';
import 'chat_attachment_viewer.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _searchQuery = '';

  void _openThread(ChatThread thread) {
    ref.read(agencyStoreProvider.notifier).markThreadRead(thread.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(threadId: thread.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final textTheme = Theme.of(context).textTheme;

    // Show only the Founders Board + the other Co-Founders (hide self DM)
    final filteredThreads = state.chatThreads.where((t) {
      if (!t.isChannel && t.name == state.currentUser.name) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return t.name.toLowerCase().contains(q) ||
            t.subtitle.toLowerCase().contains(q) ||
            t.lastMessagePreview.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Founders Direct Chat'),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Himon Bhuyan • Darshana Das • Drishant Das',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: BhAmbientCanvas(
        child: Column(
          children: [
            // 3 Founders Presence Strip (tap any Founder to open direct chat or Founders Board)
            SizedBox(
              height: 82,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: state.employees.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final emp = state.employees[index];
                  final isCurrent = emp.id == state.currentUser.id;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (isCurrent) {
                        final board = state.chatThreads
                            .where((t) => t.isChannel)
                            .toList();
                        if (board.isNotEmpty) {
                          _openThread(board.first);
                        }
                        return;
                      }
                      final dmMatches = state.chatThreads
                          .where((t) => !t.isChannel && t.name == emp.name)
                          .toList();
                      if (dmMatches.isNotEmpty) {
                        _openThread(dmMatches.first);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          BhAvatar(
                            name: emp.name,
                            size: 44,
                            isOnline: emp.isOnline,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCurrent
                                ? '${emp.name.split(' ').first} (You)'
                                : emp.name.split(' ').first,
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: isCurrent
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isCurrent ? AppColors.electricBlue : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search Founders...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () => setState(() => _searchQuery = ''),
                          icon: const Icon(Icons.close_rounded, size: 18),
                        )
                      : null,
                ),
              ),
            ),

            // Founders Conversation List
            Expanded(
              child: filteredThreads.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: BhArtisticEmptyState(
                          icon: Icons.forum_outlined,
                          title: 'No matching Founder chat',
                          description:
                              'Search for Himon, Darshana, Drishant, or Founders Board.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                      itemCount: filteredThreads.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final thread = filteredThreads[index];
                        return BhFadeSlideIn(
                          delayMs: index * 35,
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(14),
                            borderColor: thread.unreadCount > 0
                                ? AppColors.electricBlue.withValues(alpha: 0.6)
                                : null,
                            onTap: () => _openThread(thread),
                            child: Row(
                              children: [
                                if (thread.isChannel)
                                  const BhBrandLogo(
                                    size: 46,
                                    showGlow: false,
                                  )
                                else
                                  BhAvatar(
                                    name: thread.name,
                                    size: 46,
                                    isOnline: thread.isOnline,
                                  ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              thread.name,
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          if (thread.isPrivate) ...[
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.verified_user_rounded,
                                              size: 14,
                                              color: AppColors.electricBlue,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        thread.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: AppColors.electricBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (thread.messages.isNotEmpty &&
                                              thread.messages.last.senderId ==
                                                  state.currentUser.id) ...[
                                            Icon(
                                              state.isOfflineMode
                                                  ? Icons.done_rounded
                                                  : Icons.done_all_rounded,
                                              size: 14,
                                              color: thread.messages.last
                                                      .isSeenByOthers
                                                  ? const Color(0xFF38BDF8)
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Expanded(
                                            child: Text(
                                              thread.messages.isEmpty
                                                  ? 'Tap to start messaging'
                                                  : thread.lastMessagePreview,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                fontWeight:
                                                    thread.unreadCount > 0
                                                        ? FontWeight.w700
                                                        : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (thread.messages.isNotEmpty)
                                      Text(
                                        BhFormatters.relativeTime(
                                          thread.lastActivity,
                                        ),
                                        style: textTheme.labelSmall,
                                      ),
                                    const SizedBox(height: 6),
                                    if (thread.unreadCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.electricBlue,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${thread.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 13,
                                        color: AppColors.electricBlue,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ChatRoomScreen({super.key, required this.threadId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  static const List<String> _reactionEmojis = ['🔥', '🚀', '✅', '❤️', '👏', '💡'];

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatMessage? _replyingTo;
  String? _playingVoiceMsgId;
  bool _showMentionBar = false;
  Timer? _typingDebounce;
  AudioPlayer? _audioPlayer;
  StreamSubscription<void>? _playerCompleteSub;
  StreamSubscription<Duration>? _playerPosSub;
  StreamSubscription<Duration>? _playerDurSub;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  double _playbackSpeed = 1.0;

  // WhatsApp-style inline voice recording state
  AudioRecorder? _recorder;
  Timer? _recordTimer;
  StreamSubscription<Amplitude>? _ampSub;
  bool _isRecording = false;
  bool _isRecordingLocked = false;
  bool _isRecordingPaused = false;
  bool _isSendingVoice = false;
  bool _cancelBySlide = false;
  int _recordedSec = 0;
  double _dragOffsetX = 0;
  double _dragOffsetY = 0;
  Offset? _pressOrigin;
  final List<double> _waveSamples = List<double>.filled(24, 0.25, growable: true);

  bool get _isTestEnv => Platform.environment.containsKey('FLUTTER_TEST');
  bool _readSyncQueued = false;

  @override
  void initState() {
    super.initState();
    _queueMarkThreadRead();
  }

  void _queueMarkThreadRead() {
    if (_readSyncQueued) return;
    _readSyncQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readSyncQueued = false;
      if (!mounted) return;
      ref.read(agencyStoreProvider.notifier).markThreadRead(widget.threadId);
    });
  }

  List<String> _resolveSeenByFirstNames(
    ChatMessage msg,
    List<AppUser> employees,
  ) {
    final otherIds = msg.seenByOtherIds;
    if (otherIds.isEmpty) return const [];
    final byId = {for (final e in employees) e.id: e.name};
    return otherIds
        .map((id) => (byId[id] ?? id).split(' ').first)
        .toList();
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _recordTimer?.cancel();
    _ampSub?.cancel();
    _recorder?.dispose();
    _playerCompleteSub?.cancel();
    _playerPosSub?.cancel();
    _playerDurSub?.cancel();
    _audioPlayer?.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onComposerChanged(String val) {
    final notifier = ref.read(agencyStoreProvider.notifier);
    notifier.setTypingStatus(widget.threadId, val.trim().isNotEmpty);
    _typingDebounce?.cancel();
    if (val.trim().isNotEmpty) {
      _typingDebounce = Timer(
        const Duration(seconds: 4),
        () => notifier.setTypingStatus(widget.threadId, false),
      );
    }
    final wantsMention = val.endsWith('@');
    if (wantsMention != _showMentionBar) {
      setState(() => _showMentionBar = wantsMention);
    } else {
      setState(() {});
    }
  }

  void _insertMention(AppUser founder) {
    final current = _msgController.text;
    final prefix = current.endsWith('@')
        ? current.substring(0, current.length - 1)
        : (current.isEmpty || current.endsWith(' ') ? current : '$current ');
    final nextText = '$prefix@${founder.name} ';
    _msgController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    setState(() => _showMentionBar = false);
  }

  Future<void> _togglePlayVoice(ChatMessage msg) async {
    if (_playingVoiceMsgId == msg.id) {
      try {
        await _audioPlayer?.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _playingVoiceMsgId = null;
          _audioPosition = Duration.zero;
        });
      }
      return;
    }

    setState(() {
      _playingVoiceMsgId = msg.id;
      _audioPosition = Duration.zero;
      _audioDuration = Duration(seconds: msg.voiceDurationSec ?? 1);
    });
    if (_isTestEnv || msg.attachmentUrl == null || msg.attachmentUrl!.isEmpty) {
      return;
    }

    try {
      _audioPlayer ??= AudioPlayer();
      _playerCompleteSub ??= _audioPlayer!.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _playingVoiceMsgId = null;
            _audioPosition = Duration.zero;
          });
        }
      });
      _playerPosSub ??= _audioPlayer!.onPositionChanged.listen((pos) {
        if (mounted) setState(() => _audioPosition = pos);
      });
      _playerDurSub ??= _audioPlayer!.onDurationChanged.listen((dur) {
        if (mounted && dur.inMilliseconds > 0) {
          setState(() => _audioDuration = dur);
        }
      });

      await _audioPlayer!.stop();
      await _audioPlayer!.setPlaybackRate(_playbackSpeed);
      final url = msg.attachmentUrl!;
      if (url.startsWith('http')) {
        await _audioPlayer!.play(UrlSource(url));
      } else if (File(url).existsSync()) {
        await _audioPlayer!.play(DeviceFileSource(url));
      }
    } catch (_) {
      if (mounted) setState(() => _playingVoiceMsgId = null);
    }
  }

  Future<void> _cyclePlaybackSpeed() async {
    final next = _playbackSpeed == 1.0
        ? 1.5
        : (_playbackSpeed == 1.5 ? 2.0 : 1.0);
    setState(() => _playbackSpeed = next);
    try {
      if (_playingVoiceMsgId != null) {
        await _audioPlayer?.setPlaybackRate(next);
      }
    } catch (_) {}
  }

  Future<void> _startWhatsAppRecording({required bool locked}) async {
    if (_isRecording || _isSendingVoice) return;
    if (_isTestEnv) {
      setState(() {
        _isRecording = true;
        _isRecordingLocked = locked;
        _recordedSec = 1;
      });
      return;
    }

    try {
      _recorder ??= AudioRecorder();
      final permitted = await _recorder!.hasPermission();
      if (!permitted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission required for voice chat.'),
            ),
          );
        }
        return;
      }
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/bh_wa_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
        ),
        path: outPath,
      );
      HapticFeedback.mediumImpact();

      _ampSub?.cancel();
      _ampSub = _recorder!
          .onAmplitudeChanged(const Duration(milliseconds: 110))
          .listen((amp) {
        if (!mounted || _isRecordingPaused) return;
        final normalized = ((amp.current + 55) / 55).clamp(0.15, 1.0);
        setState(() {
          if (_waveSamples.length >= 24) _waveSamples.removeAt(0);
          _waveSamples.add(normalized);
        });
      });

      _recordTimer?.cancel();
      _recordedSec = 0;
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _isRecording && !_isRecordingPaused) {
          setState(() => _recordedSec++);
        }
      });

      setState(() {
        _isRecording = true;
        _isRecordingLocked = locked;
        _isRecordingPaused = false;
        _cancelBySlide = false;
        _dragOffsetX = 0;
        _dragOffsetY = 0;
      });
    } catch (_) {
      await _cancelWhatsAppRecording();
    }
  }

  Future<void> _togglePauseRecording() async {
    if (!_isRecording || _isTestEnv || _recorder == null) return;
    try {
      if (_isRecordingPaused) {
        await _recorder!.resume();
      } else {
        await _recorder!.pause();
      }
      setState(() => _isRecordingPaused = !_isRecordingPaused);
    } catch (_) {}
  }

  Future<void> _cancelWhatsAppRecording() async {
    _recordTimer?.cancel();
    _ampSub?.cancel();
    try {
      await _recorder?.cancel();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _isRecording = false;
        _isRecordingLocked = false;
        _isRecordingPaused = false;
        _cancelBySlide = false;
        _recordedSec = 0;
        _dragOffsetX = 0;
        _dragOffsetY = 0;
      });
    }
    HapticFeedback.lightImpact();
  }

  Future<void> _finishAndSendRecording() async {
    if (!_isRecording || _isSendingVoice) return;
    final durSec = _recordedSec < 1 ? 1 : _recordedSec;
    _recordTimer?.cancel();
    _ampSub?.cancel();

    setState(() {
      _isRecording = false;
      _isRecordingLocked = false;
      _isRecordingPaused = false;
      _isSendingVoice = true;
      _dragOffsetX = 0;
      _dragOffsetY = 0;
    });

    try {
      String? remoteUrl;
      String? sizeLabel;
      if (!_isTestEnv && _recorder != null) {
        final path = await _recorder!.stop();
        if (path != null && File(path).existsSync()) {
          final uploaded = await ref
              .read(agencyStoreProvider.notifier)
              .uploadChatMedia(File(path));
          remoteUrl = uploaded.url;
          sizeLabel = uploaded.sizeLabel;
        }
      }
      if (mounted) {
        _sendMessage(
          type: 'voice',
          customBody: 'Voice Message',
          attachmentName: 'VoiceNote.m4a',
          attachmentSize: sizeLabel,
          attachmentUrl: remoteUrl,
          voiceSec: durSec,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingVoice = false;
          _recordedSec = 0;
        });
      }
    }
  }

  String _fmtDuration(int totalSeconds) {
    final s = totalSeconds < 0 ? 0 : totalSeconds;
    final m = s ~/ 60;
    final rem = s % 60;
    return '$m:${rem.toString().padLeft(2, '0')}';
  }

  void _openAttachmentViewer(ChatMessage msg) {
    if (msg.attachmentName == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatAttachmentViewerScreen(
          fileName: msg.attachmentName!,
          attachmentUrl: msg.attachmentUrl,
          sizeLabel: msg.attachmentSize,
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage({
    String type = 'text',
    String? customBody,
    String? attachmentName,
    String? attachmentSize,
    String? attachmentUrl,
    int? voiceSec,
  }) {
    final text = customBody ?? _msgController.text.trim();
    if (text.isEmpty && attachmentName == null && voiceSec == null) return;

    ref.read(agencyStoreProvider.notifier).sendChatMessage(
          threadId: widget.threadId,
          body: text,
          messageType: type,
          attachmentName: attachmentName,
          attachmentSize: attachmentSize,
          attachmentUrl: attachmentUrl,
          voiceDurationSec: voiceSec,
          replyToSender: _replyingTo?.senderName,
          replyToPreview: _replyingTo?.body,
        );
    setState(() {
      _msgController.clear();
      _replyingTo = null;
      _showMentionBar = false;
    });
    _scrollToBottom();
  }

  void _showShareAttachmentSheet() {
    final fileNameCtrl = TextEditingController();
    final captionCtrl = TextEditingController();
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Photo, File or Link',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isUploading
                              ? null
                              : () async {
                                  final picked = await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 82,
                                  );
                                  if (picked == null) return;
                                  setModalState(() => isUploading = true);
                                  final uploaded = await ref
                                      .read(agencyStoreProvider.notifier)
                                      .uploadChatMedia(File(picked.path));
                                  if (!ctx.mounted) return;
                                  _sendMessage(
                                    type: 'image',
                                    customBody: captionCtrl.text.trim().isEmpty
                                        ? 'Shared photo: ${picked.name}'
                                        : captionCtrl.text.trim(),
                                    attachmentName: picked.name,
                                    attachmentSize: uploaded.sizeLabel,
                                    attachmentUrl: uploaded.url,
                                  );
                                  Navigator.pop(ctx);
                                },
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Photo / Image'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isUploading
                              ? null
                              : () async {
                                  final files = await FilePicker.pickFiles();
                                  if (files.isEmpty ||
                                      files.first.path == null) {
                                    return;
                                  }
                                  final picked = files.first;
                                  setModalState(() => isUploading = true);
                                  final uploaded = await ref
                                      .read(agencyStoreProvider.notifier)
                                      .uploadChatMedia(File(picked.path!));
                                  if (!ctx.mounted) return;
                                  _sendMessage(
                                    type: 'document',
                                    customBody: captionCtrl.text.trim().isEmpty
                                        ? 'Shared file: ${picked.name}'
                                        : captionCtrl.text.trim(),
                                    attachmentName: picked.name,
                                    attachmentSize: uploaded.sizeLabel,
                                    attachmentUrl: uploaded.url,
                                  );
                                  Navigator.pop(ctx);
                                },
                          icon: const Icon(Icons.folder_open_rounded, size: 18),
                          label: const Text('PDF / File'),
                        ),
                      ),
                    ],
                  ),
                  if (isUploading) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: fileNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Or paste File Name / Link *',
                      prefixIcon: Icon(Icons.insert_drive_file_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: captionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Message / Note (Optional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () {
                              if (fileNameCtrl.text.trim().isEmpty) return;
                              _sendMessage(
                                type: 'document',
                                customBody: captionCtrl.text.trim().isEmpty
                                    ? 'Shared attachment'
                                    : captionCtrl.text.trim(),
                                attachmentName: fileNameCtrl.text.trim(),
                              );
                              Navigator.pop(ctx);
                            },
                      icon: const Icon(Icons.send_rounded, size: 17),
                      label: const Text('Send Attachment'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMessageActionsSheet(ChatThread thread, ChatMessage msg) {
    final notifier = ref.read(agencyStoreProvider.notifier);
    final storeState = ref.read(agencyStoreProvider);
    final currentFounder = storeState.currentUser;
    final seenNames = _resolveSeenByFirstNames(msg, storeState.employees);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Read receipt status
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (seenNames.isNotEmpty
                            ? const Color(0xFF38BDF8)
                            : Colors.grey)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        storeState.isOfflineMode
                            ? Icons.done_rounded
                            : Icons.done_all_rounded,
                        size: 16,
                        color: seenNames.isNotEmpty
                            ? const Color(0xFF38BDF8)
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          seenNames.isNotEmpty
                              ? 'Seen by ${seenNames.join(', ')}'
                              : 'Delivered • Waiting to be seen',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: seenNames.isNotEmpty
                                ? const Color(0xFF38BDF8)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick Emoji Reaction Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _reactionEmojis.map((emoji) {
                    final isSelected = msg.reactions.containsKey(emoji);
                    final isSheetDark =
                        Theme.of(ctx).brightness == Brightness.dark;
                    return InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        notifier.toggleMessageReaction(
                          thread.id,
                          msg.id,
                          emoji,
                        );
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.electricBlue.withValues(alpha: 0.22)
                              : (isSheetDark
                                  ? AppColors.darkElevatedSurface
                                  : AppColors.lightElevatedSurface),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.electricBlue)
                              : null,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.reply_rounded,
                    color: AppColors.electricBlue,
                  ),
                  title: const Text('Reply to Message'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _replyingTo = msg);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    msg.isPinned
                        ? Icons.push_pin_outlined
                        : Icons.push_pin_rounded,
                    color: AppColors.warning,
                  ),
                  title: Text(
                    msg.isPinned ? 'Unpin Message' : 'Pin Message to Top',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    notifier.togglePinMessage(thread.id, msg.id);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.add_task_rounded,
                    color: AppColors.successSoft,
                  ),
                  title: const Text('Convert Message to Studio Task'),
                  onTap: () {
                    Navigator.pop(ctx);
                    notifier.createTask(
                      title: msg.body,
                      description:
                          'Created from ${thread.name} message by ${msg.senderName}.',
                      projectId: 'proj-chat',
                      projectName: 'Founders Chat Action',
                      assignedEmployee: currentFounder.name,
                      priority: 'High',
                      deadline: DateTime.now().add(const Duration(days: 3)),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task created and added to Tasks Board.'),
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Copy Message Text'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: msg.body));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message copied to clipboard.'),
                      ),
                    );
                  },
                ),
                if (currentFounder.isSuperAdmin ||
                    msg.senderId == currentFounder.id)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    title: Text(
                      currentFounder.isSuperAdmin &&
                              msg.senderId != currentFounder.id
                          ? 'Delete Message (Super Admin)'
                          : 'Delete Message',
                      style: const TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      notifier.deleteChatMessage(thread.id, msg.id);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final notifier = ref.read(agencyStoreProvider.notifier);
    final thread = state.chatThreads.firstWhere(
      (t) => t.id == widget.threadId,
      orElse: () => state.chatThreads.first,
    );
    final pinnedMessages =
        thread.messages.where((m) => m.isPinned).toList();
    final hasUnmarkedForViewer = thread.unreadCount > 0 ||
        thread.messages.any((m) => !m.seenBy.contains(state.currentUser.id));
    if (hasUnmarkedForViewer) {
      _queueMarkThreadRead();
    }
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: Row(
          children: [
            if (thread.isChannel)
              const BhBrandLogo(size: 34, showGlow: false)
            else
              BhAvatar(name: thread.name, size: 34, isOnline: true),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    thread.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (thread.messages.isNotEmpty && state.currentUser.isSuperAdmin)
            IconButton(
              tooltip: 'Clear Chat History (Super Admin)',
              onPressed: () {
                notifier.clearThreadMessages(thread.id);
              },
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: BhAmbientCanvas(
        child: Column(
          children: [
            // Pinned Message Banner (if any)
            if (pinnedMessages.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.14),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.warning.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.push_pin_rounded,
                      size: 15,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pinned (${pinnedMessages.last.senderName}): ${pinnedMessages.last.body}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => notifier.togglePinMessage(
                        thread.id,
                        pinnedMessages.last.id,
                      ),
                      child: const Icon(Icons.close_rounded, size: 15),
                    ),
                  ],
                ),
              ),

            // Messages List
            Expanded(
              child: thread.messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: BhArtisticEmptyState(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: thread.name,
                          description:
                              '${thread.subtitle}\n\nNo messages yet. Type a message below to start your conversation.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: thread.messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final msg = thread.messages[index];
                        final isFromMe =
                            msg.senderId == state.currentUser.id;
                        final isVoicePlaying = _playingVoiceMsgId == msg.id;

                        return GestureDetector(
                          onLongPress: () =>
                              _showMessageActionsSheet(thread, msg),
                          child: Align(
                            alignment: isFromMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.84,
                              ),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient:
                                    isFromMe ? AppColors.brandGradient : null,
                                color: isFromMe
                                    ? null
                                    : (isDark
                                        ? AppColors.darkSurface
                                        : AppColors.lightSurface),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft:
                                      Radius.circular(isFromMe ? 18 : 4),
                                  bottomRight:
                                      Radius.circular(isFromMe ? 4 : 18),
                                ),
                                border: isFromMe
                                    ? null
                                    : Border.all(
                                        color: isDark
                                            ? AppColors.darkBorder
                                            : AppColors.lightBorder,
                                      ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Sender Header
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (msg.isPinned) ...[
                                        Icon(
                                          Icons.push_pin_rounded,
                                          size: 12,
                                          color: isFromMe
                                              ? Colors.amberAccent
                                              : AppColors.warning,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        msg.senderName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isFromMe
                                              ? Colors.white
                                              : AppColors.electricBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          msg.senderRole,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isFromMe
                                                ? Colors.white
                                                    .withValues(alpha: 0.78)
                                                : (isDark
                                                    ? AppColors.darkTextSecondary
                                                    : AppColors
                                                        .lightTextSecondary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Reply Quote if present
                                  if (msg.replyToPreview != null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '↪ ${msg.replyToSender}: ${msg.replyToPreview}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isFromMe
                                              ? Colors.white
                                                  .withValues(alpha: 0.9)
                                              : (isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                      .lightTextSecondary),
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 6),
                                  Text(
                                    msg.body,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.42,
                                      color: isFromMe
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary),
                                    ),
                                  ),

                                  // WhatsApp-Style Voice Note Player if voice message
                                  if (msg.messageType == 'voice' ||
                                      msg.voiceDurationSec != null) ...[
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (context) {
                                        final totalSec = msg.voiceDurationSec ?? 12;
                                        final durMs = isVoicePlaying &&
                                                _audioDuration.inMilliseconds > 0
                                            ? _audioDuration.inMilliseconds
                                            : totalSec * 1000;
                                        final progress = isVoicePlaying
                                            ? (_audioPosition.inMilliseconds /
                                                    durMs)
                                                .clamp(0.0, 1.0)
                                            : 0.0;
                                        const barHeights = [
                                          8.0, 14.0, 20.0, 11.0, 18.0, 24.0,
                                          15.0, 9.0, 22.0, 16.0, 12.0, 20.0,
                                          25.0, 14.0, 10.0, 19.0, 15.0, 21.0,
                                          12.0, 9.0,
                                        ];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: isFromMe ? 0.22 : 0.14,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                onTap: () =>
                                                    _togglePlayVoice(msg),
                                                child: Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: isFromMe
                                                        ? Colors.white
                                                            .withValues(
                                                                alpha: 0.22)
                                                        : AppColors.electricBlue
                                                            .withValues(
                                                                alpha: 0.2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    isVoicePlaying
                                                        ? Icons.pause_rounded
                                                        : Icons
                                                            .play_arrow_rounded,
                                                    color: isFromMe
                                                        ? Colors.white
                                                        : AppColors.electricBlue,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: List.generate(
                                                      barHeights.length,
                                                      (bi) {
                                                        final barPct =
                                                            (bi + 1) /
                                                                barHeights
                                                                    .length;
                                                        final active =
                                                            isVoicePlaying &&
                                                                barPct <=
                                                                    progress +
                                                                        0.05;
                                                        return Container(
                                                          width: 3,
                                                          height:
                                                              barHeights[bi],
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 2.5),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: active
                                                                ? AppColors
                                                                    .cyanAccent
                                                                : (isFromMe
                                                                    ? Colors
                                                                        .white
                                                                        .withValues(
                                                                            alpha:
                                                                                0.55)
                                                                    : AppColors
                                                                        .electricBlue
                                                                        .withValues(
                                                                            alpha:
                                                                                0.45)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        99),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        isVoicePlaying
                                                            ? '${_fmtDuration(_audioPosition.inSeconds)} / ${_fmtDuration(totalSec)}'
                                                            : _fmtDuration(
                                                                totalSec),
                                                        style: TextStyle(
                                                          fontSize: 10.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: isFromMe
                                                              ? Colors.white70
                                                              : (isDark
                                                                  ? AppColors
                                                                      .darkTextSecondary
                                                                  : AppColors
                                                                      .lightTextSecondary),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      GestureDetector(
                                                        onTap:
                                                            _cyclePlaybackSpeed,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 6,
                                                            vertical: 1.5,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        999),
                                                          ),
                                                          child: Text(
                                                            '${_playbackSpeed == 1.0 ? '1' : _playbackSpeed}x',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],

                                  // Image Preview if photo attachment (tap opens full-screen viewer)
                                  if (msg.messageType == 'image' &&
                                      msg.attachmentUrl != null &&
                                      msg.attachmentUrl!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () => _openAttachmentViewer(msg),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 180,
                                            maxWidth: 230,
                                          ),
                                          child: msg.attachmentUrl!
                                                  .startsWith('http')
                                              ? Image.network(
                                                  msg.attachmentUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) =>
                                                      const SizedBox.shrink(),
                                                )
                                              : (File(msg.attachmentUrl!)
                                                      .existsSync()
                                                  ? Image.file(
                                                      File(msg.attachmentUrl!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : const SizedBox.shrink()),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Document / PDF / File Card (tap opens built-in Viewer)
                                  if (msg.attachmentName != null &&
                                      msg.messageType != 'voice') ...[
                                    const SizedBox(height: 10),
                                    Builder(
                                      builder: (context) {
                                        final isPdf = msg.attachmentName!
                                            .toLowerCase()
                                            .endsWith('.pdf');
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          onTap: () =>
                                              _openAttachmentViewer(msg),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.22),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.14),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    color: (isPdf
                                                            ? AppColors.error
                                                            : (msg.messageType ==
                                                                    'image'
                                                                ? AppColors
                                                                    .cyanAccent
                                                                : AppColors
                                                                    .electricBlue))
                                                        .withValues(
                                                            alpha: 0.22),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9),
                                                  ),
                                                  child: Icon(
                                                    isPdf
                                                        ? Icons
                                                            .picture_as_pdf_rounded
                                                        : (msg.messageType ==
                                                                'image'
                                                            ? Icons
                                                                .image_rounded
                                                            : Icons
                                                                .description_rounded),
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        msg.attachmentName!,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        '${msg.attachmentSize ?? (isPdf ? 'PDF Document' : 'File')} • Tap to open viewer',
                                                        style: TextStyle(
                                                          fontSize: 10.5,
                                                          color: Colors.white
                                                              .withValues(
                                                                  alpha: 0.78),
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
                                    ),
                                  ],

                                  const SizedBox(height: 8),
                                  // Reactions & Timestamp Row
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      ...msg.reactions.entries.map(
                                        (entry) => GestureDetector(
                                          onTap: () => notifier
                                              .toggleMessageReaction(
                                                thread.id,
                                                msg.id,
                                                entry.key,
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.22),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              '${entry.key} ${entry.value}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () =>
                                            _showMessageActionsSheet(
                                              thread,
                                              msg,
                                            ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Icon(
                                            Icons.add_reaction_outlined,
                                            size: 14,
                                            color: isFromMe
                                                ? Colors.white70
                                                : AppColors.electricBlue,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        BhFormatters.time12h(msg.timestamp),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isFromMe
                                              ? Colors.white70
                                              : (isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                      .lightTextSecondary),
                                        ),
                                      ),
                                      if (isFromMe) ...[
                                        const SizedBox(width: 6),
                                        Builder(
                                          builder: (_) {
                                            final seenNames =
                                                _resolveSeenByFirstNames(
                                              msg,
                                              state.employees,
                                            );
                                            final isSeen = seenNames.isNotEmpty;
                                            final seenLabel = thread.isChannel
                                                ? 'Seen by ${seenNames.join(', ')}'
                                                : 'Seen';
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isSeen ? 6 : 2,
                                                vertical: isSeen ? 2 : 0,
                                              ),
                                              decoration: isSeen
                                                  ? BoxDecoration(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.22),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFF38BDF8,
                                                        ).withValues(
                                                            alpha: 0.55),
                                                      ),
                                                    )
                                                  : null,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    state.isOfflineMode
                                                        ? Icons.done_rounded
                                                        : Icons
                                                            .done_all_rounded,
                                                    size: 14,
                                                    color: isSeen
                                                        ? const Color(
                                                            0xFF38BDF8)
                                                        : Colors.white70,
                                                  ),
                                                  if (isSeen) ...[
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      seenLabel,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xFF7DD3FC),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Reply Preview Banner
            if (_replyingTo != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark
                    ? AppColors.darkElevatedSurface
                    : AppColors.lightElevatedSurface,
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply_rounded,
                      size: 16,
                      color: AppColors.electricBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to ${_replyingTo!.senderName}: ${_replyingTo!.body}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _replyingTo = null),
                      icon: const Icon(Icons.close_rounded, size: 16),
                    ),
                  ],
                ),
              ),

            // Live Typing Indicator + @Mention Quick Bar
            if (state.typingByThread[thread.id] != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                color: AppColors.electricBlue.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    const Icon(
                      Icons.more_horiz_rounded,
                      size: 16,
                      color: AppColors.electricBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.typingByThread[thread.id]} is typing...',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ],
                ),
              ),

            if (_showMentionBar)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: isDark
                    ? AppColors.darkElevatedSurface
                    : AppColors.lightElevatedSurface,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: state.employees
                        .where((e) => e.id != state.currentUser.id)
                        .map(
                          (founder) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              avatar: BhAvatar(
                                name: founder.name,
                                size: 22,
                                isOnline: founder.isOnline,
                              ),
                              label: Text(
                                '@${founder.name}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () => _insertMention(founder),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

            // WhatsApp-Style Composer Bar OR Live Recording Bar
            Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 10, 18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: _isRecording
                  ? _buildWhatsAppRecordingBar(isDark)
                  : Row(
                      children: [
                        IconButton(
                          tooltip: 'Attach Photo or File',
                          onPressed: _showShareAttachmentSheet,
                          icon: const Icon(Icons.attach_file_rounded, size: 21),
                        ),
                        IconButton(
                          tooltip: 'Mention Founder (@)',
                          onPressed: () =>
                              setState(() => _showMentionBar = !_showMentionBar),
                          icon: Icon(
                            Icons.alternate_email_rounded,
                            size: 20,
                            color:
                                _showMentionBar ? AppColors.electricBlue : null,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            onChanged: _onComposerChanged,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Message ${thread.name}...',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isSendingVoice)
                          const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            ),
                          )
                        else if (_msgController.text.trim().isNotEmpty)
                          IconButton.filled(
                            tooltip: 'Send Message',
                            onPressed: _sendMessage,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.electricBlue,
                              padding: const EdgeInsets.all(13),
                            ),
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () =>
                                _startWhatsAppRecording(locked: true),
                            onLongPressStart: (details) {
                              _pressOrigin = details.globalPosition;
                              _startWhatsAppRecording(locked: false);
                            },
                            onLongPressMoveUpdate: (details) {
                              if (!_isRecording || _isRecordingLocked) return;
                              final origin = _pressOrigin ?? details.globalPosition;
                              final dx = details.globalPosition.dx - origin.dx;
                              final dy = details.globalPosition.dy - origin.dy;
                              setState(() {
                                _dragOffsetX = dx;
                                _dragOffsetY = dy;
                                _cancelBySlide = dx < -85;
                              });
                              if (dy < -55) {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isRecordingLocked = true;
                                  _cancelBySlide = false;
                                });
                              } else if (_cancelBySlide) {
                                _cancelWhatsAppRecording();
                              }
                            },
                            onLongPressEnd: (_) {
                              if (_isRecording &&
                                  !_isRecordingLocked &&
                                  !_cancelBySlide) {
                                _finishAndSendRecording();
                              }
                            },
                            child: Tooltip(
                              message: 'Hold or Tap to Record Voice Note',
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 22,
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
    );
  }

  Widget _buildWhatsAppRecordingBar(bool isDark) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Delete Voice Recording',
          onPressed: _cancelWhatsAppRecording,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.error,
            size: 24,
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _isRecordingPaused ? AppColors.warning : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _fmtDuration(_recordedSec),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _isRecordingLocked
              ? SizedBox(
                  height: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _waveSamples
                        .take(18)
                        .map(
                          (v) => AnimatedContainer(
                            duration: const Duration(milliseconds: 90),
                            width: 3,
                            height: 6 + (v * 20),
                            margin: const EdgeInsets.only(right: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : Transform.translate(
                  offset: Offset(_dragOffsetX.clamp(-80, 0), 0),
                  child: Text(
                    _dragOffsetY < -20
                        ? '↑ Release to Lock'
                        : '< Slide left to cancel',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
        ),
        if (_isRecordingLocked) ...[
          IconButton(
            tooltip: _isRecordingPaused ? 'Resume' : 'Pause',
            onPressed: _togglePauseRecording,
            icon: Icon(
              _isRecordingPaused
                  ? Icons.mic_rounded
                  : Icons.pause_circle_outline_rounded,
              color: AppColors.electricBlue,
              size: 24,
            ),
          ),
          IconButton.filled(
            tooltip: 'Send Voice Note',
            onPressed: _finishAndSendRecording,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ] else
          Transform.translate(
            offset: Offset(0, _dragOffsetY.clamp(-50, 0)),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
      ],
    );
  }
}
