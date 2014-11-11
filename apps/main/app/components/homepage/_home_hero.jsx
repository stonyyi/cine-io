/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'HomeHero',
  mixins: [],

  render: function() {
    // <div className="hero-image broadcast"><img src="/images/home-hero/cine-broadcast.png" /></div>
    // <div className="hero-image arrow"><img src="/images/home-hero/cine-arrow.png" /></div>
    // <div className="hero-image cloud"><img src="/images/home-hero/cine-cloud.png" /></div>
    // <div className="hero-image arrow"><img src="/images/home-hero/cine-arrow.png" /></div>
    // <div className="hero-image play"><img src="/images/home-hero/cine-play.png" /></div>

    return (
      <div className='home-hero'>
        <div className="hero-image laptop-video">
          <video muted={true} autoPlay={true} loop={true}>
            <source src="/videos/fireworks.mp4" type="video/mp4" />
          </video>
          <img src="/images/home-hero/laptop.png" />
        </div>
        <div className="hero-image tablet-video">
          <video muted={true} autoPlay={true} loop={true}>
            <source src="/videos/fireworks.mp4" type="video/mp4" />
          </video>
          <img src="/images/home-hero/tablet.png" />
        </div>
      </div>
    );
  }
});
