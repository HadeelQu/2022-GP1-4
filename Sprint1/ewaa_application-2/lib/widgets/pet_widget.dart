import 'package:ewaa_application/style.dart';
import 'package:flutter/material.dart';

class myPetWidget extends StatelessWidget {
  String img, name, breed, gender, age;

  myPetWidget(
      {required this.img,
      required this.name,
      required this.breed,
      required this.gender,
      required this.age});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 247, 247),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(1, 1), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 180,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: NetworkImage(
                  img,
                ),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Style.black,
              fontFamily: 'ElMessiri',
              fontSize: 18,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                      breed,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Style.black,
                        fontFamily: 'ElMessiri',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      gender,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Style.black,
                        fontFamily: 'ElMessiri',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 6.0),
                    child: Text(
                      age,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Style.black,
                        fontFamily: 'ElMessiri',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
