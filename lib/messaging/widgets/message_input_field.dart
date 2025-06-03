import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

class MessageInputField extends StatefulWidget{

  final TextEditingController messageFieldController;
  final Function sendMessage;
  final ScrollController scrollController;

  const MessageInputField({super.key, required this.messageFieldController, required this.sendMessage, required this.scrollController});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  bool _emojiShowing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade700,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(width: 5,),
                IconButton(
                 icon: Icon(Icons.emoji_emotions_outlined, color: Colors.white,size: 27,),
                  onPressed: () {
                    setState(() {
                      _emojiShowing = !_emojiShowing;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    maxLines: null,
                    controller: widget.messageFieldController,
                    cursorColor: Colors.grey.shade400,
                    decoration:  InputDecoration(
                      fillColor: Colors.grey.shade800,
                      filled: true,
                      hintText: "Yaz bişiler",
                      hintStyle: TextStyle(color: Colors.grey),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),borderSide: BorderSide.none)

                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (widget.messageFieldController.text.trim().isNotEmpty) {
                      await widget.sendMessage(widget.messageFieldController.text);
                      widget.messageFieldController.clear();
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 30),
                ),
              ],
            ),
            Offstage(
              offstage: !_emojiShowing,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EmojiPicker(
                  textEditingController: widget.messageFieldController,
                  scrollController: widget.scrollController,
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    viewOrderConfig: const ViewOrderConfig(),
                    emojiViewConfig: EmojiViewConfig(
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 28 *
                          (foundation.defaultTargetPlatform ==
                              TargetPlatform.iOS
                              ? 1.2
                              : 1.0),
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(),
                    bottomActionBarConfig: const BottomActionBarConfig(),
                    searchViewConfig: const SearchViewConfig(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}