import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

// 1. Hàm main() bắt buộc phải có để chạy app
void main() {
  runApp(const MyApp());
}

// 2. Widget gốc cấu hình ứng dụng
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Ẩn chữ debug góc phải
      title: 'SMS Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SmsAnalyzerScreen(), // Chạy vào màn hình phân tích SMS
    );
  }
}

// 3. Màn hình chính phân tích SMS
class SmsAnalyzerScreen extends StatefulWidget {
  const SmsAnalyzerScreen({Key? key}) : super(key: key);

  @override
  _SmsAnalyzerScreenState createState() => _SmsAnalyzerScreenState();
}

class _SmsAnalyzerScreenState extends State<SmsAnalyzerScreen> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];

  // Biến phục vụ chức năng tìm kiếm theo số điện thoại
  String _searchPhone = "";
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSMS();
  }

  // Hàm xin quyền và đọc toàn bộ tin nhắn
  Future<void> _fetchSMS() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(kinds: [SmsQueryKind.inbox]);
      setState(() {
        _messages = messages;
      });
    } else {
      await Permission.sms.request();
      _fetchSMS(); // Gọi lại sau khi xin quyền
    }
  }

  // Hàm trích xuất 6 số OTP
  String _extractOTP(String body) {
    // Regex tìm chữ [OTP] sau đó tìm 6 chữ số liên tiếp
    RegExp regExp = RegExp(r'\[OTP\].*?(\d{6})');
    Match? match = regExp.firstMatch(body);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return "Không tìm thấy mã 6 số";
  }

  // Hàm Thống kê tin nhắn theo ngày/tháng
  Map<String, int> getStatsByDate() {
    Map<String, int> stats = {};
    for (var msg in _messages) {
      if (msg.date != null) {
        // Format ngày tháng cơ bản: DD/MM/YYYY
        String dateStr = "${msg.date!.day}/${msg.date!.month}/${msg.date!.year}";
        stats[dateStr] = (stats[dateStr] ?? 0) + 1;
      }
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 Tab tương ứng 4 chức năng
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SMS Analyzer'),
          backgroundColor: Colors.teal,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchSMS,
              tooltip: 'Tải lại tin nhắn',
            )
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.analytics), text: "Thống kê"),
              Tab(icon: Icon(Icons.phone_android), text: "Tìm số ĐT"),
              Tab(icon: Icon(Icons.campaign), text: "Quảng cáo"),
              Tab(icon: Icon(Icons.password), text: "OTP"),
            ],
          ),
        ),
        body: _messages.isEmpty
            ? const Center(child: Text("Đang tải tin nhắn hoặc hộp thư trống..."))
            : TabBarView(
          children: [
            _buildStatsTab(),
            _buildSearchPhoneTab(),
            _buildAdsTab(),
            _buildOTPTab(),
          ],
        ),
      ),
    );
  }

  // ================= CÁC GIAO DIỆN TAB =================

  // Tab 1: Thống kê (Tổng số & Theo ngày/tháng)
  Widget _buildStatsTab() {
    Map<String, int> stats = getStatsByDate();
    List<String> dates = stats.keys.toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.teal.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng số tin nhắn:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${_messages.length}", style: const TextStyle(fontSize: 22, color: Colors.teal, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("THỐNG KÊ THEO NGÀY/THÁNG", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              String date = dates[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: Text("Ngày: $date"),
                  trailing: Text("${stats[date]} tin", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tab 2: Danh sách tin nhắn từ 1 số cụ thể
  Widget _buildSearchPhoneTab() {
    List<SmsMessage> filteredMsgs = _messages.where((msg) => msg.address != null && msg.address!.contains(_searchPhone)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: "Nhập số điện thoại cần lọc...",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _searchPhone = _phoneController.text.trim();
                  });
                },
              ),
            ),
            onSubmitted: (value) {
              setState(() {
                _searchPhone = value.trim();
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredMsgs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredMsgs[index].address ?? "Không xác định"),
                subtitle: Text(filteredMsgs[index].body ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
              );
            },
          ),
        ),
      ],
    );
  }

  // Tab 3: Lọc tin nhắn Quảng Cáo ([QC])
  Widget _buildAdsTab() {
    // Lọc tin nhắn có bắt đầu bằng [QC]
    List<SmsMessage> adsMsgs = _messages.where((msg) => (msg.body ?? "").trimLeft().startsWith('[QC]')).toList();

    return ListView.builder(
      itemCount: adsMsgs.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.yellow.shade50,
          child: ListTile(
            leading: const Icon(Icons.campaign, color: Colors.orange),
            title: Text(adsMsgs[index].address ?? ""),
            subtitle: Text(adsMsgs[index].body ?? ""),
          ),
        );
      },
    );
  }

  // Tab 4: Lọc tin nhắn OTP và xử lý click
  Widget _buildOTPTab() {
    // Lọc tin nhắn chứa chuỗi [OTP]
    List<SmsMessage> otpMsgs = _messages.where((msg) => (msg.body ?? "").contains('[OTP]')).toList();

    return ListView.builder(
      itemCount: otpMsgs.length,
      itemBuilder: (context, index) {
        SmsMessage msg = otpMsgs[index];
        return Card(
          color: Colors.blue.shade50,
          child: ListTile(
            leading: const Icon(Icons.security, color: Colors.blue),
            title: Text(msg.address ?? ""),
            subtitle: Text(msg.body ?? ""),
            trailing: const Icon(Icons.touch_app),
            onTap: () {
              // Yêu cầu: "khi được chọn thì xử lý lấy chuỗi 6 ký số của OTP và hiển thị"
              String otpCode = _extractOTP(msg.body ?? "");
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: const Text("Mã OTP của bạn là", textAlign: TextAlign.center),
                  content: Text(
                    otpCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 40, letterSpacing: 8, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("ĐÓNG"),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}