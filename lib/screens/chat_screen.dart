import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chatbotapp/providers/chat_provider.dart';
import 'package:chatbotapp/utility/animated_dialog.dart';
import 'package:chatbotapp/widgets/bottom_chat_field.dart';
import 'package:chatbotapp/widgets/chat_messages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  static const Color primaryColor = Color.fromARGB(255, 174, 128, 72);
  static const Color secondaryColor = Color.fromARGB(255, 168, 93, 58);
  static const Color accentColor = Color.fromARGB(255, 198, 153, 99);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }

        chatProvider.addListener(() {
          if (chatProvider.inChatMessages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
         
          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0A0A0A),
                        const Color(0xFF1A1A1A),
                        const Color(0xFF2A2A2A),
                        const Color(0xFF0A0A0A),
                      ]
                    : [
                        const Color(0xFFF8F8F8),
                        const Color(0xFFE8E8E8),
                        const Color(0xFFD8D8D8),
                        const Color(0xFFF0F0F0),
                      ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, isDark, chatProvider),
                  const SizedBox(height: 10),
                  Expanded(
                    child: chatProvider.inChatMessages.isEmpty
                        ? _buildEmptyState(isDark)
                        : ChatMessages(
                            scrollController: _scrollController,
                            chatProvider: chatProvider,
                          ),
                  ),
                  BottomChatField(
                    chatProvider: chatProvider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color.fromRGBO(255, 255, 255, 0.1)
            : const Color.fromRGBO(0, 0, 0, 0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: isDark
                  ? [Colors.white, const Color(0xFFC0C0C0)]
                  : [primaryColor, secondaryColor],
            ).createShader(bounds),
            child: Text(
              'AI Assistant',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            'Online',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color.fromRGBO(255, 255, 255, 0.5)
                  : const Color.fromRGBO(0, 0, 0, 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton(bool isDark, ChatProvider chatProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [secondaryColor, accentColor]
              : [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color.fromRGBO(0, 0, 0, 0.4)
                : const Color.fromRGBO(0, 0, 0, 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        onPressed: () async {
          showMyAnimatedDialog(
            context: context,
            title: 'Start New Chat',
            content: 'Are you sure you want to start a new chat?',
            actionText: 'Yes',
            onActionPressed: (value) async {
              if (value) {
                await chatProvider.prepareChatRoom(
                  isNewChat: true,
                  chatID: '',
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Row(
          children: [
            _buildBackButton(isDark),
            const SizedBox(width: 12),
            _buildTitle(isDark),
            if (chatProvider.inChatMessages.isNotEmpty)
              _buildNewChatButton(isDark, chatProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [secondaryColor, accentColor]
                    : [primaryColor, secondaryColor],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color.fromRGBO(0, 0, 0, 0.4)
                      : const Color.fromRGBO(0, 0, 0, 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: isDark
                  ? [Colors.white, const Color(0xFFC0C0C0)]
                  : [primaryColor, secondaryColor],
            ).createShader(bounds),
            child: Text(
              'Start a conversation',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything!',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? const Color.fromRGBO(255, 255, 255, 0.6)
                  : const Color.fromRGBO(0, 0, 0, 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
