import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatbotapp/apis/api_service.dart';
import 'package:chatbotapp/constants/constants.dart';
import 'package:chatbotapp/hive/boxes.dart';
import 'package:chatbotapp/hive/chat_history.dart';
import 'package:chatbotapp/hive/settings.dart';
import 'package:chatbotapp/hive/user_model.dart';
import 'package:chatbotapp/models/message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  final List<Message> _inChatMessages = [];
  final PageController _pageController = PageController();
  List<XFile>? _imagesFileList = [];
  int _currentIndex = 0;
  String _currentChatId = '';
  String _modelType = 'nvidia/nemotron-3-nano-30b-a3b:free';
  bool _isLoading = false;

  List<Message> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile>? get imagesFileList => _imagesFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  String get modelType => _modelType;
  bool get isLoading => _isLoading;
  Future<void> setInChatMessages({required String chatId}) async {
    final messagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messagesFromDB) {
      if (_inChatMessages.contains(message)) {
        log('message already exists');
        continue;
      }
      _inChatMessages.add(message);
    }
    notifyListeners();
  }

  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      return Message.fromMap(Map<String, dynamic>.from(message));
    }).toList();
    
    notifyListeners();
    return newData;
  }

  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList = listValue;
    notifyListeners();
  }

  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> deleteChatMessages({required String chatId}) async {
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    }

    await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
    await Hive.box('${Constants.chatMessagesBox}$chatId').close();

    if (currentChatId.isNotEmpty && currentChatId == chatId) {
      setCurrentChatId(newChatId: '');
      _inChatMessages.clear();
      notifyListeners();
    }
  }

  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatID,
  }) async {
    _inChatMessages.clear();

    if (!isNewChat) {
      final chatHistory = await loadMessagesFromDB(chatId: chatID);
      _inChatMessages.addAll(chatHistory);
    }

    setCurrentChatId(newChatId: chatID);
  }

  Future<void> sentMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    setLoading(value: true);

    final chatId = getChatId();
    final history = await getHistory(chatId: chatId);
    final imagesUrls = getImagesUrls(isTextOnly: isTextOnly);
    final messagesBox = await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final userMessageId = messagesBox.keys.length;
    final assistantMessageId = messagesBox.keys.length + 1;

    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: imagesUrls,
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(userMessage);
    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
      messagesBox: messagesBox,
    );
  }

  http.Request _buildApiRequest({
    required String message,
    required List<Map<String, dynamic>> history,
  }) {
    final request = http.Request(
      'POST',
      Uri.parse('${ApiService.baseUrl}/chat/completions'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${ApiService.apiKey}',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://github.com/yourusername/chatbotapp',
      'X-Title': 'Flutter Chat Bot App',
    });

    final messages = [
      ...history,
      {'role': 'user', 'content': message}
    ];

    request.body = jsonEncode({
      'model': _modelType,
      'messages': messages,
      'stream': true,
    });

    return request;
  }

  void _handleStreamData(String line, Message assistantMessage) {
    if (!line.startsWith('data: ')) return;

    final data = line.substring(6);
    if (data == '[DONE]') return;

    try {
      final jsonData = jsonDecode(data);
      final content = jsonData['choices']?[0]?['delta']?['content'];

      if (content != null) {
        _inChatMessages
            .firstWhere((element) =>
                element.messageId == assistantMessage.messageId &&
                element.role.name == Role.assistant.name)
            .message
            .write(content);
        notifyListeners();
      }
    } catch (e) {
      log('Error parsing stream: $e');
    }
  }

  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Map<String, dynamic>> history,
    required Message userMessage,
    required String modelMessageId,
    required Box messagesBox,
  }) async {
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    _inChatMessages.add(assistantMessage);
    notifyListeners();

    try {
      final request = _buildApiRequest(message: message, history: history);
      final streamedResponse = await request.send();

      streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) => _handleStreamData(line, assistantMessage),
        onDone: () async {
          log('stream done');
          await saveMessagesToDB(
            chatID: chatId,
            userMessage: userMessage,
            assistantMessage: assistantMessage,
            messagesBox: messagesBox,
          );
          setLoading(value: false);
        },
        onError: (error) {
          log('error: $error');
          setLoading(value: false);
        },
      );
    } catch (e) {
      log('Error sending message: $e');
      setLoading(value: false);
    }
  }

  Future<void> saveMessagesToDB({
    required String chatID,
    required Message userMessage,
    required Message assistantMessage,
    required Box messagesBox,
  }) async {
    await messagesBox.add(userMessage.toMap());
    await messagesBox.add(assistantMessage.toMap());

    final chatHistoryBox = Boxes.getChatHistory();
    final chatHistory = ChatHistory(
      chatId: chatID,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      imagesUrls: userMessage.imagesUrls,
      timestamp: DateTime.now(),
    );
    
    await chatHistoryBox.put(chatID, chatHistory);
    await messagesBox.close();
  }

  List<String> getImagesUrls({required bool isTextOnly}) {
    if (isTextOnly || imagesFileList == null) return [];
    return imagesFileList!.map((image) => image.path).toList();
  }

  Future<List<Map<String, dynamic>>> getHistory({required String chatId}) async {
    if (currentChatId.isEmpty) return [];

    await setInChatMessages(chatId: chatId);
    return inChatMessages
        .map((message) => {
              'role': message.role == Role.user ? 'user' : 'assistant',
              'content': message.message.toString(),
            })
        .toList();
  }

  String getChatId() {
    return currentChatId.isEmpty ? const Uuid().v4() : currentChatId;
  }

  static Future<void> initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      await Hive.openBox<UserModel>(Constants.userBox);
    }
    
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
