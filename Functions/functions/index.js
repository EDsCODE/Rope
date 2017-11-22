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

// exports.setRopeExpirationTime = functions.database.ref('/ropesIP/{ropeID}').onCreate(event => {
// 	const currentTime = new Date().getTime();

// 	console.log("rope created");

// 	return event.data.ref.child("expirationtime").set(currentTime + 43200000);
// })

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

exports.distributeNewRope = functions.database.ref('/ropes/{ropeID}').onCreate(event => {
	console.log(event.data.val());
	event.data.child('participants').forEach(function(participant) {
		console.log(participant.key);
		users_ref.child(participant.key).child('ropes').child(event.params.ropeID).set(event.data.val());
		users_ref.child(participant.key).child('ropeIP').set(false);
	});
})