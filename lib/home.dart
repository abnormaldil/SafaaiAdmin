import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? userData;
  TextEditingController balanceController = TextEditingController();
  String selectedEmail = '';
  bool showPaymentDetails = false;

  Future<void> getUserDetails(String email) async {
    try {
      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (docSnapshot.exists) {
        setState(() {
          userData = docSnapshot.data() as Map<String, dynamic>?;
          balanceController.text = userData!['CreditBalance'].toString();
          selectedEmail = email;
          showPaymentDetails = false; // Hide payment details if any
        });
        print('User Details: $userData');
      } else {
        print('No user found with the provided email');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('User Not Found'),
              content: Text('No user found with the provided email.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          userData = null;
          selectedEmail = '';
        });
      }
    } catch (error) {
      print('Error retrieving user details: $error');
      setState(() {
        userData = null;
        selectedEmail = '';
      });
    }
  }

  Future<void> updateUserBalance(String email, int newBalance) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(email).update({
        'CreditBalance': newBalance,
      });
      print('Credit balance updated successfully');
      getUserDetails(email);
      // Show a dialog box indicating successful balance update
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Balance Updated'),
            content:
                Text('SaFi balance for $email has been updated successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error updating credit balance: $error');
    }
  }

  Future<void> deleteUser(String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(email).delete();
      print('User deleted successfully');
      setState(() {
        userData = null;
        selectedEmail = '';
      });
      // Show a dialog box indicating successful deletion
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('User Deleted'),
            content:
                Text('User with email $email has been deleted successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "SaFaai Admin",
            textAlign: TextAlign.justify,
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              fontFamily: 'Gilroy',
              color: Color.fromARGB(255, 41, 40, 40),
            ),
          ),
        ),
        backgroundColor: Color(0xFFffbe00),
        toolbarHeight: 100,
      ),
      body: Container(
        color: Color(0xFFffbe00),
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    var userDocs = snapshot.data!.docs;

                    return SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('View Details')),
                          DataColumn(label: Text('Pending Payments')),
                        ],
                        rows: userDocs.map((DocumentSnapshot document) {
                          var data = document.data() as Map<String, dynamic>;
                          var email = data['Email'];

                          return DataRow(
                            cells: [
                              DataCell(Text(email)),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: () {
                                    getUserDetails(email);
                                  },
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.payment),
                                  onPressed: () {
                                    setState(() {
                                      selectedEmail = email;
                                      showPaymentDetails =
                                          true; // Show payment details
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              if (userData != null && !showPaymentDetails) ...[
                SingleChildScrollView(
                  child: Container(
                    width: 700,
                    margin: EdgeInsets.only(left: 35, right: 35, bottom: 45),
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e1f21),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.close),
                              color: Color(0xFFffbe00),
                              onPressed: () {
                                setState(() {
                                  userData = null;
                                  selectedEmail = '';
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          'Name: ${userData!['Name']}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        Text(
                          'Email: ${userData!['Email']}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        Text(
                          'SaFi Balance: ${userData!['CreditBalance']}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        Text(
                          'Phone Number: ${userData!['PhoneNumber']}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        Text(
                          'Upi Id: ${userData!['UpiId']}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        SizedBox(height: 40),
                        Center(
                          child: Container(
                            width: 300,
                            height: 100,
                            child: TextFormField(
                              controller: balanceController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              decoration: InputDecoration(
                                fillColor: Color.fromARGB(255, 31, 31, 31),
                                filled: true,
                                hintText: "SaFi Balance",
                                hintStyle: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFffbe00),
                                    width: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                updateUserBalance(
                                  selectedEmail,
                                  int.parse(balanceController.text),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                    255, 108, 244, 54), // Text color
                              ),
                              child: Text('Update SaFi Balance'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                deleteUser(selectedEmail);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red, // Text color
                              ),
                              child: Text('Delete User'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (showPaymentDetails) ...[
                SingleChildScrollView(
                  child: Container(
                    width: 800,
                    margin: EdgeInsets.only(
                      left: 30,
                      right: 5,
                    ),
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1e1f21),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.close),
                              color: Color(0xFFffbe00),
                              onPressed: () {
                                setState(() {
                                  showPaymentDetails = false;
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          'Pending Payments for $selectedEmail',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 10),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('transactions')
                              .doc(selectedEmail)
                              .collection(selectedEmail)
                              .orderBy('Time', descending: true)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              var transactionDocs = snapshot.data!.docs;

                              return DataTable(
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Email',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Redeemed amount',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Upi',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Pay',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: transactionDocs
                                    .map((DocumentSnapshot document) {
                                  var data =
                                      document.data() as Map<String, dynamic>;

                                  var userEmail = data['Email'];
                                  var redeemedAmount = data['RedeemAmount'];
                                  var upiId = data['UpiId'];

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          userEmail,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '\₹${(redeemedAmount / 100).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 163, 249, 25),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          upiId,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(Icons.content_copy),
                                          color: Color(0xFFffbe00),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(text: upiId),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'UPI ID copied to clipboard'),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
