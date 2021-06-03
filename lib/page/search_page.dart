import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superchat/helperFunction/sharedpref_helper.dart';
import 'package:superchat/screens/chatScreen.dart';
import 'package:superchat/services/database.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  Stream usersStream;
  String myName, myProfilePic, myUserName, myEmail;

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  onSearchButtonClicked() async {
    isSearching = true;
    usersStream =
        await DatabaseMethods().getUserByUserName(searchController.text);
    setState(() {});
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                profileUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                SizedBox(height: 4),
                Text(email),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["profileUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]);
                })
            : Container();
        // : Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void initState() {
    getMyInfoFromSharedPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black54, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "username"),
                )),
                GestureDetector(
                  onTap: () {
                    if (searchController.text != "") {
                      onSearchButtonClicked();
                    }
                  },
                  child: Icon(
                    Icons.search,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 6),
          searchUsersList(),
        ],
      ),
    );
  }
}
