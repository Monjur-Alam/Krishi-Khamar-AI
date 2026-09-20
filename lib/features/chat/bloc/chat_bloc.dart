import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/models.dart';
import '../../../data/services/openai_chat_service.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatEvent {
  const ChatStarted();
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class ChatSuggestionSelected extends ChatEvent {
  const ChatSuggestionSelected(this.text);
  final String text;
  @override
  List<Object?> get props => [text];
}

class ChatAttachmentAdded extends ChatEvent {
  const ChatAttachmentAdded(this.attachment);
  final ChatAttachment attachment;
  @override
  List<Object?> get props => [attachment.fileName, attachment.mimeType];
}

class ChatAttachmentCleared extends ChatEvent {
  const ChatAttachmentCleared();
}

class ChatListeningChanged extends ChatEvent {
  const ChatListeningChanged(this.isListening);
  final bool isListening;
  @override
  List<Object?> get props => [isListening];
}

class ChatVoiceTranscriptUpdated extends ChatEvent {
  const ChatVoiceTranscriptUpdated(this.transcript);
  final String transcript;
  @override
  List<Object?> get props => [transcript];
}

class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.suggestions = const [],
    this.isTyping = false,
    this.isListening = false,
    this.pendingAttachment,
    this.voiceDraft = '',
    this.error,
  });

  final List<ChatMessage> messages;
  final List<String> suggestions;
  final bool isTyping;
  final bool isListening;
  final ChatAttachment? pendingAttachment;
  final String voiceDraft;
  final String? error;

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<String>? suggestions,
    bool? isTyping,
    bool? isListening,
    ChatAttachment? pendingAttachment,
    bool clearAttachment = false,
    String? voiceDraft,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      suggestions: suggestions ?? this.suggestions,
      isTyping: isTyping ?? this.isTyping,
      isListening: isListening ?? this.isListening,
      pendingAttachment:
          clearAttachment ? null : (pendingAttachment ?? this.pendingAttachment),
      voiceDraft: voiceDraft ?? this.voiceDraft,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        messages,
        suggestions,
        isTyping,
        isListening,
        pendingAttachment,
        voiceDraft,
        error,
      ];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({OpenAiChatService? chatService})
      : _chatService = chatService ?? OpenAiChatService(),
        super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatMessageSent>(_onSend);
    on<ChatSuggestionSelected>((e, emit) => add(ChatMessageSent(e.text)));
    on<ChatAttachmentAdded>((e, emit) {
      emit(state.copyWith(pendingAttachment: e.attachment, clearError: true));
    });
    on<ChatAttachmentCleared>((e, emit) {
      emit(state.copyWith(clearAttachment: true));
    });
    on<ChatListeningChanged>((e, emit) {
      emit(state.copyWith(isListening: e.isListening));
    });
    on<ChatVoiceTranscriptUpdated>((e, emit) {
      emit(state.copyWith(voiceDraft: e.transcript));
    });
  }

  final OpenAiChatService _chatService;

  void _onStarted(ChatStarted event, Emitter<ChatState> emit) {
    emit(
      ChatState(
        messages: [
          ChatMessage(
            text:
                'Namaste! 🙏 I\'m KisanBot AI.\n\nAsk me about crops, pests, fertilizer, weather farming tips — or attach a crop photo / use the mic.',
            sender: MessageSender.bot,
            time: _nowLabel(),
          ),
        ],
        suggestions: List.of(DummyData.suggestedQuestions),
      ),
    );
  }

  Future<void> _onSend(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    final attachment = state.pendingAttachment;
    if (text.isEmpty && attachment == null) return;
    if (state.isTyping) return;

    final userMessage = ChatMessage(
      text: text.isEmpty
          ? (attachment?.isImage == true
              ? '📷 Crop photo attached'
              : '📎 ${attachment?.fileName ?? 'File'} attached')
          : text,
      sender: MessageSender.user,
      time: _nowLabel(),
      imageBytes: attachment?.isImage == true ? attachment!.bytes : null,
      attachmentName: attachment?.isImage == true ? null : attachment?.fileName,
    );

    final updated = [...state.messages, userMessage];
    emit(
      state.copyWith(
        messages: updated,
        isTyping: true,
        clearAttachment: true,
        voiceDraft: '',
        clearError: true,
        isListening: false,
      ),
    );

    try {
      final reply = await _chatService.send(
        history: updated.where((m) => m != userMessage).toList(),
        userText: text,
        attachment: attachment,
      );
      emit(
        state.copyWith(
          isTyping: false,
          messages: [
            ...updated,
            ChatMessage(
              text: reply,
              sender: MessageSender.bot,
              time: _nowLabel(),
            ),
          ],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isTyping: false,
          messages: [
            ...updated,
            ChatMessage(
              text:
                  'Sorry — I could not reach the AI right now.\n\n${e.toString().replaceFirst('Exception: ', '')}',
              sender: MessageSender.bot,
              time: _nowLabel(),
            ),
          ],
          error: e.toString(),
        ),
      );
    }
  }

  static String _nowLabel() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }
}
