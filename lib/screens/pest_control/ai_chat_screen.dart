import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';
import '../../utils/constants.dart';

/// AI Chat screen for pest control assistance
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _imagePicker = ImagePicker();
  late final dynamic _chatSession;

  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Start chat session
    _chatSession = _geminiService.startChat();
    // Add welcome message
    _messages.add(
      ChatMessage(
        text: 'Hello! How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    // Add user message
    final userMessage = ChatMessage(
      text: text.isEmpty ? 'Please analyze this image' : text,
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: _selectedImage?.path,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      String aiResponse;

      if (_selectedImage != null) {
        // Analyze image with optional text context
        aiResponse = await _geminiService.analyzeImage(_selectedImage!, text);
        setState(() {
          _selectedImage = null;
        });
      } else {
        // Send text message using chat session for context
        aiResponse = await _geminiService.sendChatMessage(_chatSession, text);
      }

      // Add AI response
      final aiMessage = ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(
          ChatMessage(
            text: 'Sorry, an error occurred: ${e.toString()}',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppColors.primaryGreen),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talk to AI'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    text: 'Chat cleared. How can I help you?',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('AI is thinking...'),
                ],
              ),
            ),

          // Selected image preview
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Image selected. Add description (optional) and send.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate),
                  color: AppColors.primaryGreen,
                  onPressed: _showImageSourceDialog,
                  tooltip: 'Upload image',
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: _selectedImage != null
                          ? 'Add description (optional)'
                          : 'Ask about pest control...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primaryGreen,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.white),
                    onPressed: _isLoading ? null : _handleSendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primaryGreen : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image if present
            if (message.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(message.imageUrl!),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Message text
            SelectableText(
              message.text,
              style: TextStyle(
                color: message.isUser ? AppColors.white : AppColors.black,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            // Timestamp
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? AppColors.white.withOpacity(0.7)
                    : AppColors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
