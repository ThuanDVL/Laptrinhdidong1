import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), (){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00D1A3),
      body: Center(
        child: Text(
          "Fellow4U",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ================= ONBOARDING =================

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController _controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> data = [
    {
      "title": "Tìm hướng dẫn viên địa phương dễ dàng",
      "desc": "Với Fellow4U, bạn có thể tìm hướng dẫn viên địa phương và khám phá theo cách bạn muốn.",
      "image": "https://cdn-icons-png.flaticon.com/512/854/854878.png"
    },
    {
      "title": "Nhiều tour khắp thế giới",
      "desc": "Khám phá hàng trăm tour ở nhiều quốc gia với mức giá tốt nhất.",
      "image": "https://cdn-icons-png.flaticon.com/512/201/201623.png"
    },
    {
      "title": "Tạo chuyến và nhận ưu đãi",
      "desc": "Tạo chuyến của riêng bạn và nhận ưu đãi độc quyền từ hướng dẫn viên địa phương.",
      "image": "https://cdn-icons-png.flaticon.com/512/2150/2150901.png"
    }
  ];

  void nextPage() {
    if (currentPage < data.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [

          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: data.length,
              onPageChanged: (index){
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (_, index){

                return Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// IMAGE
                      Image.network(
                        data[index]["image"]!,
                        height: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey,
                            child: const Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      ),

                      SizedBox(height: 40),

                      /// TITLE
                      Text(
                        data[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 15),

                      /// DESC
                      Text(
                        data[index]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),

                      SizedBox(height: 30),

                      /// DOTS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          data.length,
                          (i) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            width: currentPage == i ? 12 : 8,
                            height: currentPage == i ? 12 : 8,
                            decoration: BoxDecoration(
                              color: currentPage == i
                                  ? Color(0xFF00D1A3)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// BUTTONS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// SKIP
                TextButton(
                  onPressed: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: Text("BỎ QUA"),
                ),

                /// NEXT / GET STARTED
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00D1A3),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  onPressed: nextPage,
                  child: Text(
                    currentPage == data.length - 1
                        ? "BẮT ĐẦU"
                        : "TIẾP",
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}