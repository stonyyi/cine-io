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
              The first real-time audio and video service built
              <em> by </em> and
              <em> for </em> developers.
            </h2>
            <p>
              Launch your audio- and video-conferencing apps in a matter of
              minutes using our APIs and SDKs for iOS, Android, and the web.
              Just focus on coding your app &mdash; we&apos;ll handle the
              cross-platform viewing experience, signaling infrastructure, and
              firewall traversal.
            </p>
          </div>
        </div>
      </section>
    );
  }
});
