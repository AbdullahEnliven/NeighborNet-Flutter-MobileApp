NeighborNet is a neighborhood-focused mobile application designed to connect people living in the same 
locality. 

The app solves the real-world problem of disconnected neighborhoods by enabling users to:  
● Share giveaways, announcements, and alerts  
● Chat with neighbors in real-time  
● Report issues and activities  
● Filter content based on post type and user location  

The main goal is to build stronger communities through better communication and collaboration.  


Tech Stack  
● Frontend: Flutter (with BLoC and Clean Architecture)  
● Backend: Firebase Firestore, Firebase Auth, Firebase Storage  
● State Management: Cubit/BLoC  
● Push Notifications: Firebase Cloud Messaging  
● Image Handling: Image Picker + Firebase Storage  
● Deep Linking: For post sharing  
● Online/Offline Status: Firestore + onDisconnect()  


Key Features Implemented  
Firebase Phone Authentication  
Secure login using phone number, with the ability to edit profile details like name, profile picture, 
and address.  
User Profile Management  
Users can update their personal information including name, profile image, and area (location).  

Area-Based Functionality  
● The user’s area is saved during profile setup.  
● Posts and alerts are shown and filtered based on the user's area.  
● Area-based alert notifications are sent to neighbors when an alert is posted.  

Post Creation   
● Users can create posts with optional images.  
● Supported post types: Announcement, Giveaway, Alert, Help, Volunteers, etc.  

Post Management  
● Users can view, edit, and delete their own posts.  

Post Filtering  
Posts are filtered by both post type and user's neighborhood/area.  

Real-Time Chat  
● One-on-one messaging between neighbors.  
● Shows online/offline status, supports chat image sharing, and delivers push notifications for new 
messages.  

Push Notifications  
● For new chat messages, new posts, and area alerts.  

Deep Linking Support  
● Shareable links to specific posts.  
● If app is not installed, opens in Play Store.  
● If installed, opens directly to the post inside the app.  

Post Sharing Options  
● Posts can be shared with images and links via WhatsApp, SMS, or other platforms.  
Integrated Communication Shortcuts  
● Quickly call, WhatsApp, or chat with neighbors from post or profile screens. Categorized Home 
Feed  
● Posts displayed in sections based on their type (e.g., Alerts, Giveaways, Announcements).  

Working Modules:  
User Profile – Phone login, image/name update, location save  
Posts – Create, view, and filter posts by category and area  
Chat – Real-time with image support, deep linking, online status  
Notifications – Realtime messaging and post alerts  
UI – Dark theme, organized home layout, bottom navigation, responsive design 
