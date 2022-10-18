import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/entity/restaurant.dart';

class RestaurantReviewsPage extends StatefulWidget {
  RestaurantReviewsPage({Key key, this.restaurant}) : super(key: key);

  final User _user = FirebaseAuth.instance.currentUser;
  final Restaurant restaurant;

  @override
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<RestaurantReviewsPage> {
  final _textController = TextEditingController();
  String userReview = '';

  CollectionReference restaurants =
      FirebaseFirestore.instance.collection('restaurants');

  Future<void> addReview() async {
    return restaurants
        .doc(widget.restaurant.id)
        .collection("reviews")
        .add({'review': userReview, 'user_img': widget._user.photoURL})
        .then((value) => print("Review Added"))
        .catchError((error) => print("Failed to add review: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: SizedBox(
          width: 200,
          height: 50,
          child: MaterialButton(
            onPressed: () {
              setState(() {
                userReview = _textController.text;
              });
              addReview();
            },
            color: Colors.orange,
            child: const Text(
              'Add Review',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 30, left: 10),
              child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ),
          ),
          Container(
            width: 300.0,
            height: 100.0,
            alignment: Alignment.center,
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Add Review",
                suffixIcon: IconButton(
                  onPressed: () {
                    _textController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 25.0),
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('restaurants')
                      .doc(widget.restaurant.id)
                      .collection('reviews')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> favSnapshot) {
                    return favSnapshot.hasData
                        ? Expanded(
                            child: ListView.builder(
                                itemCount: favSnapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot data =
                                      favSnapshot.data.docs[index];
                                  return buildItemRow(
                                      data.get('review'), data.get('user_img'));
                                }))
                        : Container();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildItemRow(String review, String imageUrl) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: <Widget>[
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageUrl),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          SizedBox(
            width: MediaQuery.of(context).size.width - 150,
            child: Text(
              review,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
