import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../core/services/server_config.dart';
import '../../core/theme/app_colors.dart';

/// In-app multi-format viewer for PDFs, images, text/code files, and documents shared in Chat.
class ChatAttachmentViewerScreen extends StatefulWidget {
  final String fileName;
  final String? attachmentUrl;
  final String? sizeLabel;

  const ChatAttachmentViewerScreen({
    super.key,
    required this.fileName,
    this.attachmentUrl,
    this.sizeLabel,
  });

  @override
  State<ChatAttachmentViewerScreen> createState() =>
      _ChatAttachmentViewerScreenState();
}

class _ChatAttachmentViewerScreenState
    extends State<ChatAttachmentViewerScreen> {
  bool _loading = true;
  String? _error;
  Uint8List? _bytes;
  File? _cachedFile;
  final List<Uint8List> _pdfPagePngs = [];

  String get _ext {
    final name = widget.fileName.toLowerCase();
    final idx = name.lastIndexOf('.');
    return idx >= 0 ? name.substring(idx + 1) : '';
  }

  bool get _isPdf => _ext == 'pdf';
  bool get _isImage =>
      const {'png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'}.contains(_ext);
  bool get _isText => const {
        'txt',
        'md',
        'csv',
        'json',
        'xml',
        'yaml',
        'yml',
        'log',
        'sql',
        'php',
        'dart',
        'js',
        'ts',
        'html',
        'css',
      }.contains(_ext);

  @override
  void initState() {
    super.initState();
    _loadAttachment();
  }

  Future<void> _loadAttachment() async {
    final source = widget.attachmentUrl?.trim() ?? '';
    if (source.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'This item is a link/text reference (${widget.fileName}).';
      });
      return;
    }

    try {
      Uint8List? loadedBytes;
      File? diskFile;

      if (!source.startsWith('http://') && !source.startsWith('https://')) {
        final local = File(source);
        if (await local.exists()) {
          loadedBytes = await local.readAsBytes();
          diskFile = local;
        }
      } else {
        // Build candidate URLs (original host first, then configured server fallbacks for same file)
        final candidates = <String>[source];
        final uri = Uri.tryParse(source);
        final fileQuery = uri?.queryParameters['file'];
        if (fileQuery != null && fileQuery.isNotEmpty) {
          for (final base in BhServerConfig.instance.baseUrls) {
            final alt = '$base/index.php?action=media&file=$fileQuery';
            if (!candidates.contains(alt)) candidates.add(alt);
          }
        }

        final client = HttpClient()
          ..connectionTimeout = const Duration(seconds: 6);
        try {
          for (final url in candidates) {
            try {
              final req = await client.getUrl(Uri.parse(url));
              final resp = await req.close();
              if (resp.statusCode == 200) {
                loadedBytes = await consolidateHttpClientResponseBytes(resp);
                break;
              }
            } catch (_) {}
          }
        } finally {
          client.close(force: true);
        }

        if (loadedBytes != null) {
          final tempDir = await getTemporaryDirectory();
          final safeName = widget.fileName.replaceAll(RegExp(r'[^\w.\-]'), '_');
          diskFile = File('${tempDir.path}/bh_view_$safeName');
          await diskFile.writeAsBytes(loadedBytes, flush: true);
        }
      }

      if (loadedBytes == null) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Unable to load file bytes from studio storage or network.';
        });
        return;
      }

      if (_isPdf) {
        await for (final page in Printing.raster(loadedBytes, dpi: 150)) {
          final png = await page.toPng();
          if (!mounted) return;
          _pdfPagePngs.add(png);
        }
      }

      if (!mounted) return;
      setState(() {
        _bytes = loadedBytes;
        _cachedFile = diskFile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not preview file: $e';
      });
    }
  }

  Future<void> _openExternally() async {
    final target = _cachedFile;
    if (target != null && await target.exists()) {
      final res = await OpenFilex.open(target.path);
      if (res.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No external viewer found (${res.message}).')),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not available locally yet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            Text(
              _isPdf && _pdfPagePngs.isNotEmpty
                  ? 'PDF • ${_pdfPagePngs.length} page${_pdfPagePngs.length == 1 ? '' : 's'}${widget.sizeLabel != null ? ' • ${widget.sizeLabel}' : ''}'
                  : '${_ext.isEmpty ? 'FILE' : _ext.toUpperCase()}${widget.sizeLabel != null ? ' • ${widget.sizeLabel}' : ''}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          if (_isPdf && _bytes != null)
            IconButton(
              tooltip: 'Share / Print PDF',
              onPressed: () => Printing.sharePdf(
                bytes: _bytes!,
                filename: widget.fileName,
              ),
              icon: const Icon(Icons.share_rounded),
            ),
          if (_cachedFile != null)
            IconButton(
              tooltip: 'Open in External App',
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_new_rounded),
            ),
        ],
      ),
      body: _buildBody(context, isDark),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Loading file preview...'),
          ],
        ),
      );
    }

    if (_error != null || _bytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                size: 54,
                color: AppColors.electricBlue,
              ),
              const SizedBox(height: 14),
              Text(
                widget.fileName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'No preview available for this item.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (widget.attachmentUrl != null &&
                  widget.attachmentUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.attachmentUrl!),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File reference copied')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 17),
                  label: const Text('Copy Link / Path'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_isImage) {
      return Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: Image.memory(_bytes!, fit: BoxFit.contain),
          ),
        ),
      );
    }

    if (_isPdf && _pdfPagePngs.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: _pdfPagePngs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, idx) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.memory(_pdfPagePngs[idx], fit: BoxFit.fitWidth),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Page ${idx + 1} of ${_pdfPagePngs.length}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          );
        },
      );
    }

    if (_isText) {
      final decoded = utf8.decode(_bytes!, allowMalformed: true);
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark
                ? AppColors.darkElevatedSurface
                : AppColors.lightElevatedSurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${decoded.length} characters',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: decoded));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied file contents')),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  label: const Text('Copy All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                decoded,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Generic document/binary viewer fallback (DOCX, XLSX, ZIP, etc.)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_rounded,
                size: 46,
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.fileName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Ready (${(_bytes!.length / 1024).toStringAsFixed(1)} KB)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _openExternally,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text(
                'Open in Device App',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

