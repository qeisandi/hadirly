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
  bool isDeleting = false;

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

    filteredData =
        data.where((item) {
          if (item.attendanceDate == null) return false;
          final itemMonth = item.attendanceDate!.month.toString().padLeft(
            2,
            '0',
          );
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
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
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
                                  items:
                                      months.map((month) {
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
                      border: Border.all(color: Colors.grey[200]!, width: 1),
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
                  child:
                      filteredData == null || filteredData!.isEmpty
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
                              final number =
                                  date?.day.toString().padLeft(2, '0') ?? "";

                              final isIzin = item.status == 'izin';

                              return Dismissible(
                                key: Key(item.id.toString()),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  await _showDeleteConfirmation(item);
                                  return false; // Don't auto-dismiss, let the dialog handle it
                                },
                                background: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[600],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Card(
                                    margin: EdgeInsets.symmetric(vertical: 6),
                                    color:
                                        isIzin
                                            ? Colors.orange[50]
                                            : Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 70,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isIzin
                                                      ? Colors.orange
                                                      : Color(0xFF1B3C53),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      isIzin
                                                          ? 'Izin'
                                                          : 'Check In',
                                                      style: TextStyle(
                                                        color:
                                                            isIzin
                                                                ? Colors.orange
                                                                : Color(
                                                                  0xFF1B3C53,
                                                                ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    if (isIzin)
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                          left: 8,
                                                        ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          'IZIN',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ),
                                                    Spacer(),
                                                    Text(
                                                      isIzin
                                                          ? '-'
                                                          : (item.checkInTime ??
                                                              '-'),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      isIzin
                                                          ? 'Alasan'
                                                          : 'Check Out',
                                                      style: TextStyle(
                                                        color:
                                                            isIzin
                                                                ? Colors.orange
                                                                : Color(
                                                                  0xFF1B3C53,
                                                                ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Flexible(
                                                      child: Text(
                                                        isIzin
                                                            ? (item.alasanIzin
                                                                    ?.toString() ??
                                                                '-')
                                                            : (item.checkOutTime ??
                                                                '-'),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              isIzin
                                                                  ? Colors
                                                                      .orange[800]
                                                                  : null,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // Delete Button
                                          GestureDetector(
                                            onTap:
                                                () => _showDeleteConfirmation(
                                                  item,
                                                ),
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.red[200]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red[600],
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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

  Future<void> _showDeleteConfirmation(History item) async {
    final date = item.attendanceDate?.toLocal();
    final formattedDate =
        date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
            : 'Unknown Date';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Hapus Data',
                style: TextStyle(
                  color: Color(0xFF1B3C53),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menghapus data kehadiran?',
                style: TextStyle(fontSize: 16, color: Color(0xFF1B3C53)),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal: $formattedDate',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B3C53),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Check In: ${item.checkInTime ?? '-'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      'Check Out: ${item.checkOutTime ?? '-'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed:
                  isDeleting
                      ? null
                      : () async {
                        Navigator.of(context).pop();
                        await _deleteHistoryItem(item);
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child:
                  isDeleting
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        'Hapus',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteHistoryItem(History item) async {
    if (item.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[600],
          content: Text('ID data tidak valid'),
        ),
      );
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      final success = await AttendanceService().deleteHistoryAttendance(
        item.id!,
      );

      if (success) {
        // Remove item from both lists
        setState(() {
          allData?.removeWhere((element) => element.id == item.id);
          filteredData?.removeWhere((element) => element.id == item.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[600],
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Data berhasil dihapus'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[600],
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Gagal menghapus data'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[600],
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Terjadi kesalahan: $e'),
            ],
          ),
        ),
      );
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }
}
