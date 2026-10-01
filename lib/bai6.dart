import 'package:flutter/material.dart';

void main() => runApp(const MusicPlayerApp());

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2C1338), // Màu nền tím sẫm
      ),
      home: const MusicScreen(),
    );
  }
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  // Biến để chuyển đổi giữa màn hình Now Playing (0) và Playlist (1)
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentIndex == 0 ? _buildNowPlaying() : _buildPlaylist(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'Now Playing'),
          BottomNavigationBarItem(icon: Icon(Icons.queue_music), label: 'Playlist'),
        ],
      ),
    );
  }

  // Màn hình 1: Now Playing
  Widget _buildNowPlaying() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("ALBUM", style: TextStyle(letterSpacing: 2, color: Colors.grey)),
        const SizedBox(height: 30),
        // Đĩa than / Ảnh cover
        Container(
          height: 250,
          width: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade800, width: 10),
          ),
          child: const Center(
            child: Icon(Icons.music_note, size: 80, color: Colors.black26),
          ),
        ),
        const SizedBox(height: 30),
        const Text("SONG TITLE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text("ARTIST", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
        // Thanh tiến trình
        Slider(value: 0.3, onChanged: (val) {}),
        // Các nút điều khiển
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.shuffle), onPressed: () {}),
            IconButton(icon: const Icon(Icons.skip_previous, size: 36), onPressed: () {}),
            IconButton(icon: const Icon(Icons.play_circle_fill, size: 64, color: Colors.pinkAccent), onPressed: () {}),
            IconButton(icon: const Icon(Icons.skip_next, size: 36), onPressed: () {}),
            IconButton(icon: const Icon(Icons.repeat), onPressed: () {}),
          ],
        )
      ],
    );
  }

  // Màn hình 2: Playlist
  Widget _buildPlaylist() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("SONG TITLE\nARTIST", textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text("${index + 1}."),
                title: const Text("Title"),
                subtitle: const Text("Artist"),
                trailing: const Text("3:00"),
                onTap: () {}, // Xử lý khi chọn bài
              );
            },
          ),
        ),
      ],
    );
  }
}