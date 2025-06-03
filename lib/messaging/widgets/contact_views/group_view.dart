import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupView extends StatefulWidget {
  final String groupName;
  final String contactID;

  const GroupView({
    super.key,
    required this.groupName,
    required this.contactID,
  });

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  late Future<List<Map<String, String>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = listMembers();
  }

  Future<List<Map<String, String>>> listMembers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, String>> members = [];
    String name, role;

    // Fetch all members of the group
    var membersSnapshot = await firestore.collection("groups").doc(widget.contactID).collection("members").get();

    // If no members found, return empty list early
    if (membersSnapshot.docs.isEmpty) return members;

    // Fetch all user data in a single batch instead of making multiple calls
    List<String> memberIds = membersSnapshot.docs.map((doc) => doc.id).toList();
    var usersSnapshot = await firestore.collection("users").where(FieldPath.documentId, whereIn: memberIds).get();

    // Convert Firestore data to a list of maps
    for (var memberDoc in membersSnapshot.docs) {
      var userDoc = usersSnapshot.docs.firstWhere(
            (doc) => doc.id == memberDoc.id,
        orElse: () => throw Exception("User data not found"),
      );

      name = userDoc.data()["username"] ?? "Unknown";
      role = memberDoc.data()["role"] ?? "Member";
      members.add({name: role});
    }

    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        title: Text(
          "Overview",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                child: Icon(Icons.group, size: 50),
              ),
              SizedBox(height: 20),
              Text(
                widget.groupName,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, String>>>(
                  future: _membersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error loading members",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "No members found",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true, // Allows ListView to fit content
                        itemBuilder: (context, index) {
                          String name = snapshot.data![index].keys.first;
                          String role = snapshot.data![index][name]!;
                          return ListTile(
                            leading: Icon(Icons.person, color: Colors.white, size: 35,),

                            title: Text(name, style: TextStyle(color: Colors.white, fontSize: 20),),

                            subtitle: Text(role, style: TextStyle(color: Colors.white70, fontSize: 17),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
