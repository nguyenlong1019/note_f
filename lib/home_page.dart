import 'package:firebase_auth/firebase_auth.dart'
  hide EmailAuthProvider, PhoneAuthProvider;
import 'package:guest_book2/guest_book.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'src/widgets.dart';
import 'app_state.dart';
import 'src/authentication.dart';
import 'yes_no_selection.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Meetup', style: TextStyle(color: Colors.white, fontSize: 18),),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        children: <Widget>[
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8,),
          const IconAndDetail(Icons.calendar_today, 'Aug 28'),
          const IconAndDetail(Icons.location_city, 'Hanoi'),
          Consumer<ApplicationState>(
            builder: (context, appState, _) => AuthFunc(
              loggedIn: appState.loggedIn,
              signOut: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
          const Header("what we'll be doing"),
          const Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                switch (appState.attendees) {
                  1 => const Paragraph('1 person going'),
                  >= 2 => Paragraph('${appState.attendees} people going'),
                  _ => const Paragraph('No one going'),
                },
                if (appState.loggedIn) ...[
                  YesNoSelection(
                    state: appState.attending,
                    onSelection: (attending) => appState.attending = attending,
                  ),
                  const Header('Discussion'),
                  GuestBook(
                    addMessage: (message) => 
                      appState.addMessageToGuestBook(message),
                    messages: appState.guestBookMessages,
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
