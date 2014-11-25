FORMAT: 1A
HOST: https://www.cine.io/api/1/-/

# cine.io API

Cine.io is an API-driven live video-streaming platform. Developers can quickly
setup a live streaming app using our global live streaming CDN. Cine.io was
designed for immediate usage, getting you setup in your own app in just a few
minutes.

## Getting Started

Start off by creating an account at [cine.io](https://www.cine.io) or through
the heroku addon marketplace. We will automatically create you a project with
a default name of "Development". You can change your project names at any
time. You can create as many projects as you like. Each project will provide
you with a unique "Public key" and a "Secret key". A common usage is to create
a different project for your Development and Production environment (perhaps
also staging, canary environments, etc.).

Now you have your account `masterKey` as well as your project `publicKey` and
`secretKey`. Let's review a typical life cycle.

## Common Request Life Cycle

1. Create a live stream
2. Publish a live stream
3. Play a live stream

### Create a live stream

Every project starts off with 1 live stream. Most likely you'll want to have
more than 1 unique live stream.

Requests normally start off by *creating a live stream*. This live stream is
unique to your project. You'll get a response back containing a few fields.
The most important fields to save in your database is `id`, and `password`.
You'll need these fields to play and publish your live stream. You can always
fetch the other fields again by issuing a get request to the `stream/show`
endpoint.

Look at the API docs for [POST /stream](#stream-stream-post) to learn how to
create a stream.

### Publish a live stream

Now you've saved your stream `id` and stream `password`. Using the [JS
SDK](https://github.com/cine-io/js-sdk), you'll need to pass you project's
`publicKey` to the client. If your specific user has permission in your
application to publish to this stream, then you'll need to send along the
stream `id` and stream `password` to your web client. For example, this
endpoint would be useful if you are building a "virtual classroom" and the
current logged-in user has a "teacher" role.

Publishing a live-stream requires that the logged-in user have Adobe Flash
installed and enabled in her browser. The JS SDK will automatically download
the correct SWF file and launch it in the user's browser when `start()` is
called on the publisher.

```javascript
var streamId = '<STREAM_ID>'
  , password = '<STREAM_PASSWORD'
  , domId = 'publisher-example';

var publisher = CineIO.publish(
  streamId, password, domId
);

publisher.start();
```


### Play a live stream

Using the [JS SDK](https://github.com/cine-io/js-sdk), you'll need to pass you
project's *public key* to the client. To play a stream using the JS SDK, you
only need to send out the stream `id`. Only serve the stream `id` to users who
have permission to view a stream. For example, in our aforementioned "virtual
classroom" application, this endpoint would be useful when the current logged-
in user has a "student" role.

Playing a live stream will launch the branded, open-source version of
[JWPlayer](http://www.jwplayer.com/). If you have your own JWPlayer license,
you can send it as one of the options (key: `jwPlayerKey`) to the `init()`
function. Mobile devices will use native `<video>` elements rather than
JWPlayer; this happens automatically.

```javascript
var streamId = '<STREAM_ID>'
  , domId = 'player-example';

CineIO.play(streamId, domId);
```


## Resources

The cine.io API is comprised of three main resource types:

- Project: a project has one or more associated streams
- Stream: a stream contains all of the data necessary to publish and consume live video
- Recording: streams support the ability to be recorded


# Group Project

Each account can have one or more associated projects. A project has one or
more associated streams. The project resource exists for the convenience of
organizing your streams.

## Projects [/projects]

### Get Projects [GET]

Return a list of all projects associated with the passed-in account `masterKey`.

##### Example
```bash
curl -X GET "https://www.cine.io/api/1/-/projects?masterKey=ACCOUNT_MASTER_KEY"
```

+ Parameters

    + masterKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `masterKey` associated with the account

+ Response 200 (application/json)

    + Body

        [
           {
              "streamsCount" : 3,
              "updatedAt" : "2014-08-22T02:29:23.552Z",
              "name" : "My Project",
              "id" : "abcd1234abcd1234abcd1234abcd1234",
              "publicKey" : "abcd1234abcd1234abcd1234abcd1234",
              "secretKey" : "abcd1234abcd1234abcd1234abcd1234"
           }
        ]

## Project [/project]

### Get Project [GET]

Return the full information for the project associated with the passed-in
project `secretKey`.

##### Example
```bash
curl -X GET "https://www.cine.io/api/1/-/project?secretKey=PROJECT_SECRET_KEY"
```

+ Parameters

    + secretKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `secretKey` associated with the project

+ Response 200 (application/json)

    + Body

       {
          "streamsCount" : 3,
          "updatedAt" : "2014-08-22T02:29:23.552Z",
          "name" : "My Project",
          "id" : "abcd1234abcd1234abcd1234abcd1234",
          "publicKey" : "abcd1234abcd1234abcd1234abcd1234",
          "secretKey" : "abcd1234abcd1234abcd1234abcd1234"
       }


# Group Stream

## Streams [/streams]

### Get Streams [GET]

Return the list of streams associated with the passed-in project `secretKey`.

##### Example
```bash
curl -X GET "https://www.cine.io/api/1/-/streams?secretKey=PROJECT_SECRET_KEY"
```

+ Parameters

    + secretKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `secretKey` associated with the project
    + name (optional, string `abc123`) ... Return only streams with the supplied `name`.

+ Response 200 (application/json)

    + Body

        [
           {
              "name" : "Stream 1",
              "play" : {
                 "rtmp" : "rtmp://fml.cine.io/20C45E/cines/abc123",
                 "hls" : "http://hls.cine.io/PUBLIC_KEY/abc123.m3u8"
              },
              "publish" : {
                 "stream" : "abc123?pass",
                 "url" : "rtmp://publish-sfo.cine.io/live"
              },
              "password" : "pass",
              "record" : true,
              "expiration" : "2034-08-16T00:00:00.000Z",
              "assignedAt" : "2014-08-18T19:38:05.076Z",
              "id" : "abcd1234abcd1234abcd1234",
              "streamName" : "abc123"
           },
           {
              "name" : "Stream 2",
              "play" : {
                 "rtmp" : "rtmp://fml.cine.io/20C45E/cines/zyx987",
                 "hls" : "http://hls.cine.io/cines/zyx987/zyx987.m3u8"
              },
              "publish" : {
                 "stream" : "zyx987?pass&amp",
                 "url" : "rtmp://publish-sfo.cine.io/live"
              },
              "password" : "pass",
              "record" : true,
              "expiration" : "2034-05-21T00:00:00.000Z",
              "assignedAt" : "2014-06-02T23:22:32.928Z",
              "id" : "abcd1234abcd1234abcd1234",
              "streamName" : "zyx987"
           }
        ]

## Stream [/stream]

### Get Stream [GET]

Get detailed information about a particular stream

##### Example
```bash
curl -X GET "https://www.cine.io/api/1/-/stream?secretKey=PROJECT_SECRET_KEY&id=STREAM_ID"
```

+ Parameters

    + secretKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `secretKey` associated with the project
    + id (required, string `abcd1234abcd1234abcd1234`) ... The `id` associated with the given stream

+ Response 200 (application/json)

    + Body

        {
           "name" : "my stream name",
           "play" : {
              "rtmp" : "rtmp://fml.cine.io/20C45E/cines/abc123",
              "hls" : "http://hls.cine.io/PUBLIC_KEY/abc123.m3u8"
           },
           "publish" : {
              "stream" : "abc123?pass",
              "url" : "rtmp://publish-sfo.cine.io/live"
           },
           "password" : "pass",
           "record" : true,
           "expiration" : "2034-08-22T00:00:00.000Z",
           "assignedAt" : "2014-08-22T23:54:21.453Z",
           "id" : "abcd1234abcd1234abcd1234",
           "streamName" : "abc123"
        }


### Create Stream [POST]

Return the list of streams associated with the passed-in project `secretKey`.

##### Example
```bash
curl -X POST \
     --data "secretKey=abcd1234abcd1234abcd1234abcd1234&name=my+stream+name&record=true" \
     "https://www.cine.io/api/1/-/stream"
```

+ Parameters

    + secretKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `secretKey` associated with the project
    + name (optional, string `my stream name`) ... Any text to help you identify your stream
    + record (optional, boolean `true`) ... Whether or not you want to record your stream

+ Response 200 (application/json)

    + Body

        {
           "name" : "my stream name",
           "play" : {
              "rtmp" : "rtmp://fml.cine.io/20C45E/cines/abc123",
              "hls" : "http://hls.cine.io/PUBLIC_KEY/abc123.m3u8"
           },
           "publish" : {
              "stream" : "abc123?pass",
              "url" : "rtmp://publish-sfo.cine.io/live"
           },
           "password" : "pass",
           "record" : true,
           "expiration" : "2034-08-22T00:00:00.000Z",
           "assignedAt" : "2014-08-22T23:54:21.453Z",
           "id" : "abcd1234abcd1234abcd1234",
           "streamName" : "abc123"
        }

### Update Stream [PUT]

Update the information about a given stream.

##### Example
```bash
curl -X PUT \
     --data "secretKey=abcd1234abcd1234abcd1234abcd1234&name=my+new+stream+name&record=false" \
     "https://www.cine.io/api/1/-/stream"
```

+ Parameters

    + secretKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `secretKey` associated with the project
    + id (required, string `abcd1234abcd1234abcd1234`) ... The `id` associated with the given stream
    + name (optional, string `my stream name`) ... Any text to help you identify your stream
    + record (optional, boolean `true`) ... Whether or not you want to record your stream

+ Response 200 (application/json)

    + Body

        {
           "name" : "my new stream name",
           "play" : {
              "rtmp" : "rtmp://fml.cine.io/20C45E/cines/abc123",
              "hls" : "http://hls.cine.io/PUBLIC_KEY/abc123.m3u8"
           },
           "publish" : {
              "stream" : "abc123?pass",
              "url" : "rtmp://publish-sfo.cine.io/live"
           },
           "password" : "pass",
           "record" : false,
           "expiration" : "2034-08-22T00:00:00.000Z",
           "assignedAt" : "2014-08-22T23:54:21.453Z",
           "id" : "abcd1234abcd1234abcd1234",
           "streamName" : "abc123"
        }


### Delete Stream [DELETE]

Delete a stream.

##### Example
```bash
curl -X DELETE "https://www.cine.io/api/1/-/stream?secretKey=PROJECT_SECRET_KEY&id=STREAM_ID"
```

+ Parameters

    + secretKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `secretKey` associated with the project
    + id (required, string `abcd1234abcd1234abcd1234`) ... The `id` associated with the given stream

+ Response 200 (application/json)

    + Body

        {
           "updatedAt" : "2014-08-23T00:14:19.531Z",
           "deletedAt" : "2014-08-23T00:14:19.526Z",
           "name" : "my stream",
           "id" : "abcd1234abcd1234abcd1234"
        }

# Group Recording

## Recordings [/stream/recordings]

### Get Recordings for a Stream [GET]

Get the list of recordings associated with a stream.

##### Example
```bash
curl -X GET "https://www.cine.io/api/1/-/stream/recordings?publicKey=PROJECT_PUBLIC_KEY&id=STREAM_ID"
```

+ Parameters

    + publicKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `publicKey` associated with the project
    + id (required, string `abcd1234abcd1234abcd1234`) ... The `id` associated with the given stream

+ Response 200 (application/json)

    + Body

        [
           {
              "date" : "2014-08-18T21:45:00.000Z",
              "url" : "http://vod.cine.io/cines/abcd1234abcd1234abcd1234abcd1234/abc123.mp4",
              "name" : "abc123.mp4",
              "size" : 202623953
           }
        ]

## Recording [/stream/recording]

### Delete a Recording [DELETE]

Delete one of the recordings associated with a stream.

##### Example
```bash
curl -X DELETE "https://www.cine.io/api/1/-/stream/recording?secretKey=PROJECT_SECRET_KEY&id=STREAM_ID&name=RECORDING_NAME"
```

+ Parameters

    + secretKey (required, string `abcd1234abcd1234abcd1234abcd1234`) ... The `secretKey` associated with the project
    + id (required, string `abcd1234abcd1234abcd1234`) ... The `id` associated with the given stream
    + name (required, string `abc123`) ... The `name` of the recording

+ Response 200 (application/json)

    + Body

        {
           "deletedAt" : "2014-08-23T00:24:20.402Z"
        }
