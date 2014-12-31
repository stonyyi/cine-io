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
              The first live realtime video and audio service built
              <em> by </em> and
              <em> for </em> developers.
            </h2>
            <p>
              Leave the global signaling and cross-platform viewing experience to us.
              Launch your video-conferncing and video/audio-chat apps in a
              matter of minutes using our APIs and SDKs for iOS, Android, and
              the web.
            </p>
          </div>
        </div>
      </section>
    );
  }
});
