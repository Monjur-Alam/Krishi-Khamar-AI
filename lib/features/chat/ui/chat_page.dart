import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../../data/services/openai_chat_service.dart';
import '../bloc/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  final _speech = stt.SpeechToText();
  bool _speechReady = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            context.read<ChatBloc>().add(const ChatListeningChanged(false));
          }
        }
      },
      onError: (_) {
        if (mounted) {
          context.read<ChatBloc>().add(const ChatListeningChanged(false));
        }
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _speech.stop();
    super.dispose();
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send([String? text]) {
    final value = text ?? _controller.text;
    final hasAttachment =
        context.read<ChatBloc>().state.pendingAttachment != null;
    if (value.trim().isEmpty && !hasAttachment) return;
    context.read<ChatBloc>().add(ChatMessageSent(value));
    _controller.clear();
    _scrollToEnd();
  }

  Future<void> _toggleVoice() async {
    final bloc = context.read<ChatBloc>();
    if (!_speechReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone / speech not available')),
      );
      return;
    }

    if (bloc.state.isListening) {
      await _speech.stop();
      bloc.add(const ChatListeningChanged(false));
      final draft = bloc.state.voiceDraft.trim();
      if (draft.isNotEmpty) {
        _controller.text = draft;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
      return;
    }

    bloc.add(const ChatListeningChanged(true));
    await _speech.listen(
      onResult: (result) {
        bloc.add(ChatVoiceTranscriptUpdated(result.recognizedWords));
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        if (result.finalResult) {
          bloc.add(const ChatListeningChanged(false));
        }
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'en_IN',
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      ),
    );
  }

  Future<void> _showAttachSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file, color: AppColors.primary),
                title: const Text('Attach file'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final mime = _mimeFromPath(file.path) ?? 'image/jpeg';
      if (!mounted) return;
      context.read<ChatBloc>().add(
            ChatAttachmentAdded(
              ChatAttachment(
                bytes: bytes,
                fileName: p.basename(file.path),
                mimeType: mime,
              ),
            ),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'txt', 'pdf', 'csv'],
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final name = file.name;
      final mime = _mimeFromPath(name) ?? 'application/octet-stream';
      if (!mounted) return;
      context.read<ChatBloc>().add(
            ChatAttachmentAdded(
              ChatAttachment(
                bytes: bytes,
                fileName: name,
                mimeType: mime,
              ),
            ),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick file: $e')),
      );
    }
  }

  String? _mimeFromPath(String path) {
    final ext = p.extension(path).toLowerCase();
    return switch (ext) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.gif' => 'image/gif',
      '.txt' => 'text/plain',
      '.csv' => 'text/csv',
      '.pdf' => 'application/pdf',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (p, c) => p.messages.length != c.messages.length || p.isTyping != c.isTyping,
      listener: (_, _) => _scrollToEnd(),
      child: Column(
        children: [
          const _ChatHeader(),
          Expanded(
            child: Container(
              color: AppColors.mintSoft,
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                    itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (state.isTyping && index == state.messages.length) {
                        return const _TypingBubble();
                      }
                      return _MessageBubble(message: state.messages[index]);
                    },
                  );
                },
              ),
            ),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: state.suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final q = state.suggestions[i];
                    return ActionChip(
                      label: Text(q),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.accent),
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onPressed: state.isTyping ? null : () => _send(q),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final pending = state.pendingAttachment;
              return Column(
                children: [
                  if (pending != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            if (pending.isImage)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  Uint8List.fromList(pending.bytes),
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(Icons.insert_drive_file,
                                  color: AppColors.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                pending.fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              onPressed: () => context
                                  .read<ChatBloc>()
                                  .add(const ChatAttachmentCleared()),
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (state.isListening)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Listening… tap mic to stop',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: state.isTyping ? null : _showAttachSheet,
                          borderRadius: BorderRadius.circular(21),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: AppColors.mint,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.attach_file,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !state.isTyping,
                            decoration: InputDecoration(
                              hintText: state.isListening
                                  ? 'Speak now…'
                                  : 'Ask about your farm...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: IconButton(
                                onPressed: state.isTyping ? null : _toggleVoice,
                                icon: Icon(
                                  state.isListening ? Icons.mic : Icons.mic_none,
                                  color: state.isListening
                                      ? Colors.red
                                      : AppColors.primary,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onSubmitted: state.isTyping ? null : _send,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: state.isTyping ? null : _send,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: state.isTyping
                                  ? Colors.grey
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 12, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KisanBot AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFF69F0AE)),
                        SizedBox(width: 6),
                        Text(
                          'Online • Powered by OpenAI',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isBot ? Colors.white : AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            Uint8List.fromList(message.imageBytes!),
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (message.attachmentName != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              size: 16,
                              color: isBot ? AppColors.primary : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                message.attachmentName!,
                                style: TextStyle(
                                  color: isBot
                                      ? AppColors.textPrimary
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      if (isBot)
                        MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                              color: AppColors.textPrimary,
                              height: 1.45,
                              fontSize: 14,
                              fontFamily: 'Nunito',
                            ),
                            strong: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              fontFamily: 'Nunito',
                            ),
                            em: const TextStyle(
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              fontFamily: 'Nunito',
                            ),
                            listBullet: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            listIndent: 20,
                            h1: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              fontFamily: 'Nunito',
                            ),
                            h2: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              fontFamily: 'Nunito',
                            ),
                            h3: const TextStyle(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              fontFamily: 'Nunito',
                            ),
                            code: TextStyle(
                              backgroundColor: AppColors.mint,
                              color: AppColors.primaryDark,
                              fontSize: 13,
                              fontFamily: 'Nunito',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: AppColors.mintSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            blockquote: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                            blockquoteDecoration: const BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppColors.primary,
                                  width: 3,
                                ),
                              ),
                            ),
                            a: const TextStyle(
                              color: AppColors.weatherBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      else
                        Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.4,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 38, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
