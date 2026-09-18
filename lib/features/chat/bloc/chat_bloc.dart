import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/dummy/dummy_data.dart';
import '../../../data/models/models.dart';

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

class ChatState extends Equatable {
  const ChatState({
    this.messages = const [],
    this.suggestions = const [],
    this.isTyping = false,
  });

  final List<ChatMessage> messages;
  final List<String> suggestions;
  final bool isTyping;

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<String>? suggestions,
    bool? isTyping,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      suggestions: suggestions ?? this.suggestions,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => [messages, suggestions, isTyping];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<ChatStarted>((event, emit) {
      emit(
        ChatState(
          messages: List.of(DummyData.chatHistory),
          suggestions: List.of(DummyData.suggestedQuestions),
        ),
      );
    });
    on<ChatMessageSent>(_onSend);
    on<ChatSuggestionSelected>((e, emit) => add(ChatMessageSent(e.text)));
  }

  Future<void> _onSend(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    final updated = [
      ...state.messages,
      ChatMessage(text: text, sender: MessageSender.user, time: 'Now'),
    ];
    emit(state.copyWith(messages: updated, isTyping: true));

    await Future<void>.delayed(const Duration(milliseconds: 900));

    emit(
      state.copyWith(
        isTyping: false,
        messages: [
          ...updated,
          const ChatMessage(
            text:
                'Thanks for your question! Based on local conditions, I recommend checking soil moisture and applying a balanced NPK fertilizer this week. Need more details?',
            sender: MessageSender.bot,
            time: 'Now',
          ),
        ],
      ),
    );
  }
}
