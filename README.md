# How do I run this project

This project assumes you are using yarn, but npm should work fine too.

- Install Elm - [https://guide.elm-lang.org/install.html](https://guide.elm-lang.org/install.html)
- Install parcel.js - `yarn global add parcel-bundler` [https://parceljs.org/getting_started.html](https://parceljs.org/getting_started.html)
- Install and run the project: `yarn install && yarn run start`
- open [http://localhost:3000](http://localhost:3000) and you'll find the app.

# The data files are on the file system. How do I can change them.

For simplicity of this demo, they are bundled into the js. In production, these should be served from somewhere.

At this time, the following 2 options will update the files

- put new files on the file system, then change the imports `./src/index.js`
- just overwrite the data in the existing files

# What if I want to deploy this to a server?

1. run build `yarn install && yarn run build`
2. copy the dist folder to you favorite file server or object store.
3. To enable CORS, the services in this project should be proxied. Looks like Richmond hasn't enabled CORS.

# Background

Enrich 911 emergency incident data to provide better analytics for a fire department.

## Task

Given an incident data, enrich it and then display the location and data on a map for easy validation.

## Enrichments

- Weather at the time of the incident (use a weather service of your choice).
- Parcel data at the location of the incident. Note that a Parcel is a polygon with attributes such as: `OwnerName, MailAddress, LandValue, LandSqFt, ...`. Use this existing service which belongs to the city of Richmond, VA: http://gis.richmondgov.com/ArcGIS/rest/services/StatePlane4502/Ener/MapServer/0/

Note that the "Query" link at the bottom of the page allow you to search for parcels. The Query page has a link to an API Reference documentation link which you should use for help. The incident has a point as "longitude" and "latitude" properties (which corresponds to `"spatialReference" : {"wkid" : 4326}`).

- Optional: If you have extra time or want to go the extra mile, are there additional attributes that would be helpful for the department to know?

## Notes

- Example incidents are provided in the data folder.
- We will test the project with an arbitrary incident file that is also from Richmond, VA and in the same format.
- It would be sufficient for the app to only handle one CAD file at a time.
- The incident location and attributes should be displayed on a map in the browser.
- You can enrich the incident and get it on a map however you wish.
- We would like for you to spend up to 4 hours. It is okay if you spend less time or more time so long as you have a working app.
- Use technology stack of your choice.

## Deliverable

- Link to a Github repository with your commits as you originally made them. Do not squash them or just have a single commit.
- There should be a README in the repo with:
  - steps to install and run your app
  - did you complete the project? comment as needed.
  - how much time did you spend on the project?
  - Add a couple of screen shots to the repo that show the working version as running on your machine.
- Assume the user will be on OSX but if you do not have access to OSX machine, provide needed steps to run your app on any other OS.
