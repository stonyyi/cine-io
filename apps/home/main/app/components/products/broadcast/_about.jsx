/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'About',
  render: function() {
    return (
      <section id="about" className='top-margin-2'>
        <div className="row">
          <div className="info text-center">
            <h2>
              The first live-streaming service built
              <em> by </em> and
              <em> for </em> developers.
            </h2>
            <p>

              Launch your live-streaming apps in a matter of minutes using our
              APIs and SDKs for iOS, Android, and the web. Just focus on
              coding your app &mdash; we&apos;ll handle the infrastructure,
              CDN, and cross-platform viewing experience for both RTMP and HLS.

            </p>
          </div>
        </div>
      </section>
    );
  }
});
