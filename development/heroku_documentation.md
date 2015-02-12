[cine.io](http://addons.heroku.com/cine) is an [add-on](http://addons.heroku.com) that provides live streaming capabilities to any application.

cine.io allows developers to build live video-streaming capabilities into their apps with ease. Streaming can happen from any device to any web browser, iOS device, or Android device. All live-streams are backed by a global CDN with 5,000 interconnected networks across 5 continents.

cine.io is accessible via a simple RESTful API and has supported client libraries for both Node.js and Ruby (with iOS and Android coming soon).

## Provisioning the add-on

cine.io can be attached to a Heroku application via the CLI:

> callout
> A list of all plans available can be found [here](http://addons.heroku.com/cine).

```term
$ heroku addons:add cine
-----> Adding cine to sharp-mountain-4005... done, v18 (free)
```

Once cine.io has been added, the `CINE_IO_PUBLIC_KEY` and `CINE_IO_SECRET_KEY` setting will be available in the app configuration and will contain the public and secret keys necessary to create, publish, and play back live streams. This can be confirmed using the `heroku config:get` command:

```term
$ heroku config:get CINE_IO_PUBLIC_KEY
http://user:pass@instance.ip/resourceid
```

After installing cine.io the application should be configured to fully integrate with the add-on.

## Local setup

### Environment setup

After provisioning the add-on it’s necessary to locally replicate the config vars so your development environment can operate against the service.

> callout
> Though less portable it’s also possible to set local environment variables using `export CINE_IO_PUBLIC_KEY=value` and `export CINE_IO_SECRET_KEY=value`.

Use [Foreman](config-vars#local-setup) to configure, run and manage process types specified in your app’s [Procfile](procfile). Foreman reads configuration variables from an .env file. Use the following command to add the CINE_IO values retrieved from heroku config to `.env`.

```term
$ heroku config -s | grep CINE_IO >> .env
$ more .env
```

> warning
> Credentials and other sensitive configuration values should not be committed to source-control. In Git exclude the .env file with: `echo .env >> .gitignore`.


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

Look at the API docs for [POST /stream](http://developer.cine.io/broadcast#stream-stream-post) to learn how to
create a stream.

### Publish a live stream

Now you've saved your stream `id` and stream `password`. Using the [Broadcast JS SDK](https://github.com/cine-io/broadcast-js-sdk), you'll need to pass you project's
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

Using the [Broadcast JS SDK](https://github.com/cine-io/broadcast-js-sdk), you'll need to pass you
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


## Additional API endpoints

Additional API endpoints may be found at: [http://developer.cine.io](http://developer.cine.io).

## Using with Rails

>callout
>We’ve built a small Ruby Sinatra broadcast example.
> [Source code](https://github.com/cine-io/cineio-broadcast-sinatra-example-app) or
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/cine-io/cineio-broadcast-sinatra-example-app)


### Integrate with your Ruby app

Ruby on Rails applications may to add the following entry into their `Gemfile` specifying the cine.io client library.

```ruby
gem 'cine_io'
```

Update application dependencies with bundler.

```term
$ bundle install
```

Initialize the client.

```ruby
require('cine_io')
client = CineIo::Client.new(secretKey: ENV['CINE_IO_SECRET_KEY'])
```

Additional examples can be found at the [repository's homepage](https://github.com/cine-io/cineio-ruby).

## Using with Node.js

>callout
>We’ve built a small Node.js Express broadcast example.
> [Source code](https://github.com/cine-io/cineio-broadcast-node-example-app) or
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/cine-io/cineio-broadcast-node-example-app)

### Integrate with your Node app

The npm package may be installed with the following command.

```term
npm install --save cine-io
```

Initialize the client.

```javascript
var CineIO = require('cine-io');
var client = CineIO.init({secretKey: process.env.CINE_IO_SECRET_KEY});
```

Additional examples can be found at the [repository's homepage](https://github.com/cine-io/cineio-node).

## Using with Python

The python egg may be installed with the following command.

```term
pip install cine_io
```

Initialize the client.

```javascript
import cine_io
client = cine_io.Client({"secretKey": "CINE_IO_SECRET_KEY"})
```

Additional examples can be found at the [repository's homepage](https://github.com/cine-io/cineio-python).

## Dashboard

> callout
> For more information on the features available within the cine.io dashboard please see the docs at [http://developer.cine.io](http://developer.cine.io).

The cine.io dashboard allows you to manage all your projects, create live streams, monitor bandwidth, and see example code.

The dashboard can be accessed via the CLI:

```term
$ heroku addons:open cine
Opening cine for sharp-mountain-4005…
```

or by visiting the [Heroku apps web interface](http://heroku.com/myapps) and selecting the application in question. Select cine.io from the Add-ons menu.

## Troubleshooting

If you cannot create a live stream. Ensure you are using your CINE_IO_SECRET_KEY instead of your CINE_IO_PUBLIC_KEY.

## Migrating between plans

You can migrate your plan at any time. Carefully monitor your bandwidth to ensure you're usage fits with the appropriate plan.

Use the `heroku addons:upgrade` command to migrate to a new plan.

```term
$ heroku addons:upgrade cine:solo
-----> Upgrading cine:solo to sharp-mountain-4005... done, v18 ($20/mo)
       Your plan has been updated to: cine:solo
```

## Removing the add-on

cine.io can be removed via the  CLI.

> warning
> This will destroy all associated data and cannot be undone!

```term
$ heroku addons:remove cine
-----> Removing cine from sharp-mountain-4005... done, v20 (free)
```

Before removing cine.io, you may export all your data via the get commands of projects and streams.

## Support

All cine.io support and runtime issues should be submitted via on of the [Heroku Support channels](support-channels). Any non-support related issues or product feedback is welcome at [http://support.cine.io/](http://support.cine.io/).
