import 'package:avatar_brick/avatar_brick.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modified Message Bar from https://pub.dev/packages/chat_bubbles
///
/// following attributes can be modified
///
///
/// # BOOLEANS
/// [replying] is the additional reply widget top of the message bar
///
/// # STRINGS
/// [replyingTo] is the string to tag the replying message
/// [messageBarHintText] is the string to show as message bar hint
///
/// # WIDGETS
/// [actions] are the additional leading action buttons like camera
/// and file select
///
/// # COLORS
/// [replyWidgetColor] is the reply widget color
/// [replyIconColor] is the reply icon color on the left side of reply widget
/// [replyCloseColor] is the close icon color on the right side of the reply
/// widget
/// [messageBarColor] is the color of the message bar
/// [sendButtonColor] is the color of the send button
/// [messageBarHintStyle] is the style of the message bar hint
///
/// # METHODS
/// [onTextChanged] is the function which triggers after text every text change
/// [onSend] is the send button action
/// [onTapCloseReply] is the close button action of the close button on the
/// reply widget usually change [replying] attribute to `false`

class MessageBar extends StatelessWidget {
  /// [MessageBar] constructor
  ///
  ///
  MessageBar({
    required this.onSend,
    super.key,
    this.replying = false,
    this.replyingTo = '',
    this.actions = const [],
    this.replyWidgetColor = const Color(0xffF4F4F5),
    this.replyIconColor = Colors.blue,
    this.replyCloseColor = Colors.black12,
    this.messageBarColor = const Color(0xffF4F4F5),
    this.sendButtonColor = Colors.blue,
    this.isSendButtonBusy = false,
    this.messageBarHintText = 'Type your message here',
    this.messageBarHintStyle = const TextStyle(fontSize: 16),
    this.onTextChanged,
    this.onTapCloseReply,
    this.prefixIcon,
  });
  final bool replying;
  final String replyingTo;
  final List<Widget> actions;
  final TextEditingController _textController = TextEditingController();
  final Color replyWidgetColor;
  final Color replyIconColor;
  final Color replyCloseColor;
  final Color messageBarColor;
  final String messageBarHintText;
  final TextStyle messageBarHintStyle;
  final Color sendButtonColor;
  final bool isSendButtonBusy;
  final void Function(String)? onTextChanged;
  final void Function(String) onSend;
  final void Function()? onTapCloseReply;
  final Widget? prefixIcon;
  static final textFieldBorderRadius = BorderRadius.circular(30);

  /// [MessageBar] builder method
  ///
  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode(
      onKeyEvent: (focusNode, event) {
        if (event is KeyDownEvent) {
          if (HardwareKeyboard.instance.isShiftPressed &&
              event.logicalKey.keyLabel == 'Enter') {
            debugPrint('Shift + Enter');
            _textController.text = '${_textController.text}\n';
            return KeyEventResult.handled;
          } else if (event.logicalKey.keyLabel == 'Enter') {
            debugPrint('Enter');
            focusNode.unfocus();
            _send();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (replying)
            Container(
              color: replyWidgetColor,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    color: replyIconColor,
                    size: 24,
                  ),
                  Expanded(
                    child: Text(
                      'Re : $replyingTo',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: onTapCloseReply,
                    child: Icon(
                      Icons.close,
                      color: replyCloseColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(),
          if (replying)
            Container(
              height: 1,
              color: Colors.grey.shade300,
            )
          else
            Container(),
          Container(
            color: messageBarColor,
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...actions,
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: focusNode,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    onChanged: onTextChanged,
                    decoration: InputDecoration(
                      hintText: messageBarHintText,
                      hintMaxLines: 1,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      hintStyle: messageBarHintStyle,
                      fillColor: Theme.of(context).colorScheme.surface,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: textFieldBorderRadius,
                        borderSide: const BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: textFieldBorderRadius,
                        borderSide: const BorderSide(
                          color: Colors.black26,
                        ),
                      ),
                      prefixIcon: prefixIcon,
                      suffixIcon: isSendButtonBusy
                          ? const AvatarBrick(
                              isLoading: true,
                              size: Size(32, 32),
                              backgroundColor: Colors.transparent,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8),
                              child: IconButton(
                                padding: const EdgeInsets.all(5),
                                onPressed: _send,
                                icon: Icon(
                                  Icons.send,
                                  color: sendButtonColor,
                                  size: 24,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !isSendButtonBusy) {
      _textController.text = '';
      onSend(text);
    }
  }
}
