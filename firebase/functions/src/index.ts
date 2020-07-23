require('firebase-functions');
import * as functions from 'firebase-functions';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();  
//if (location.hostname === "localhost") {
    db.settings({
        host: "localhost:8080",
        ssl: false
        });
//}
const snapshot =  db.collection('users').get();
for (let doc in snapshot) {
    console.log(doc);
}

export const helloWorld = functions.https.onRequest((request, response) => {
     

    const docRef = db.collection('users').doc('alovelace');
        docRef.set({
        first: 'Ada',
        last: 'Lovelace',
        born: 1815
    });

    const aTuringRef = db.collection('users').doc('aturing');

    aTuringRef.set({
        'first': 'Alan',
        'middle': 'Mathison',
        'last': 'Turing',
        'born': 1912
    });

    const snapshot =  db.collection('users').get();
    if (snapshot.empty) {
        console.log('No matching documents.');
    } else {
        snapshot.forEach(doc => {
            console.log(doc.id, '=>', doc.data());
          });
    } 

    response.send({
        "data": {
            "message": `Hello 1, ${request.body.data.name}!`
            
        }
    });
});