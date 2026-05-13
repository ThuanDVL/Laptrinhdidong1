import 'package:flutter/material.dart';
import '../storage/app_data.dart';
import '../models/tour.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {

  @override
  Widget build(BuildContext context){

    List<Tour> favorites = AppData.favorites;

    return Scaffold(

      backgroundColor: Colors.grey[100],

      body: favorites.isEmpty

      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "Chưa có tour yêu thích",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )

      : ListView.builder(

          padding: EdgeInsets.all(12),
          itemCount: favorites.length,

          itemBuilder: (context, index){

            var tour = favorites[index];

            return Container(
              margin: EdgeInsets.only(bottom: 15),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),

              child: Row(
                children: [

                  /// IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                    child: Image.network(
  tour.image,
  width: 110,
  height: 100,
  fit: BoxFit.cover,

  errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 110,
      height: 100,
      color: Colors.grey[300],
      child: Icon(Icons.image_not_supported, color: Colors.grey),
    );
  },

  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(
      width: 110,
      height: 100,
      alignment: Alignment.center,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  },
),
                  ),

                  /// INFO
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            tour.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                tour.location,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          Text(
                            "Tour yêu thích ❤️",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// DELETE BUTTON
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: (){
                      setState(() {
                        AppData.favorites.removeAt(index);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đã xóa khỏi yêu thích"))
                      );
                    },
                  )
                ],
              ),
            );

          },
        ),
    );
  }
}