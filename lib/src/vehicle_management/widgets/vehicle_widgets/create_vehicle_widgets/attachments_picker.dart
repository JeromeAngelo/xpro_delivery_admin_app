import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

/// Multi-file attachment picker.
///
/// Uses the `file_selector` plugin (already declared in `pubspec.yaml`)
/// to open a system file dialog. The selected files are returned to
/// the parent via [onAttachmentsChanged] as a list of `XFile`s. The
/// widget re-renders the current selection as removable chips.
///
/// We return `XFile` objects (rather than just the file path) so the
/// caller has access to the file's `name`, `mimeType` and `length`
/// for upload.
class AttachmentsPicker extends StatelessWidget {
  /// Currently selected attachments. May be empty.
  final List<XFile> attachments;

  /// Called whenever the user adds or removes a file.
  final ValueChanged<List<XFile>> onAttachmentsChanged;

  /// Optional label shown above the picker.
  final String label;

  /// Optional helper text shown under the picker.
  final String? helperText;

  const AttachmentsPicker({
    super.key,
    required this.attachments,
    required this.onAttachmentsChanged,
    this.label = 'Attachments',
    this.helperText,
  });

  Future<void> _pickFiles() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'attachments',
        extensions: <String>[
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
        ],
      );
      final files = await openFiles(
        acceptedTypeGroups: <XTypeGroup>[typeGroup],
      );
      if (files.isEmpty) return;
      onAttachmentsChanged([...attachments, ...files]);
    } catch (e) {
      debugPrint('❌ [ATTACHMENTS] Failed to pick files: $e');
    }
  }

  void _removeFile(XFile file) {
    onAttachmentsChanged(
      attachments.where((f) => f.path != file.path).toList(),
    );
  }

  String _humanSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row – label + "Add files" button.
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.attach_file, size: 18),
                label: const Text('Add files'),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 4),
            Text(
              helperText!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 8),

          // Selected files list.
          if (attachments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                'No attachments selected',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  attachments.map((file) {
                    // `XFile.length` is a `Future<int>`; we display the
                    // name and only enrich the tooltip with the size
                    // once the future resolves.
                    return FutureBuilder<int>(
                      future: file.length(),
                      builder: (context, snap) {
                        final size = snap.hasData ? _humanSize(snap.data!) : '';
                        return InputChip(
                          avatar: const Icon(Icons.insert_drive_file, size: 16),
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              file.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeFile(file),
                          tooltip:
                              size.isEmpty ? file.name : '${file.name} • $size',
                        );
                      },
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }
}
