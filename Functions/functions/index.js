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
			if (rope.hasChild('expirationDate')) {
				if (rope.child('expirationDate').val() > currentTime) {
					return;
				}

				if (rope.hasChild('media')) {
					ropes_ref.child(rope.key).set(rope.val());
					ropesIP_ref.child(rope.key).remove();
				} else {
					var numberOfPeople = 0;
					ropesIP_ref.child('participants').forEach(function(participant) {
						users_ref.child(participant.key).child('ropeIP').set(false);
						numberOfPeople++;
						if (numberOfPeople == ropesIP_ref.child('participants').length) {
							ropesIP_ref.child(rope.key).remove();
						}
					})
				}
			} else {
				ropesIP_ref.child(rope.key).remove();
			}
		});
	});
	res.send('moving rope');
});

exports.distributeNewRope = functions.database.ref('/ropes/{ropeID}').onCreate(event => {
	console.log(event.data.val());
	event.data.child('participants').forEach(function(participant) {
		console.log(participant.key);
		let ropeData = event.data.val();
		ropeData['viewed'] = false;
		users_ref.child(participant.key).child('ropes').child(event.params.ropeID).set(ropeData);
		users_ref.child(participant.key).child('ropeIP').set(false);
		users_ref.child(participant.key).child('profile').child('notificationToken').once('value', function(token) {
			if (token.exists()) {
				const payload = {
					notification: {
					title: "Rope",
					body: "You have a new Rope!"
					}
				};
				admin.messaging().sendToDevice(token.val(), payload)
				.then(function(response) {
					console.log("successfully sent message");
				})
				.catch(function(error) {
					console.log("Error sending message:", error);
				})
			} 
		})
	});
})

exports.checkCount = functions.database.ref('/ropesIP/{ropeID}/thumbnail/{thumbnailID}').onCreate(event => {
	ropesIP_ref.child(event.params.ropeID).once('value', function(snapshot) {
		let ropeData = snapshot.val();
		let participantsLength = Object.keys(ropeData['participants']).length;
		let thumbnailLength = Object.keys(ropeData['thumbnail']).length;
		ropeData['expirationDate'] = Date.now();
		console.log(participantsLength)
		console.log(thumbnailLength);
		if (participantsLength * 5 == thumbnailLength) {
			ropes_ref.child(event.params.ropeID).set(ropeData);
			ropesIP_ref.child(event.params.ropeID).remove();
		}

	})
})
