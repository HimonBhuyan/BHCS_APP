import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

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
                                      Text(
                                        thread.messages.isEmpty
                                            ? 'Tap to start messaging'
                                            : thread.lastMessagePreview,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: thread.unreadCount > 0
                                              ? FontWeight.w700
                                              : null,
                                        ),
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

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    int? voiceSec,
  }) {
    final text = customBody ?? _msgController.text.trim();
    if (text.isEmpty && attachmentName == null && voiceSec == null) return;

    ref.read(agencyStoreProvider.notifier).sendChatMessage(
          threadId: widget.threadId,
          body: text,
          messageType: type,
          attachmentName: attachmentName,
          voiceDurationSec: voiceSec,
          replyToSender: _replyingTo?.senderName,
          replyToPreview: _replyingTo?.body,
        );
    setState(() {
      _msgController.clear();
      _replyingTo = null;
    });
    _scrollToBottom();
  }

  void _showVoiceNoteSheet() {
    int selectedDurationSec = 12;
    final noteCtrl = TextEditingController(text: 'Founder Voice Memo');

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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send Founder Voice Note',
                              style: Theme.of(ctx).textTheme.headlineSmall,
                            ),
                            Text(
                              'High-clarity Opus audio memo for the studio',
                              style: Theme.of(ctx).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Voice Note Topic / Transcript Summary',
                      prefixIcon: Icon(Icons.graphic_eq_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Audio Length:',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '0:${selectedDurationSec.toString().padLeft(2, '0')} sec',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: selectedDurationSec.toDouble(),
                    min: 4,
                    max: 59,
                    divisions: 55,
                    activeColor: AppColors.electricBlue,
                    onChanged: (v) =>
                        setModalState(() => selectedDurationSec = v.round()),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _sendMessage(
                          type: 'voice',
                          customBody: noteCtrl.text.trim().isEmpty
                              ? 'Founder Voice Memo'
                              : noteCtrl.text.trim(),
                          voiceSec: selectedDurationSec,
                        );
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.send_rounded, size: 17),
                      label: const Text('Send Voice Note'),
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

  void _showShareAttachmentSheet() {
    final fileNameCtrl = TextEditingController();
    final captionCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
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
                'Share Document or Link',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fileNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'File Name or Link *',
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
                  onPressed: () {
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
  }

  void _showMessageActionsSheet(ChatThread thread, ChatMessage msg) {
    final notifier = ref.read(agencyStoreProvider.notifier);
    final currentFounder = ref.read(agencyStoreProvider).currentUser;

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

                                  // Voice Note Player if voice message
                                  if (msg.messageType == 'voice' ||
                                      msg.voiceDurationSec != null) ...[
                                    const SizedBox(height: 10),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          _playingVoiceMsgId = isVoicePlaying
                                              ? null
                                              : msg.id;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.22),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isVoicePlaying
                                                  ? Icons.pause_circle_filled_rounded
                                                  : Icons.play_circle_fill_rounded,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.graphic_eq_rounded,
                                              color: isVoicePlaying
                                                  ? AppColors.cyanAccent
                                                  : Colors.white70,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '0:${(msg.voiceDurationSec ?? 12).toString().padLeft(2, '0')}',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Document Attachment Preview
                                  if (msg.attachmentName != null) ...[
                                    const SizedBox(height: 10),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Opening attachment: ${msg.attachmentName}',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.insert_drive_file_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                msg.attachmentName!,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                      if (isFromMe)
                                        const Icon(
                                          Icons.done_all_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
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

            // Message Composer Bar
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
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Attach File or Link',
                    onPressed: _showShareAttachmentSheet,
                    icon: const Icon(Icons.attach_file_rounded, size: 21),
                  ),
                  IconButton(
                    tooltip: 'Record Voice Note',
                    onPressed: _showVoiceNoteSheet,
                    icon: const Icon(Icons.mic_none_rounded, size: 21),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Message ${thread.name}...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
