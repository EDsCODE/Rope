const functions = require('firebase-functions');
const admin = require("firebase-admin");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


admin.initializeApp(functions.config().firebase);
const db = admin.database();
var ropesIP_ref = db.ref('/ropesIP');
var ropes_ref = db.ref('/ropes');
var users_ref = db.ref('/users');
var usernames_ref = db.ref('/usernames');

exports.setRopeComplete = functions.https.onRequest((req,res) => {
	ropesIP_ref.orderByChild('expirationDate').once('value', function(snapshot) {
		const currentTime = new Date().getTime();
		snapshot.forEach(function(rope) {
			if (rope.child('expirationDate').val() > currentTime) {
				return;
			}
			ropes_ref.child(rope.key).set(rope.val());
			ropesIP_ref.child(rope.key).remove();
		});
	});
	res.send('moving rope');
});

exports.sendFriendRequest = functions.database.ref('/users/{userID}/sentRequests/{requestID}').onCreate(event => {
	var username = event.data.child('receiver').val();
	var sentDate = event.data.child('sentDate').val();
	var status = event.data.child('status').val();
	var sender = event.data.child('sender').val();
	usernames_ref.once('value', function(snapshot) {
		if (snapshot.hasChild(username)) {
			var receiver = snapshot.child(username).val();
			var request = {
				"sentDate" : sentDate,
				"sender" : sender,
				"status" : status,
			};
			users_ref.child(receiver).child("receivedRequests").push().set(request);
			users_ref.child(event.params.userID).child('sentRequests').child(event.params.requestID).remove();
			users_ref.child(receiver).child("profile").child("notificationToken").once('value', function(token) {
				if (token.exists()) {
					const payload = {
						notification: {
						title: "Rope",
						body: "Someone wants to be your friend!"
						}
					};
					return admin.messaging().sendToDevice(token.val(), payload)
					.then(function(response) {
						console.log("successfully sent message");
					})
					.catch(function(error) {
						console.log("Error sending message:", error);
					});
				}
			})
		}
	})
})
