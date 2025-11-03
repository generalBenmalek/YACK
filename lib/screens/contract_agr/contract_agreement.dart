import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/contract/message.dart';

class ContractAgreement extends StatefulWidget {
  const ContractAgreement({super.key});
  @override
  State<ContractAgreement> createState() => _ContractAgreementState();
}

String contract_name = 'E-Commerce Mobile App';
int price = 5000;
String dets = 'Development of a cross-platform e-commerce mobile application with user authentication, payment integration, product catalog, and order tracking features. Includes 60 days of maintenance support.';
String user = 'Tech Solutions Inc.';

class _ContractAgreementState extends State<ContractAgreement> {

  final TextEditingController _controllerinp = TextEditingController();
  final List<Message> _messages = [
    Message('Hi there!', 'yacine', true, false, null),
    Message('Hello! I wanted to discuss the contract details', 'yacine', false, false, null),
    Message('Sure, what would you like to know?', 'yacine', true, false, null),
  ];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Contract Agreement',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colors.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: _showContractDetails,
            icon: Icon(Icons.info_outline, size: 25, color: colors.primary),
          )
        ],
      ),
      body: Column(
        children: [
          // Buttons Container
          Container(
            color: colors.surface,
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton('Dispute', Icons.gavel, colors.onError, colors.errorContainer),
                SizedBox(width: 20),
                _buildActionButton('Accept', Icons.check_circle, colors.onPrimary, colors.primaryContainer),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 8),
              child: Column(
                children: _messages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final message = entry.value;
                  return messageWidget(
                      message.text,
                      message.sender,
                      message.me,
                      message.isFile,
                      message.file,
                      index
                  );
                }).toList(),
              ),
            ),
          ),

          // Improved Chat Input Bar
          _buildChatInputBar(),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: Icon(icon, color: color, size: 20),
          label: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatInputBar() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom:12, // MediaQuery.of(context).padding.bottom + 8,
        top: 12,
      ),
      child: Row(
        children: [
          // Attachment Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
            ),
            child: IconButton(
              onPressed: _showAttachmentOptions,
              icon: Icon(Icons.attach_file, color: colors.onSurface, size: 22),
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(),
            ),
          ),
          SizedBox(width: 8),

          // Message Input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllerinp,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(color: colors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),

          // Send Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(Icons.send, color: colors.onPrimary, size: 20),
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controllerinp.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(Message(
            _controllerinp.text.trim(),
            'yacine',
            true,
            false,
            null
        ));
      });
      _controllerinp.clear();
    }
  }

  void _showAttachmentOptions() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose File Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(Icons.photo_camera, 'Camera', _pickImageFromCamera),
                  _buildAttachmentOption(Icons.photo, 'Gallery', _pickImageFromGallery),
                  _buildAttachmentOption(Icons.videocam, 'Video', _pickVideo),
                  _buildAttachmentOption(Icons.insert_drive_file, 'Document', _pickDocument),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Function() onTap) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: colors.onPrimary, size: 24),
            padding: EdgeInsets.all(12),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _addFileMessage(File(image.path), FileType.image);
    }
  }

  Future<void> _pickImageFromGallery() async {
    Navigator.pop(context);
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _addFileMessage(File(image.path), FileType.image);
    }
  }

  Future<void> _pickVideo() async {
    Navigator.pop(context);
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _addFileMessage(File(video.path), FileType.video);
    }
  }

  Future<void> _pickDocument() async {
    Navigator.pop(context);

    _addFileMessage(null, FileType.document);
  }

  void _addFileMessage(File? file, FileType fileType) {
    String fileName = _generateFileName(fileType);

    setState(() {
      _messages.add(Message(
          fileName,
          'yacine',
          true,
          true,
          FileData(fileName, fileType, file: file)
      ));
    });
  }

  String _generateFileName(FileType fileType) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    switch (fileType) {
      case FileType.image:
        return 'image_$timestamp.jpg';
      case FileType.video:
        return 'video_$timestamp.mp4';
      case FileType.document:
        return 'document_$timestamp.pdf';
    }
  }

  void _showContractDetails() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: colors.surface,
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.assignment, color: colors.onPrimary, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contract Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Active • ${DateTime.now().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: colors.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildDetailRow('Contract Name', contract_name, Icons.badge),
                _buildDetailRow('Price', '\$$price', Icons.attach_money),
                _buildDetailRow('Client', 'Yacine', Icons.person),
                SizedBox(height: 20),
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  dets,
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaPreview(String fileName, FileType fileType, File? file, int index) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: colors.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _buildMediaPreview(fileType, fileName, file),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'File Type: ${_getFileTypeText(fileType)}',
                    style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaPreview(FileType fileType, String fileName, File? file) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    switch (fileType) {
      case FileType.image:
        return file != null
            ? Image.file(file, fit: BoxFit.cover)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 80, color: colors.primary),
            SizedBox(height: 16),
            Text('Image: $fileName', style: TextStyle(fontSize: 16, color: colors.onSurface)),
          ],
        );
      case FileType.video:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 80, color: colors.primary),
            SizedBox(height: 16),
            Text('Video: $fileName', style: TextStyle(fontSize: 16, color: colors.onSurface)),
            SizedBox(height: 8),
            Icon(Icons.play_circle_fill, size: 40, color: colors.primary),
          ],
        );
      case FileType.document:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, size: 80, color: colors.primary),
            SizedBox(height: 16),
            Text('Document: $fileName', style: TextStyle(fontSize: 16, color: colors.onSurface)),
            SizedBox(height: 8),
            Text('PDF File', style: TextStyle(color: colors.onSurface.withOpacity(0.6))),
          ],
        );
    }
  }

  String _getFileTypeText(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return 'Image';
      case FileType.video:
        return 'Video';
      case FileType.document:
        return 'Document';
    }
  }

  Widget messageWidget(String text, String sender, bool me, bool isFile, FileData? file, int index) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: isFile && file != null ? () => _showMediaPreview(file.name, file.type, file.file, index) : null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!me) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: colors.surface,
                child: Text(
                  sender.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 12, color: colors.onSurface),
                ),
              ),
              SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: me ? Radius.circular(16) : Radius.circular(4),
                    bottomRight: me ? Radius.circular(4) : Radius.circular(16),
                  ),
                  color: me ? colors.primary : colors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!me)
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          sender,
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (isFile && file != null) ...[
                      Row(
                        children: [
                          Icon(
                            _getFileIcon(file.type),
                            color: me ? colors.onPrimary : colors.primary,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              file.name,
                              style: TextStyle(
                                color: me ? colors.onPrimary : colors.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (file.type == FileType.image || file.type == FileType.video)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(me ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              file.type == FileType.image ? Icons.image : Icons.videocam,
                              size: 40,
                              color: me ? colors.onPrimary : colors.primary,
                            ),
                          ),
                        ),
                    ] else
                      Text(
                        text,
                        style: TextStyle(
                          color: me ? colors.onPrimary : colors.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    SizedBox(height: 4),
                    Text(
                      '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: me ? colors.onPrimary.withOpacity(0.7) : colors.onSurface.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (me) ...[
              SizedBox(width: 8),
              CircleAvatar(
                radius: 14,
                backgroundColor: colors.primary,
                child: Text(
                  'Me',
                  style: TextStyle(fontSize: 10, color: colors.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(FileType fileType) {
    switch (fileType) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.videocam;
      case FileType.document:
        return Icons.insert_drive_file;
    }
  }
}


