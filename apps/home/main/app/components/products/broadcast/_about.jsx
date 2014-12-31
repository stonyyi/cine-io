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
              Leave the CDN and cross-platform viewing experience to us.
              Launch your live- streaming and video-conferencing apps in a
              matter of minutes using our APIs and SDKs for iOS, Android, and
              the web. We handle all of your RTMP, and HLS needs.
            </p>
          </div>
        </div>
      </section>
    );
  }
});
