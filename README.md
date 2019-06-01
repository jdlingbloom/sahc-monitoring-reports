# SAHC Monitoring Reports

A web application for organizing land trust monitoring photos and generating reports. Built for [Southern Appalachian Highlands Conservancy](https://appalachian.org) (SAHC), but can be used by other organizations.

## Features

* Upload and process photos in JPEG or KMZ formats.
* Automatically extracts metadata information from the photos, if available (time the photo was taken, latitude, longitude, altitude, and direction).
* Generates PDF reports for gathering signatures.
* Free to run your own version of this application.
* Sign in with your Google Account.
  * This means your users will need a Google Account tied to the e-mail address they wish to login with. Note that you can [create a Google Account without Gmail](https://accounts.google.com/SignUpWithoutGmail), so you can create Google Accounts tied to your work email addresses if desired.

## Screenshots

<a href="/docs/screenshots/login.png?raw=true" style="float: left;"><img src="/docs/screenshots/login_thumbnail.png?raw=true" width="260" alt="Login page"></a>
<a href="/docs/screenshots/list.png?raw=true" style="float: left;"><img src="/docs/screenshots/list_thumbnail.png?raw=true" width="260" alt="Listing page"></a>
<a href="/docs/screenshots/new.png?raw=true" style="float: left;"><img src="/docs/screenshots/new_thumbnail.png?raw=true" width="260" alt="New report page"></a>
<a href="/docs/screenshots/show.png?raw=true" style="float: left;"><img src="/docs/screenshots/show_thumbnail.png?raw=true" width="260" alt="Show report page"></a>
<a href="/docs/screenshots/edit.png?raw=true" style="float: left;"><img src="/docs/screenshots/edit_thumbnail.png?raw=true" width="260" alt="Edit report page"></a>
<a href="/docs/screenshots/pdf.png?raw=true" style="float: left;"><img src="/docs/screenshots/pdf_thumbnail.png?raw=true" width="260" alt="PDF report"></a>

## Deployment

If you'd like to run your own version of this application, you can do so for free on [Heroku](https://www.heroku.com). The free version of Heroku has limits the database size, but it should be enough to hold several hundred reports (depending on the number of photos). In order to deploy to Heroku:

1. Obtain credentials for configuring Google Sign-In.
  1. Create a new project at the [Google API Console](https://console.developers.google.com/project) (this will require a Google Account for whoever is performing this deployment. If you don't already have a Google Account, you can [create a Google Account without Gmail](https://accounts.google.com/SignUpWithoutGmail)).
  1. Click the top-left menu icon, and then choose "APIs & Services" and then pick "Credentials".
  1. Click on the "OAuth consent screen", enter an "Application name" and then click "Save" (the name could be the name of your organization).
  1. Back on the "Credentials" tab, click the "Create credentials" button and from the menu choose "OAuth client ID".
  1. For the "Application type" choose "Web application" and for the "Name" enter "Report Monitoring Application". Leave the other fields blank for now, and press the "Create" button.
  1. Copy the "Client ID" and "Client Secret" displayed to you, since you'll need these 2 items for the next step.
1. Deploy to Heroku.
  1. Click this button to begin the process of deploying this application to Heroku: [![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/GUI/sahc-monitoring-reports)
