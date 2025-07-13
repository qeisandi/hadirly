import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_history.dart';
import 'package:hadirly/HadirLy_project/helper/servis/history_servis.dart';
import 'package:hadirly/HadirLy_project/main/profile.dart';

class Riwayat extends StatefulWidget {
  static String id = "/riwayat";

  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  late Future<HistoryAttend?> futureHistory;
  String? selectedMonth;
  List<History>? allData;
  List<History>? filteredData;

  final List<Map<String, String>> months = [
    {'value': '01', 'label': 'Januari'},
    {'value': '02', 'label': 'Februari'},
    {'value': '03', 'label': 'Maret'},
    {'value': '04', 'label': 'April'},
    {'value': '05', 'label': 'Mei'},
    {'value': '06', 'label': 'Juni'},
    {'value': '07', 'label': 'Juli'},
    {'value': '08', 'label': 'Agustus'},
    {'value': '09', 'label': 'September'},
    {'value': '10', 'label': 'Oktober'},
    {'value': '11', 'label': 'November'},
    {'value': '12', 'label': 'Desember'},
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().month.toString().padLeft(2, '0');
    futureHistory = AttendanceService().fetchHistoryAttendance();
  }

  void _filterDataByMonth(List<History> data) {
    if (selectedMonth == null) {
      filteredData = data;
      return;
    }

    filteredData = data.where((item) {
      if (item.attendanceDate == null) return false;
      final itemMonth = item.attendanceDate!.month.toString().padLeft(2, '0');
      return itemMonth == selectedMonth;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Kehadiran',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF1B3C53),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text("Fitur Settings belum tersedia"),
                ),
              );
            },
            icon: Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRiwayat,
        child: FutureBuilder<HistoryAttend?>(
          future: futureHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data?.data?.isEmpty == true) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      'Tidak ada data kehadiran',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!.data!;
            allData = data;
            _filterDataByMonth(data);

            return Column(
              children: [
                // Filter Section
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Simple Header
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFF1B3C53),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Filter Bulan',
                            style: TextStyle(
                              color: Color(0xFF1B3C53),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Simple Dropdown
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedMonth,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF1B3C53),
                                  ),
                                  hint: Text(
                                    'Pilih Bulan',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  items: months.map((month) {
                                    return DropdownMenuItem<String>(
                                      value: month['value'],
                                      child: Text(
                                        month['label']!,
                                        style: TextStyle(
                                          color: Color(0xFF1B3C53),
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedMonth = newValue;
                                      _filterDataByMonth(allData!);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          // Simple Clear Button
                          if (selectedMonth != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedMonth = null;
                                  _filterDataByMonth(allData!);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.clear_rounded,
                                  color: Colors.red[600],
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Results Count
                if (filteredData != null)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF1B3C53),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Menampilkan ${filteredData!.length} dari ${allData!.length} data',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1B3C53),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // List View
                Expanded(
                  child: filteredData == null || filteredData!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada data',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                selectedMonth != null
                                    ? 'untuk bulan ${months.firstWhere((m) => m['value'] == selectedMonth)['label']}'
                                    : 'kehadiran tersedia',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filteredData!.length,
              itemBuilder: (context, index) {
                            final item = filteredData![index];
                final date = item.attendanceDate?.toLocal();
                final day = _getDayName(date);
                final number = date?.day.toString().padLeft(2, '0') ?? "";

                return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1B3C53),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  day,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  number,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Check In',
                                      style: TextStyle(
                                        color: Color(0xFF1B3C53),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      item.checkInTime ?? '-',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Check Out',
                                      style: TextStyle(
                                        color: Color(0xFF1B3C53),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      item.checkOutTime ?? '-',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshRiwayat() async {
    setState(() {
      futureHistory = AttendanceService().fetchHistoryAttendance();
    });
  }

  String _getDayName(DateTime? date) {
    if (date == null) return '';
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
