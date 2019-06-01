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
    1. If you don't have a Heroku account, you can create one for free. Or you can sign into your existing Heroku account.
    1. Once on the "Create New App" page, enter an "App name". This name will be used for accessing your application at https://[YOUR-APP-NAME-HERE].herokuapp.com
    1. Under "Config Vars" make the following changes (the rest of the values can be left alone):
        1. Enter either `ALLOWED_EMAIL_ADDRESSES` or `ALLOWED_EMAIL_DOMAIN` to determine who should be allowed to login to your application.
        1. For `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`, enter the "Client ID" and "Client Secret" values you got in the previous step. If you didn't copy these down during the previous step, you can always find it again in your [Google API Console](https://console.developers.google.com/apis/credentials)
        1. For `ORGANIZATION_NAME`, enter the name of your organization you'd like to show up in the application.
        1. Adjust the `TIME_ZONE` if your organization is not in the Eastern US time zone.
    1. Press the "Deploy app" button. This may take a few minutes to complete.
    1. After the deployment finishes, click on the "Manage App" button.
    1. Click the "Heroku Scheduler" link under the "Installed add-ons" section.
        1. Click the "Create job" button.
        1. Under "Schedule" pick "Every day at..." (12AM, or anytime is fine).
        1. Under "Run Command" enter `rake carrierwave:clean_cached_files`
        1. Press "Save Job"
    1. Navigate back to the [dashboard](https://dashboard.heroku.com/) and to your application.
    1. Click the "Configure Dynos" link next to the "Dyno formation" section.
        1. Click the edit pencil icon next to the "worker" dyno, and then click the toggle switch to enable this option.
        1. Press the "Confirm" button to save.
    1. Click the "Open App" button in the top-right corner. You should end up at https://[YOUR-APP-NAME-HERE].herokuapp.com with a login page. However, before logging in, you'll need complete some additional configuration with Google:
1. Finalize the Google Sign-In configuration.
    1. Navigate back to the Credentials section of the [Google API Console](https://console.developers.google.com/apis/credentials).
    1. Under "OAuth 2.0 client IDs" click on the credentials you previously created.
    1. Under the "Authorized redirect URIs" enter: `https://[YOUR-APP-NAME-HERE].herokuapp.com/users/auth/google_oauth2/callback` (substituting `[YOUR-APP-NAME-HERE]` with whatever Heroku name you ended up using).
    1. Press "Save."
1. Navigate back to https://[YOUR-APP-NAME-HERE].herokuapp.com. You should now be able to login with any allowed Google Accounts and start using the tool. 🚀
