/** @jsx React.DOM */
var
  React = require('react'),
  cx = Cine.lib('cx');

module.exports = React.createClass({
  displayName: 'HomeHero',
  mixins: [],
  render: function() {
    // <div className="hero-image broadcast"><img src="/images/home-hero/cine-broadcast.png" /></div>
    // <div className="hero-image arrow"><img src="/images/home-hero/cine-arrow.png" /></div>
    // <div className="hero-image cloud"><img src="/images/home-hero/cine-cloud.png" /></div>
    // <div className="hero-image arrow"><img src="/images/home-hero/cine-arrow.png" /></div>
    // <div className="hero-image play"><img src="/images/home-hero/cine-play.png" /></div>

    var rings = (
      <div className="hero-item rings">
        <div className="ring"></div>
        <div className="ring"></div>
        <div className="ring"></div>
        <div className="ring"></div>
      </div>
    );
    return (
      <div className='home-hero'>

        <div className="container">
          <a href="/" title="cine.io">
            <h1 className="brand">cine.io</h1>
          </a>
          <h3>Build powerful video apps. Like fer all yer porn.</h3>
        </div>
        <div className="row">

          <div>
            <div className="hero-row hero-flow">
              <div className="hero-item broadcaster-wrapper">
                <div className='table-row'>
                  <div className="hero-item broadcaster">
                    <div className="hero-image broadcast">
                      <img src="/images/home-hero/cine-broadcast.png" />
                    </div>
                  </div>
                  <div className="hero-item stage">
                    <video muted={true} autoPlay={true} loop={true}>
                      <source src="http://vod.cine.io/homepage/fireworks_320.webm" type="video/webm" />
                      <source src="http://vod.cine.io/homepage/fireworks_320.mp4" type="video/mp4" />
                    </video>
                  </div>
                </div>
              </div>
              {rings}
              <div className="hero-item cloud">
                <div className="hero-image">
                  <img src="/images/home-hero/cine-cloud.png" />
                </div>
              </div>

              {rings}

              <div className="hero-item watch">
                <div className="players">
                  <div className="hero-image laptop-video">
                    <video muted={true} autoPlay={true} loop={true}>
                      <source src="http://vod.cine.io/homepage/fireworks_320.webm" type="video/webm" />
                      <source src="http://vod.cine.io/homepage/fireworks_320.mp4" type="video/mp4" />
                    </video>
                    <img src="/images/home-hero/laptop.png" />
                  </div>
                  <div className="hero-image tablet-video">
                    <video muted={true} autoPlay={true} loop={true}>
                      <source src="http://vod.cine.io/homepage/fireworks_320.webm" type="video/webm" />
                      <source src="http://vod.cine.io/homepage/fireworks_320.mp4" type="video/mp4" />
                    </video>
                    <img src="/images/home-hero/tablet.png" />
                  </div>
                  <div className="hero-image phone-video">
                    <video muted={true} autoPlay={true} loop={true}>
                      <source src="http://vod.cine.io/homepage/fireworks_320.webm" type="video/webm" />
                      <source src="http://vod.cine.io/homepage/fireworks_320.mp4" type="video/mp4" />
                    </video>
                    <img src="/images/home-hero/phone.png" />
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="hero-text-wrapper">
            <div className='hero-row hero-text'>
              <div className="hero-item broadcaster-wrapper">
                <div>
                  <h3>Broadcast</h3>
                  <p>Broadcast using our native SDKs or popular broadcast software.</p>
                </div>
              </div>
              <div className='hero-item cloud'>
                <div>
                  <h3>Transcode, Record, Distribute</h3>
                  <p>Automatic transcoding and transmuxing for playback on any device. Record directly to the cloud.</p>
                </div>
              </div>
              <div className='hero-item players'>
                <div>
                  <h3>Watch</h3>
                  <p>View your content live or at a later time on any device.</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
