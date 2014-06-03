[cine.io](http://addons.heroku.com/cine) is an [add-on](http://addons.heroku.com) for providing live streaming functionality.

Adding global live streaming functionality to an application provides benefits X, Y and Z. [[Sell the benefits here! Don't skimp - developers have many options these days.]]

cine.io is accessible via an API and has supported client libraries for [[Java|Ruby|Python|Node.js|Clojure|Scala]]*.

## Provisioning the add-on

cine.io can be attached to a Heroku application via the  CLI:

> callout
> A list of all plans available can be found [here](http://addons.heroku.com/cine).

```term
$ heroku addons:add cine
-----> Adding cine to sharp-mountain-4005... done, v18 (free)
```

Once cine.io has been added a `CINE_IO_PUBLIC_KEY` and a `CINE_IO_SECRET_KEY` setting will be available in the app configuration and will contain the public and secret keys necessary to create and play live streams. This can be confirmed using the `heroku config:get` command.

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

## Common request life cycle

### 1. Create a live stream
*Location: Web Server*

Every project starts off with 1 live stream. Most likely you'll want to have more than 1 unique live stream.

Requests normally start off by *creating a live stream*. This live stream is unique to your project. You'll get a response back containing a few fields. The most important fields to save in your database is *id*, and *password*. You'll need these fields to play and publish your live stream. You can always fetch the other fields again by issuing a get request to the stream/show endpoint.

End point:

* method: POST
* url: /api/1/-/stream
* parameters:
  * secretKey: CINE_IO_SECRET_KEY

Example: `curl --data "secretKey=MY_SECRET_KEY" https://www.cine.io/api/1/-/stream`

### 2. Publish a live stream
*Location: Web Client*

Now you've saved your stream *id* and stream *password*. Using the JS SDK, you'll need to pass you project's *public key* to the client. If your specific user has permission in your application to publish to this stream, then you'll need to send along the stream *id* and stream *password* to your web client. For example, say your streams are associated with a "classroom" and the current logged in user has a "teacher" role

### 3. Play a live stream
*Location: Web Client*

Using the JS SDK, you'll need to pass you project's *public key* to the client. To play a stream using the JS SDK, you only need to send out the stream *id*. Only serve the stream *id* to users who have permission to view a stream. For example, say your streams are associated with a "classroom" and the current logged in user has a "student" role.

## Additional API endpoints

Additional API endpoints may be found at: [cine.io/docs](cine.io/docs).

## Using with Rails

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
client = CineIo::Client.new(secretKey: 'YOUR_SECRET_KEY')
```

Additional examples can be found at the repositories homepage: https://github.com/cine-io/cineio-ruby

## Using with Node.js

The npm package may be installed with the following command.

```term
npm install --save cine-io
```

Initialize the client.

```javascript
CineIO = require('cine-io');
client = CineIO.init({secretKey: 'my secret'});
```

Additional examples can be found at the repositories homepage: https://github.com/cine-io/cineio-node

## Dashboard

> callout
> For more information on the features available within the cine.io dashboard please see the docs at [cine.io/docs](cine.io/docs).

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
$ heroku addons:upgrade cine:startup
-----> Upgrading cine:startup to sharp-mountain-4005... done, v18 ($20/mo)
       Your plan has been updated to: cine:startup
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

All cine.io support and runtime issues should be submitted via on of the [Heroku Support channels](support-channels). Any non-support related issues or product feedback is welcome at [https://cineio.uservoice.com/](https://cineio.uservoice.com/).