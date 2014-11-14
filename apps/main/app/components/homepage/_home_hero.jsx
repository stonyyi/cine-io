/** @jsx React.DOM */
var
  React = require('react'),
  cx = Cine.lib('cx');

module.exports = React.createClass({
  displayName: 'HomeHero',
  mixins: [],
  getApiKey: function(e){
    e.preventDefault();

    this.props.app.tracker.getApiKey({value: 0});
    this.props.app.trigger('show-login');
  },
  render: function() {
    var arrows = (
      <div className="hero-item arrows">
        <div className="arrow"></div>
        <div className="arrow"></div>
        <div className="arrow extra-arrow"></div>
        <div className="arrow extra-arrow"></div>
      </div>
    );

    var broadcastText = (
      <div>
        <h4>Broadcast</h4>
        <p>Broadcast using our native SDKs or any broadcast software that supports RTMP.</p>
      </div>
    );
    var transcodeText = (
      <div>
        <h4>Transcode and Store</h4>
        <p>Automatic transcoding and transmuxing for mobile playback. Record directly to the cloud.</p>
      </div>
    );
    var watchText = (
      <div>
        <h4>Watch Anywhere</h4>
        <p>View your content live or at a later time on any device using our global CDN.</p>
      </div>
    );
    return (
      <div className='home-hero'>

        <div className="container">
          <a href="/" title="cine.io">
            <h1 className="brand">cine.io</h1>
          </a>
          <h3>Build powerful video apps.</h3>
        </div>
        <div className="show-for-small-only">
          <div className='text-center'>
            <h4>Broadcast</h4>
            {arrows}
            <h4>Transcode and Store</h4>
            {arrows}
            <h4>Watch Anywhere</h4>
          </div>
        </div>
        <div className="hero-content row">
          <div className="show-for-medium-up">
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

              {arrows}

              <div className="hero-item cloud">
                <div className="hero-image">
                  <img src="/images/home-hero/cine-cloud.png" />
                </div>
              </div>

              {arrows}

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

          <div className="hero-text-wrapper show-for-medium-up">
            <div className='hero-row hero-text'>
              <div className="hero-item broadcaster-wrapper">
                {broadcastText}
              </div>
              <div className='hero-item cloud'>
                {transcodeText}
              </div>
              <div className='hero-item players'>
                {watchText}
              </div>
            </div>

          </div>
          <div className="call-to-action">
            <span className="api-key-button">
              <a className="button radius secondary" href="" onClick={this.getApiKey}>
                Get Free API Key
              </a>
            </span>
          </div>
        </div>
      </div>
    );
  }
});
