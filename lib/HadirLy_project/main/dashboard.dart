import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/main/riwayat.dart';

class Main extends StatefulWidget {
  static String id = "/main";

  Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final List<Map<String, String>> attendanceData = [
    {
      'date': 'Monday 13',
      'checkIn': '07:50:00',
      'checkOut': '17:50:00',
    },
    {
      'date': 'Monday 13',
      'checkIn': '07:50:00',
      'checkOut': '17:50:00',
    },
    {
      'date': 'Monday 13',
      'checkIn': '07:50:00',
      'checkOut': '17:50:00',
    },
    {
      'date': 'Monday 13',
      'checkIn': '07:50:00',
      'checkOut': '17:50:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F3EF),
      body: Stack(
        children: [
          SizedBox(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Color(0xFF1B3C53),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'MORNING',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Muhammad Rio Akbar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              AssetImage('assets/image/profile.png'),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '123456789',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        
                      ],
                    ),
                  ),
                  SizedBox(height: 24,),
                  Text(
                          'Distance from place',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          '250.43m',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF456882),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Check In',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '07 : 50 : 00',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFD2C1B6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Check Out',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 18,
                                    color: Color(0xFF1B3C53),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '17 : 50 : 00',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF1B3C53)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 24),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Jl. Kebembem II No.83G 9, Kec. Jagakarsa, Kota Jakarta selatan, Indonesia',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Kehadiran',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 18,
                            color: Color(0xFF1B3C53),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Riwayat()));
                          },
                          child: Text('Lihat Semua',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                          ),)
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: attendanceData.length,
                      itemBuilder: (context, index) {
                        final item = attendanceData[index];
                        final parts = item['date']!.split(" ");
                        final day = parts[0];
                        final number = parts.length > 1 ? parts[1] : "";

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
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
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        number,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
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
                                            'Check In',
                                            style: TextStyle(
                                              color: Color(0xFF1B3C53),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            item['checkIn'] ?? '',
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
                                            item['checkOut'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
