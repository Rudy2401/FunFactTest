const functions = require('firebase-functions');
const googleCloudStorage = require('@google-cloud/storage');
var admin = require("firebase-admin");
var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://funfacts-5b1a9.firebaseio.com",
    storageBucket: "funfacts-5b1a9.appspot.com"
});

const db = admin.firestore()
exports.numOfFunFacts = 0
exports.numOfLandmarks = 0

//Algolia Code
const env = functions.config();
const algoliasearch = require('algoliasearch');

// Initialize Algolia Client
const client = algoliasearch(env.algolia.appid, env.algolia.apikey);
const landmarkIndex = client.initIndex('landmark_name');
const hashtagIndex = client.initIndex('hashtag_name');
const userIndex = client.initIndex('user_profile');

exports.indexLandmark = functions.firestore.document('/landmarks/{landmarkID}').onCreate((snap, context) => {

    var _geoloc = {
        lat: snap.data().coordinates.latitude,
        lng: snap.data().coordinates.longitude
    };

    const name = snap.data().name;
    const address = snap.data().address;
    const city = snap.data().city;
    const state = snap.data().state;
    const country = snap.data().country;
    const type = snap.data().type;
    const zipcode = snap.data().zipcode;
    const image = snap.data().image;
    const numOfFunFacts = snap.data().numOfFunFacts;
    const likes = snap.data().likes;
    const dislikes = snap.data().dislikes;
    const objectID = snap.id;

    // Add data to algolia index
    return landmarkIndex.addObject({
        objectID,
        name,
        address,
        _geoloc,
        city,
        state,
        country,
        type,
        image,
        numOfFunFacts,
        likes,
        dislikes,
        zipcode
    });
});
exports.indexLandmarkUpdate = functions.firestore.document('/landmarks/{landmarkID}').onUpdate((change, context) => {

    var _geoloc = {
        lat: change.after.data().coordinates.latitude,
        lng: change.after.data().coordinates.longitude
    };

    const name = change.after.data().name;
    const address = change.after.data().address;
    const city = change.after.data().city;
    const state = change.after.data().state;
    const country = change.after.data().country;
    const type = change.after.data().type;
    const zipcode = change.after.data().zipcode;
    const image = change.after.data().image;
    const numOfFunFacts = change.after.data().numOfFunFacts;
    const likes = change.after.data().likes;
    const dislikes = change.after.data().dislikes;
    const objectID = change.after.id;

    // Add data to algolia index
    return landmarkIndex.addObject({
        objectID,
        name,
        address,
        _geoloc,
        city,
        state,
        country,
        type,
        image,
        numOfFunFacts,
        likes,
        dislikes,
        zipcode
    });
});
exports.unindexLandmark = functions.firestore.document('/landmarks/{landmarkID}').onDelete((snap, context) => {
    const objectID = snap.id;

    // Delete ID from index
    return landmarkIndex.deleteObject(objectID);
});

exports.indexHashtag = functions.firestore.document('/hashtags/{hashtagID}').onCreate((snap, context) => {
    const name = snap.id;
    const count = snap.data().hashtagcount;
    const objectID = snap.id;
    var image = "";
    admin.firestore().collection('hashtags').doc(objectID).collection('funFacts').get().then(doc => {
        doc.forEach(element => {
            image = element.id;
            // Add data to algolia index
            return hashtagIndex.addObject({
                objectID,
                name,
                count,
                image
            });
        });
        return "";
    }).catch(error => {
        console.log(error);
    });
});
exports.indexHashtagUpdate = functions.firestore.document('/hashtags/{hashtagID}').onUpdate((change, context) => {
    const name = change.after.id;
    const count = change.after.data().hashtagcount;
    const objectID = change.after.id;
    var image = "";
    admin.firestore().collection('hashtags').doc(objectID).collection('funFacts').get().then(doc => {
        doc.forEach(element => {
            image = element.id;
            // Add data to algolia index
            return hashtagIndex.addObject({
                objectID,
                name,
                count,
                image
            });
        });
        return "";
    }).catch(error => {
        console.log(error);
    });
});
exports.unindexHashtag = functions.firestore.document('/hashtags/{hashtagID}').onDelete((snap, context) => {
    const objectID = snap.id;

    // Delete ID from index
    return hashtagIndex.deleteObject(objectID);
});

exports.indexUsers = functions.firestore.document('/users/{userID}').onCreate((snap, context) => {
    const objectID = snap.id;
    const name = snap.data().name;
    const userName = snap.data().userName;
    const photoURL = snap.data().photoURL;
    return userIndex.addObject({
        objectID,
        name,
        userName,
        photoURL
    });
});
exports.indexUsersUpdate = functions.firestore.document('/users/{userID}').onUpdate((change, context) => {
    const objectID = change.before.id;
    const name = change.after.data().name;
    const userName = change.after.data().userName;
    const photoURL = change.after.data().photoURL;
    return userIndex.addObject({
        objectID,
        name,
        userName,
        photoURL
    });
});
exports.unindexUsers = functions.firestore.document('/users/{userID}').onDelete((snap, context) => {
    const objectID = snap.id;

    // Delete ID from index
    return userIndex.deleteObject(objectID);
});

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

