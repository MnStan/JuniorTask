# App
This iOS app fetches and displays a list of events in Poland from the Ticketmaster API. Users can browse upcoming events, view details, and navigate between a list view and a detailed event screen.

# Features

- Event List: Displays events with name, date, city, venue, and image, supporting infinite scroll and sorting options.
- Event Details: Detailed view includes artist, date/time, location, genre, price range, and image gallery.

# Technical Overview
- Architecture: MVVM for a modular, testable structure.
- Frameworks: SwiftUI, Combine or structured concurrency for networking.
- Sorting and Filtering: Implemented to enhance user experience.

# Testing
Unit Tests: Added to ensure stability and code quality across the app.

# Requirements
- iOS: Version 16 or higher.
- Dependencies: No external libraries.

# Presentation
<p align="center">
<img src="https://github.com/user-attachments/assets/bbc3fde1-30e5-428a-945b-beddd9490504" width="425"/> <img src="https://github.com/user-attachments/assets/ccaecb54-37cd-4347-b79c-b7af509e6293" width="425"/> 
</p>

<p align="center">
<img src="https://github.com/user-attachments/assets/1d471b01-a496-4d38-b3c6-9e1f090df900" width="425"/> <img src="https://github.com/user-attachments/assets/b437e5c2-9b83-4ea5-99cc-99e5840e1e10" width="425"/> 
</p>

# How to run
To run this project you need to:
- rename "_ticketmaster-info.plist" to "ticketmaster-info.plist",
- insert your API key from: [API](https://developer.ticketmaster.com/products-and-docs/apis/getting-started/) in this file as API_KEY value.
