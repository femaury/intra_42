# Intra 42
![Release](https://img.shields.io/github/release/femaury/Intra_42.svg)
![License](https://img.shields.io/github/license/femaury/Intra_42.svg?color=green)
![Top Language](https://img.shields.io/github/languages/top/femaury/Intra_42.svg)
![Platform](https://img.shields.io/badge/platform-iOS%2011.0%2B-green.svg)

<img src="https://github.com/femaury/intra_42/raw/master/Screenshots/intra_42_main_screens_white.jpg"
     title="Intra 42 by Felix Maury" width="800">
     
### Swift app for 42's intranet

<br/>:warning: WORK IN PROGRESS :warning: <br/>
This is a swift learning project for myself. <br/>
I plan on publishing it for free on the App Store. <br/>
Feel free to create issues or pull requests to contribute!

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
  <li>Projects Info / List</li>
  <li>Holy Graph</li>
  <li>Forums</li>
  <li>Videos</li>
  <li>Dark mode</li>
  <li>Better looking achievement cells</li>
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
      <li>Cursuses</li>
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
      <li>Possibility for direct call/text/email to all your friends</li>
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
  
  ## Contact Me
  
 You can send me a mail at femaury@student.42.fr or find me on 42's slack as 'femaury' 😉
