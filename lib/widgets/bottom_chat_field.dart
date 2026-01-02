import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/utility/animated_dialog.dart';
import 'package:chatbotapp/widgets/preview_images_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final TextEditingController textController = TextEditingController();
  final FocusNode textFieldFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  static const Color primaryColor = Color.fromARGB(255, 174, 128, 72);
  static const Color secondaryColor = Color.fromARGB(255, 168, 93, 58);
  static const Color accentColor = Color.fromARGB(255, 198, 153, 99);

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sentMessage(
        message: message,
        isTextOnly: isTextOnly,
      );
    } catch (e) {
      log('error : $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  void pickImage() async {
    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }

  BoxDecoration _buildButtonDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [secondaryColor, accentColor]
            : [primaryColor, secondaryColor],
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? const Color.fromRGBO(0, 0, 0, 0.4)
              : const Color.fromRGBO(0, 0, 0, 0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildImagePickerButton(bool isDark, bool hasImages) {
    return Container(
      decoration: _buildButtonDecoration(isDark),
      child: IconButton(
        onPressed: () {
          if (hasImages) {
            showMyAnimatedDialog(
              context: context,
              title: 'Delete Images',
              content: 'Are you sure you want to delete the images?',
              actionText: 'Delete',
              onActionPressed: (value) {
                if (value) {
                  widget.chatProvider.setImagesFileList(listValue: []);
                }
              },
            );
          } else {
            pickImage();
          }
        },
        icon: Icon(
          hasImages ? CupertinoIcons.delete : CupertinoIcons.photo,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField(bool isDark, bool hasImages) {
    return Expanded(
      child: TextField(
        focusNode: textFieldFocus,
        controller: textController,
        textInputAction: TextInputAction.send,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onSubmitted: widget.chatProvider.isLoading
            ? null
            : (String value) {
                if (value.isNotEmpty) {
                  sendChatMessage(
                    message: textController.text,
                    chatProvider: widget.chatProvider,
                    isTextOnly: !hasImages,
                  );
                }
              },
        decoration: InputDecoration.collapsed(
          hintText: 'Type your message...',
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: isDark
                ? const Color.fromRGBO(255, 255, 255, 0.5)
                : const Color.fromRGBO(0, 0, 0, 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(bool isDark, bool hasImages) {
    return GestureDetector(
      onTap: widget.chatProvider.isLoading
          ? null
          : () {
              if (textController.text.isNotEmpty) {
                sendChatMessage(
                  message: textController.text,
                  chatProvider: widget.chatProvider,
                  isTextOnly: !hasImages,
                );
              }
            },
      child: Container(
        decoration: _buildButtonDecoration(isDark),
        padding: const EdgeInsets.all(12.0),
        child: const Icon(
          Icons.arrow_upward_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color.fromRGBO(255, 255, 255, 0.08),
                        const Color.fromRGBO(255, 255, 255, 0.04),
                      ]
                    : [
                        const Color.fromRGBO(255, 255, 255, 0.9),
                        const Color.fromRGBO(255, 255, 255, 0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color.fromRGBO(255, 255, 255, 0.15)
                    : const Color.fromRGBO(0, 0, 0, 0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color.fromRGBO(0, 0, 0, 0.3)
                      : const Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                if (hasImages) const PreviewImagesWidget(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      _buildImagePickerButton(isDark, hasImages),
                      const SizedBox(width: 12),
                      _buildTextField(isDark, hasImages),
                      _buildSendButton(isDark, hasImages),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
