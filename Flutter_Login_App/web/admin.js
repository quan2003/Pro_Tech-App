const firebaseConfig = {
    apiKey: "AIzaSyDXZ6eE5CoNWmlmkKbBfAntKSU27SK18f4",
    authDomain: "signin-example-b56ee.firebaseapp.com",
    projectId: "signin-example-b56ee",
    storageBucket: "signin-example-b56ee.appspot.com",
    messagingSenderId: "989890578847",
    appId: "1:989890578847:web:903a936a3b2278ed9d95aa",
    measurementId: "G-6C63FNQH88"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Get elements
const signInBtn = document.getElementById('signInBtn');
const signOutBtn = document.getElementById('signOutBtn');
const whenSignedIn = document.getElementById('whenSignedIn');
const whenSignedOut = document.getElementById('whenSignedOut');
const userDetails = document.getElementById('userDetails');

// Add auth provider
const provider = new firebase.auth.GoogleAuthProvider();

// Sign in event handlers
signInBtn.onclick = () => firebase.auth().signInWithPopup(provider);
signOutBtn.onclick = () => firebase.auth().signOut();

// Auth state observer
firebase.auth().onAuthStateChanged(user => {
    if (user) {
        // Signed in
        whenSignedIn.hidden = false;
        whenSignedOut.hidden = true;
        userDetails.innerHTML = `<h3>Hello ${user.displayName}!</h3> <p>User ID: ${user.uid}</p>`;
    } else {
        // Not signed in
        whenSignedIn.hidden = true;
        whenSignedOut.hidden = false;
        userDetails.innerHTML = '';
    }
});