// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:chat/src/app/app.locator.dart';
import 'package:chat/src/ui/views/chat/chat_viewmodel.dart';
import 'package:chat/src/ui/widgets/message_bar.dart';
import 'package:chat/src/ui/widgets/message_widget.dart';
import 'package:chat/src/ui/widgets/prompt_panel.dart';
import 'package:document/document.dart';

import 'package:flutter/material.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class ChatView extends StackedView<ChatViewModel> {
  ChatView({
    required this.showEmbeddingDialogFunction,
    required this.showNewChatDialogFunction,
    this.tablePrefix = 'main',
    this.leftWidgetTabController,
    super.key,
  });
  final String tablePrefix;
  final _scrollController = ScrollController();
  final _analyticsFacade = locator<AnalyticsFacade>();
  final TabController? leftWidgetTabController;
  final Future<void> Function(Embedding embedding) showEmbeddingDialogFunction;
  final Future<bool> Function() showNewChatDialogFunction;

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    final isSmallScreen = MediaQuery.sizeOf(context).width < 600;
    final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
    return Column(
      children: [
        Flexible(
          child: Align(
            alignment: Alignment.topCenter,
            child: InfiniteList(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              scrollController: _scrollController,
              itemCount: viewModel.messages.length,
              centerEmpty: true,
              emptyBuilder: (context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (const String.fromEnvironment(promptsKey).isNotEmpty)
                      PromptPanel(
                        (text) {
                          unawaited(
                            _analyticsFacade.trackChatStartedFromPrompt(text),
                          );
                          _onSend(viewModel, text);
                        },
                      ),
                  ],
                );
              },
              isLoading: viewModel.isBusy,
              onFetchData: viewModel.fetchMessages,
              reverse: true,
              shrinkWrap: true,
              hasReachedMax: viewModel.hasReachedMax,
              itemBuilder: (context, index) {
                return MessageWidget(
                  viewModel.messages[index],
                  showEmbeddingDialogFunction,
                );
              },
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            EdgeInsetsGeometry buttonMargin;
            EdgeInsetsGeometry buttonPadding;
            double buttonIconSize;
            if (constraints.maxWidth < 600) {
              buttonMargin = const EdgeInsets.all(4);
              buttonPadding = const EdgeInsets.all(2);
              buttonIconSize = 20;
            } else {
              buttonMargin = const EdgeInsets.all(8);
              buttonPadding = const EdgeInsets.all(4);
              buttonIconSize = 24;
            }
            
            return MessageBar(
              messageBarHintText: 'Message $appTitle',
              isSendButtonBusy: viewModel.isGenerating,
              sendButtonColor: Theme.of(context).colorScheme.primary,
              sendButtonMargin: buttonMargin,
              sendButtonPadding: buttonPadding,
              sendButtonIconSize: buttonIconSize,
              onSend: (text) async {
                unawaited(
                  _analyticsFacade.trackChatStarted(),
                );
                await _onSend(viewModel, text);
              },
              onStop: viewModel.isStreaming ? viewModel.stop : null,
              prefixIcon: Padding(
                padding: buttonMargin,
                child: IconButton(
                  padding: buttonPadding,
                  onPressed: isDisabledNewChatButton(viewModel)
                      ? null
                      : () async => _newChat(viewModel),
                  icon: Icon(
                    Icons.add,
                    color: isDisabledNewChatButton(viewModel)
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    size: buttonIconSize,
                  ),
                ),
              ),
              messageBarColor: Colors.transparent,
            );
          },
        ),
      ],
    );
  }

  bool isDisabledNewChatButton(ChatViewModel viewModel) {
    final disabledNewChatButton =
        viewModel.isGenerating && !viewModel.isStreaming;
    return disabledNewChatButton;
  }

  @override
  ChatViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatViewModel(tablePrefix);

  @override
  void onDispose(ChatViewModel viewModel) {
    _scrollController.dispose();
  }

  Future<void> _onSend(ChatViewModel viewModel, String text) async {
    leftWidgetTabController?.animateTo(1);
    _scrollToBottom();
    await viewModel.addMessage(viewModel.userId, text);
  }

  Future<void> _newChat(ChatViewModel viewModel) async {
    if (viewModel.isGenerating && viewModel.isStreaming) {
      if (await showNewChatDialogFunction()) {
        await viewModel.stop();
        viewModel.newChat();
      }
    } else {
      viewModel.newChat();
    }
  }

  void _scrollToBottom() {
    // Autoscroll to the top after message sent
    // (top is bottom when reverse=True in the infinite list)
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
  }
}