// exports.helloWorld = functions.https.onRequest((request, response) => {
//     getNumOfLandmarks();
//     getNumOfFunFacts();
//     response.send("Number of Landmarks = " + numOfLandmarks + "\r\nNumber of Fun Facts = " + numOfFunFacts);
// });

function getNumOfFunFacts() {
    db.collection('funFacts').get().then(snapshot => {
        if (!snapshot.empty) {
            numOfFunFacts = snapshot.size;
        } else response.send('No docs found!')
        return numOfFunFacts;
    })
        .catch(err => {
            console.log(err);
            response.status(500).send(error);
            return 500;
        })
}
function getNumOfLandmarks() {
    db.collection('landmarks').get().then(snapshot => {
        if (!snapshot.empty) {
            numOfLandmarks = snapshot.size;
        } else response.send('No docs found!')
        return numOfLandmarks;
    })
        .catch(err => {
            console.log(err);
            response.status(500).send(error);
            return 500;
        })
}

exports.updateHashtagCount = functions.firestore.document('/hashtags/{tagID}/funFacts/{funFactID}').onCreate((change, context) => {
    // New document Created : add one to count
    const tagID = context.params.tagID
    const docRef = admin.firestore().collection('hashtags').doc(tagID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        var tcount = 0;
        if (!snap.exists) {
            tcount = 0;
        } else {
            tcount = snap.data().hashtagcount;
        }
        const hashtagcount = tcount + 1;
        const data = { hashtagcount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateHashtagCountForDelete = functions.firestore.document('/hashtags/{tagID}/funFacts/{funFactID}').onDelete((change, context) => {
    // Document Deleted : subtract one from count
    const tagID = context.params.tagID
    const docRef = admin.firestore().collection('hashtags').doc(tagID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        const hashtagcount = snap.data().hashtagcount - 1;
        const data = { hashtagcount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateDisputeCount = functions.firestore.document('/users/{userID}/funFactsDisputed/{disputeID}').onCreate((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        var count = 0;
        if (isNaN(snap.data().disputeCount)) {
            count = 0;
        } else {
            count = snap.data().disputeCount;
        }
        const disputeCount = count + 1;
        const data = { disputeCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateDisputeCountForDelete = functions.firestore.document('/users/{userID}/funFactsDisputed/{disputeID}').onDelete((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        console.log("Add Dispute Count = " + snap.data().count);
        // get the total tag count and add one
        const disputeCount = snap.data().disputeCount - 1;
        const data = { disputeCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});

exports.updateLikeCount = functions.firestore.document('/users/{userID}/funFactsLiked/{funFactID}').onCreate((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        var count = 0;
        if (isNaN(snap.data().likeCount)) {
            count = 0;
        } else {
            count = snap.data().likeCount;
        }
        const likeCount = count + 1;
        const data = { likeCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateLikeCountForDelete = functions.firestore.document('/users/{userID}/funFactsLiked/{funFactID}').onDelete((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        console.log("Add Dispute Count = " + snap.data().count);
        // get the total tag count and add one
        const likeCount = snap.data().likeCount - 1;
        const data = { likeCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});

exports.updateDislikeCount = functions.firestore.document('/users/{userID}/funFactsDisliked/{funFactID}').onCreate((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        var count = 0;
        if (isNaN(snap.data().dislikeCount)) {
            count = 0;
        } else {
            count = snap.data().dislikeCount;
        }
        const dislikeCount = count + 1;
        const data = { dislikeCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateDislikeCountForDelete = functions.firestore.document('/users/{userID}/funFactsDisliked/{funFactID}').onDelete((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        const dislikeCount = snap.data().dislikeCount - 1;
        const data = { dislikeCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});

exports.updateSubmittedCount = functions.firestore.document('/users/{userID}/funFactsSubmitted/{funFactID}').onCreate((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        var count = 0;
        if (isNaN(snap.data().submittedCount)) {
            count = 0;
        } else {
            count = snap.data().submittedCount;
        }
        const submittedCount = count + 1;
        const data = { submittedCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateSubmittedCountForDelete = functions.firestore.document('/users/{userID}/funFactsSubmitted/{funFactID}').onDelete((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        const submittedCount = snap.data().submittedCount - 1;
        const data = { submittedCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});

exports.deleteUserFields = functions.auth.user().onDelete((user) => {
    const uid = user.uid;
    return admin.firestore().collection('users').doc(uid).delete();
});

exports.udpateNumOfFunFacts = functions.firestore.document('/funFacts/{funFactID}').onCreate((snap, context) => {
    // New document Created : add one to count
    const landmarkID = snap.data().landmarkId;
    const docRef = admin.firestore().collection('landmarks').doc(landmarkID)

    return docRef.get().then(snap => {
        // get the total funFact count and add one
        const funFactCount = snap.data().numOfFunFacts;
        const numOfFunFacts = funFactCount + 1;
        const data = { numOfFunFacts }
        // run update
        return docRef.set(data, { merge: true });
    })
});

exports.udpateNumOfFunFactsForDelete = functions.firestore.document('/funFacts/{funFactID}').onDelete((snap, context) => {
    // Document Deleted : subtract one from count
    const landmarkID = snap.data().landmarkId;
    const docRef = admin.firestore().collection('landmarks').doc(landmarkID)
    const userSubRef = admin.firestore().collection('users')

    return docRef.get().then(snap => {
        // get the total funFact count and subtract one
        const funFactCount = snap.data().numOfFunFacts;
        const numOfFunFacts = funFactCount - 1;
        const data = { numOfFunFacts }
        // run update
        return docRef.set(data, { merge: true });
    })
});

exports.updateVerifiedCount = functions.firestore.document('/users/{userID}/funFactsVerified/{funFactID}').onCreate((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        var count = 0;
        if (isNaN(snap.data().verifiedCount)) {
            count = 0;
        } else {
            count = snap.data().verifiedCount;
        }
        const verifiedCount = count + 1;
        const data = { verifiedCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateVerifiedCountForDelete = functions.firestore.document('/users/{userID}/funFactsVerified/{funFactID}').onDelete((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        const verifiedCount = snap.data().verifiedCount - 1;
        const data = { verifiedCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});


exports.updateRejectedCount = functions.firestore.document('/users/{userID}/funFactsRejected/{funFactID}').onCreate((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        var count = 0;
        if (isNaN(snap.data().rejectedCount)) {
            count = 0;
        } else {
            count = snap.data().rejectedCount;
        }
        const rejectedCount = count + 1;
        const data = { rejectedCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});
exports.updateRejectedCountForDelete = functions.firestore.document('/users/{userID}/funFactsRejected/{funFactID}').onDelete((change, context) => {
    // New document Created : add one to count
    const userID = context.params.userID
    const docRef = admin.firestore().collection('users').doc(userID)

    return docRef.get().then(snap => {
        // get the total tag count and add one
        const rejectedCount = snap.data().rejectedCount - 1;
        const data = { rejectedCount }
        // run update
        return docRef.set(data, { merge: true });
    })
});

exports.updateUserFactsSubmittedForDelete = functions.firestore.document('/funFacts/{funFactID}').onDelete((change, context) => {
    const userID = change.data().submittedBy
    const funFactID = change.data().id
    const docRef = admin.firestore().collection('users').doc(userID).collection('funFactsSubmitted').doc(funFactID)

    return docRef.delete().then(() => {
        return console.log('Deleted funFactID ', funFactID);
      }).catch((error) => {
        return console.error('Deletion failed:', error);
      });
});
exports.updateUserFactsRejectedForDelete = functions.firestore.document('/funFacts/{funFactID}').onDelete((change, context) => {
    const userID = change.data().submittedBy
    const funFactID = change.data().id
    const docRef = admin.firestore().collection('users').doc(userID).collection('funFactsRejected').doc(funFactID)

    return docRef.delete().then(() => {
        return console.log('Deleted funFactID ', funFactID);
      }).catch((error) => {
        return console.error('Deletion failed:', error);
      });
});
exports.updateUserFactsLikedForDelete = functions.firestore.document('/funFacts/{funFactID}').onDelete((change, context) => {
    const userID = change.data().submittedBy
    const funFactID = change.data().id
    const docRef = admin.firestore().collection('users').doc(userID).collection('funFactsLiked').doc(funFactID)

    return docRef.delete();
});
exports.updateUserFactsVerifiedForDelete = functions.firestore.document('/funFacts/{funFactID}').onDelete((change, context) => {
    const userID = change.data().submittedBy
    const funFactID = change.data().id
    const docRef = admin.firestore().collection('users').doc(userID).collection('funFactsVerified').doc(funFactID)

    return docRef.delete().then(() => {
        return console.log('Deleted funFactID ', funFactID);
      }).catch((error) => {
        return console.error('Deletion failed:', error);
      });
});
exports.updateUserFactsDisputedForDelete = functions.firestore.document('/funFacts/{funFactID}').onDelete((change, context) => {
    const userID = change.data().submittedBy
    const funFactID = change.data().id
    const docRef = admin.firestore().collection('users').doc(userID).collection('funFactsDisputed').doc(funFactID)

    return docRef.delete().then(() => {
        return console.log('Deleted funFactID ', funFactID);
      }).catch((error) => {
        return console.error('Deletion failed:', error);
      });
});
exports.deleteImage = functions.firestore.document('/funFacts/{funFactID}').onDelete((change, context) => {
    const funFactID = change.data().id
    const filePath = 'images/' + funFactID + '.jpeg'
    // const bucket = googleCloudStorage.bucket('funfacts-5b1a9.appspot.com')
    const bucket = admin.storage().bucket()
    const file = bucket.file(filePath)

    file.delete().then(() => {
        return console.log('Successfully deleted photo with UID', funFactID)
    }).catch((err) => {
        return console.error('Failed to remove photo, error', err)
    });
});