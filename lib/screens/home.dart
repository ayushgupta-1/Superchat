import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superchat/helperFunction/sharedpref_helper.dart';
import 'package:superchat/screens/signIn.dart';
import 'package:superchat/services/auth.dart';
import 'package:superchat/services/database.dart';
import 'chatScreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController tabController;
  String myName, myProfilePic, myUserName, myEmail;
  Stream chatRoomsStream, usersStream;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  getChatRoomIdByUserNames(String a, String b) {
    if (a.substring(0, 3).codeUnitAt(0) > b.substring(0, 3).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  buildTab(String name) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.7,
      height: 50,
      child: Center(
        child: Text(
          name,
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  onSearchButtonClicked() async {
    isSearching = true;
    usersStream =
        await DatabaseMethods().getUserByUserName(searchController.text);
    setState(() {});
  }

  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onScreenLoaded();
    tabController = TabController(length: 2, vsync: this);
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget searchListUserTile({String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomIdByUserNames(myUserName, username);
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

  Widget searchPage() {
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

  Widget chatRoomsList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return ChatRoomListTile(
                        ds["lastMessage"], ds.id, myUserName);
                    // Text(
                    //   ds.id.replaceAll(myUserName, "").replaceAll("_", ""));
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Superchat',
          style: TextStyle(
              fontSize: 36, color: Colors.white, fontFamily: "Signatra"),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
              child: Icon(Icons.exit_to_app_outlined),
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          )
        ],
        bottom: TabBar(
          // isScrollable: true,
          indicatorColor: Colors.white,
          controller: tabController,
          // tabs: [buildTab("Chats"), buildTab("Search")],
          tabs: [
            Tab(
              icon: Icon(Icons.message),
              text: "chats",
            ),
            Tab(
              icon: Icon(Icons.search),
              text: "search",
            )
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.purpleAccent, Colors.blueAccent],
                // colors: [Colors.lightBlueAccent, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.topRight),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          chatRoomsList(),
          searchPage(),
        ],
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    print(username);
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    // print(
    //     "something bla bla ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}  ${querySnapshot.docs[0]["imgUrl"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["profileUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                profilePicUrl,
                height: 50,
                width: 50,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 4),
                Text(
                  widget.lastMessage,
                  style: TextStyle(color: Colors.black54),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
