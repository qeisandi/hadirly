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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: Color(0xFF1B3C53)),
                      SizedBox(width: 8),
                      Text(
                        'Filter Bulan:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B3C53),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF1B3C53)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedMonth,
                              isExpanded: true,
                              hint: Text('Pilih Bulan'),
                              items: months.map((month) {
                                return DropdownMenuItem<String>(
                                  value: month['value'],
                                  child: Text(month['label']!),
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
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            selectedMonth = null;
                            _filterDataByMonth(allData!);
                          });
                        },
                        icon: Icon(Icons.clear, color: Colors.red),
                        tooltip: 'Hapus Filter',
                      ),
                    ],
                  ),
                ),
                
                // Results Count
                if (filteredData != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Menampilkan ${filteredData!.length} dari ${allData!.length} data kehadiran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                              Icon(Icons.filter_list_off, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 20),
                              Text(
                                'Tidak ada data kehadiran untuk bulan yang dipilih',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
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
                              padding: const EdgeInsets.all(8.0),
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
