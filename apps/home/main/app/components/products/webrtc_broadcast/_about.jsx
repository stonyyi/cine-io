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
              Take your real time video applications to the next level.
            </h2>
            <p>
              WebRTC is the future of live video. The world is your video playground.
            </p>
          </div>
        </div>
      </section>
    );
  }
});
