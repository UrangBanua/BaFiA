import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';
import '../services/bafia_ai_service.dart';
import '../services/logger_service.dart';

class ChatAiPage extends StatefulWidget {
  const ChatAiPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatAiPageState createState() => _ChatAiPageState();
}

class _ChatAiPageState extends State<ChatAiPage> {
  final List<Map<String, String>> _messages = [];
  final List<Map<String, String>> _chatHistory = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late BafiaAiService _geminiAiService;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final String? apiKeyGemini = ApiService.apiKeyGemini;
    _geminiAiService = BafiaAiService(apiKeyGemini!);
    _playNotificationSound();
  }

  void _playNotificationSound() async {
    // set volume to 50%
    await _audioPlayer.setVolume(0.5);
    await _audioPlayer.play(AssetSource('sounds/notif-bafia.mp3'));
    LoggerService.logger.i('Play Sound, From BaFia...');

    // tampilkan info
    var duration = await _audioPlayer.getDuration();
    LoggerService.logger.i('Sound Duration: $duration');

    // Tambahkan pesan selamat datang
    _welcomeMessage(
        "Halo, saya BaFiA, asisten virtual Anda. Ada yang bisa saya bantu?");
  }

  void _welcomeMessage(String messageText) {
    var personalText =
        'kamu adalah asisten pribadi saya yang sangat berpengalaman dalam bidang keuangan pemerintah daerah dan efektif dalam mencarian solusi maupun informasi terkait probis/alur/tata cara dalam bidang penganggaran, penatausahaan dan akuntansi sesuai dengan pedoman dari PMDN No 77 tahun 2020';
    setState(() {
      _messages.add({
        "sender": "Bafia",
        "text": messageText,
      });
    });
    _chatHistory.add({"sender": "Saya", "text": personalText});
    _scrollToBottom(messageText);
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "Saya", "text": _controller.text});
        _chatHistory.add({"sender": "Saya", "text": _controller.text});
      });
      _getAiResponse(_controller.text);
      _controller.clear();
      _scrollToBottom(_controller.text);
    }
  }

  void _getAiResponse(String message) async {
    setState(() {
      _messages.add({"sender": "Bafia", "text": "sedang mengetik..."});
    });
    _scrollToBottom("sedang mengetik...");

    try {
      final response = await _geminiAiService
          .getAiResponse(_chatHistory.map((msg) => msg["text"]!).join("\n"));
      setState(() {
        _messages.removeLast();
        _messages.add({"sender": "Bafia", "text": response});
        _chatHistory.add({"sender": "Bafia", "text": response});
      });
      _scrollToBottom(response);
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({"sender": "Bafia", "text": "Error getting response"});
      });
      _scrollToBottom("Error getting response");
    }
  }

  void _scrollToBottom(String response) {
    final int responseLength = response.length;
    final int duration =
        (responseLength / 3) // Kurangi nilai pembagi untuk memperlambat durasi
            .clamp(2000, 10000) // Tingkatkan batas durasi maksimum
            .toInt(); // Durasi antara 2000ms dan 10000ms

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: duration),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _expandChat() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _closeChat() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: _isExpanded ? MediaQuery.of(context).size.width * 0.8 : 300,
          height: _isExpanded ? MediaQuery.of(context).size.height * 0.8 : 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: _expandChat,
                    ),
                    const Text(
                      'Tanya BaFiA',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _closeChat,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message["sender"] == "Saya";
                      return MarkdownBody(
                        data: "${message["sender"]}: ${message["text"]}",
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 11,
                            color: isUser ? Colors.greenAccent : Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'BaFiA Gen. AI Model',
                    style: TextStyle(fontSize: 8, color: Colors.white38),
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
