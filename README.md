# Intra 42
![Release](https://img.shields.io/github/release/femaury/Intra_42.svg)
![License](https://img.shields.io/github/license/femaury/Intra_42.svg?color=green)
![Top Language](https://img.shields.io/github/languages/top/femaury/Intra_42.svg)
![Platform](https://img.shields.io/badge/platform-iOS%2011.0%2B-green.svg)

<img src="https://github.com/femaury/intra_42/raw/master/Screenshots/intra_42_main_screens_white.png"
     title="Intra 42 by Felix Maury" width="800">
     
### Swift app for 42's intranet

This is a swift learning project for myself. I started it to give native access to the intranet to 42's iOS users, as there were no such apps on the App Store. I plan on publishing it for free.  
Feel free to create issues or pull requests to contribute!  

#### Known issues [Live Build]

- [The number label for E1R7P1 says 7 instead of 1 after changing clusters.](https://github.com/femaury/intra_42/issues/2)
- [Negative content inset when refreshing a tableview with a search controller imbeded in the navbar.](https://github.com/femaury/intra_42/issues/3)

## Contributing
To run the app, you will first need to [create an app for 42's api](https://profile.intra.42.fr/oauth/applications/new) with the following redirection URI: `com.femaury.swifty://oauth2callback`. Then use the keys your are given inside `Intra42/APIManager/API42Manager.swift`:
```
    let clientId = "YOUR_42_API_APP_UID"
    let clientSecret = "YOUR_42_API_APP_SECRET"
```
You will also need to install [SwiftLint](https://github.com/realm/SwiftLint).

## TODO
<ul>
  <li>Get unlimited official API key</li>
  <li>Comment/Document source code</li>
  <li>Better looking achievement cells</li>
  <li>Create cluster maps for other campuses</li>
  <li>Feel free to pitch in!</li>
</ul>

## Current Features
  <details><summary>Your Profile</summary>
    <ul>
      <li>Full Name</li>
      <li>Username</li>
      <li>Campus</li>
      <li>Piscine Year</li>
      <li>Picture</li>
      <li>Location</li>
      <li>Wallets</li>
      <li>Correction Points</li>
      <li>Level</li>
      <li>Cursus</li>
      <li>Graded Projects</li>
      <li>Previous log locations and dates (with duration)</li>
      <li>Achievements</li>
    </ul>
  </details>
  <details><summary>Corrections</summary>
    <ul>
      <li>Your upcoming corrections</li>
      <li>Corrector</li>
      <li>Correctee</li>
    </ul>
  </details>
  <details><summary>Events</summary>
    <ul>
      <li>All Future Events</li>
      <li>Your Events</li>
      <li>Searchable by kind and name</li>
      <li>Possibility to add events to calendar</li>
    </ul>
  </details>
  <details><summary>Cluster Map</summary>
    <ul>
      <li>Zoomable map of all 3 Paris Clusters (a la Stud42)</li>
      <li>Info on how many people per cluster (x/271)</li>
      <li>Info on how many friends per cluster</li>
      <li>All connected user profiles can be shown</li>
    </ul>
  </details>
  <details><summary>Friends List</summary>
    <ul>
      <li>List of all your friends with current locations</li>
      <li>Current campus and login time</li>
    </ul>
  </details>
  <details><summary>Student Search</summary>
    <ul>
      <li>Search students of all campuses by username, first name and last name</li>
      <li>Shows students logins and pictures, with detailed profile on tap</li>
      <li>Possibility to add students to friends list directly from results page</li>
    </ul>
  </details>
  <details><summary>All Achievements</summary>
    <ul>
      <li>Searchable by tier and name</li>
      <li>Your achievements are highlighted</li>
    </ul>
  </details>
  <details><summary>About</summary>
  <ul>
  <li>Little description of the project and myself</li>
  <li>Links for third party libraries used</li>
  </ul>
  </details>
  <details><summary>Settings</summary>
  <ul>
  <li>Possibility to change app icon</li>
  <li>Possibility to change primary color</li>
  </ul>
  </details>
  <details><summary>Coalition Rankings</summary>
  <ul>
  <li>All coalitions ranked by score</li>
  </ul>
  </details>
  <details><summary>Projects (Holy Graph)</summary>
  <ul>
  <li>Holy Graph with clickable projects.</li>
  <li>List of user cursus to display</li>
  </ul>
  </details>
  <details><summary>Forums</summary>
  <ul>
  <li>Link to Stackoverflow 42 forums</li>
  </ul>
  </details>
  <details><summary>Peer finder</summary>
  <ul>
  <li>Search refined by campus, cursus, project and user status</li>
  <li>Lists are searchable</li>
  <li>Shows online users first, and always ordered by project grade</li>
  </ul>
  </details>
  
  ## Contact Me
  
 You can send me a mail at femaury@student.42.fr or find me on 42's slack as 'femaury' 😉
