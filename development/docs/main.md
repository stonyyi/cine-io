# Documentation for [cine.io](https://www.cine.io) API.

## About cine.io

Cine.io is an api driven live streaming platform. Developers can quickly setup a live streaming app using our global live streaming cdn. Cine.io was designed for immediate usage, getting you setup in your own app in just a few minutes.

## Getting started

Start off by creating an account at [cine.io](https://www.cine.io) or through the heroku addon marketplace. We will automatically create you a project with a default name of "Development". You can change your project names at any time. You can create as many projects as you like. Each project will provide you with a unique "Public key" and a "Secret key". A common usage is to create a different project for your Development and Production environment (perhaps also staging, canary environments, etc.).

Now you have your public and secret keys, let's review a typical life cycle.

## Common request life cycle

### 1. Create a live stream
*Location: Web Server*

Every project starts off with 1 live stream. Most likely you'll want to have more than 1 unique live stream.

Requests normally start off by *creating a live stream*. This live stream is unique to your project. You'll get a response back containing a few fields. The most important fields to save in your database is `id`, and `password`. You'll need these fields to play and publish your live stream. You can always fetch the other fields again by issuing a get request to the stream/show endpoint.

End point:

* method: POST
* url: /api/1/-/stream
* response format: JSON
* parameters:
  * secretKey: CINE_IO_SECRET_KEY
  * name (optional): any text to help you identify your stream

Example: `curl -X POST --data "secretKey=MY_SECRET_KEY&name=first%20stream" https://www.cine.io/api/1/-/stream --header "Content-Type:application/json"`

### 2. Publish a live stream
*Location: Web Client*

Now you've saved your stream `id` and stream `password`. Using the [JS SDK](https://github.com/cine-io/js-sdk), you'll need to pass you project's *public key* to the client. If your specific user has permission in your application to publish to this stream, then you'll need to send along the stream `id` and stream `password` to your web client. For example, this endpoint would be useful if you are building a "virtual classroom" and the current logged-in user has a "teacher" role.

Publishing a live-stream requires that the logged-in user have Adobe Flash installed and enabled in her browser. The JS SDK will automatically download the correct SWF file and launch it in the user's browser when `start()` is called on the publisher.

Example:

```javascript
var streamId = '<STREAM_ID>'
  , password = '<STREAM_PASSWORD'
  , domId = 'publisher-example';

var publisher = CineIO.publish(
  streamId, password, domId
);

publisher.start();
```

### 3. Play a live stream
*Location: Web Client*

Using the [JS SDK](https://github.com/cine-io/js-sdk), you'll need to pass you project's *public key* to the client. To play a stream using the JS SDK, you only need to send out the stream `id`. Only serve the stream `id` to users who have permission to view a stream. For example, in our aforementioned "virtual classroom" application, this endpoint would be useful when the current logged-in user has a "student" role.

Playing a live stream will launch the branded, open-source version of [JWPlayer](http://www.jwplayer.com/). If you have your own JWPlayer license, you can send it as one of the options (key: `jwPlayerKey`) to the `init()` function. Mobile devices will use native `<video>` elements rather than JWPlayer; this happens automatically.

Example:

```javascript
var streamId = '<STREAM_ID>'
  , domId = 'player-example';

CineIO.play(streamId, domId);
```

## Additional end points

### Get a live stream
*Location: Web Server*

After you have created a live stream you can always fetch the information again. This will return the same fields as the create endpoint.

End point:

* method: GET
* url: /api/1/-/stream
* response format: JSON
* parameters:
 * secretKey: CINE_IO_SECRET_KEY
 * id: stream id

Example: `curl "https://www.cine.io/api/1/-/stream?secretKey=MY_SECRET_KEY&id=streamId" --header "Content-Type:application/json"`

### Get all of your streams
*Location: Web Server*

You can fetch all of your streams via an api endpoint. Currently pagination is not supported.

End point:

* method: GET
* url: /api/1/-/streams
* response format: JSON
* parameters:
 * secretKey: CINE_IO_SECRET_KEY

Example: `curl https://www.cine.io/api/1/-/streams?secretKey=MY_SECRET_KEY --header "Content-Type:application/json"`

### Update a live stream
*Location: Web Server*

This will update the stream details. Currently only `name` is supported.

End point:

* method: PUT
* url: /api/1/-/stream
* response format: JSON
* parameters:
 * secretKey: CINE_IO_SECRET_KEY
 * id: stream id
 * name: any text to help you identify your stream

Example: `curl -X PUT "https://www.cine.io/api/1/-/stream?secretKey=MY_SECRET_KEY&id=streamId&name=new%20name" --header "Content-Type:application/json"`

### Delete a live stream
*Location: Web Server*

This will delete the stream. Publishing and playing will no longer be available.

End point:

* method: DELETE
* url: /api/1/-/stream
* response format: JSON
* parameters:
 * secretKey: CINE_IO_SECRET_KEY
 * id: stream id

Example: `curl -X DELETE "https://www.cine.io/api/1/-/stream?secretKey=MY_SECRET_KEY&id=streamId" --header "Content-Type:application/json"`

### Get the project details
*Location: Web Server*

You can fetch your project details via api.

End point:

* method: GET
* url: /api/1/-/project
* response format: JSON
* parameters:
 * secretKey: CINE_IO_SECRET_KEY

Example: `curl https://www.cine.io/api/1/-/project?secretKey=MY_SECRET_KEY --header "Content-Type:application/json"`

### Update the project
*Location: Web Server*

This will update the project details. Currently only `name` is supported.

End point:

* method: PUT
* url: /api/1/-/project
* response format: JSON
* parameters:
 * secretKey: CINE_IO_SECRET_KEY
 * name: a new project name string

Example: `curl -X PUT https://www.cine.io/api/1/-/project?secretKey=MY_SECRET_KEY&name=new%20name --header "Content-Type:application/json"`

### Delete the project
*Location: Web Server*

This will delete the entire project. Publishing and playing to all associated streams will no longer be available.

End point:

* method: DELETE
* url: /api/1/-/project
* response format: JSON
* parameters:
 * secretKey: CINE_IO_SECRET_KEY

Example: `curl -X DELETE https://www.cine.io/api/1/-/project?secretKey=MY_SECRET_KEY --header "Content-Type:application/json"`

### health
*Location: Web Server*

This is a simple API health check.

End point:

* method: GET
* response format: JSON
* url: /api/1/-/health

Example: `curl https://www.cine.io/api/1/-/health --header "Content-Type:application/json"`
