/** @jsx React.DOM */
var
  React = require('react'),
  cx = Cine.lib('cx');

module.exports = React.createClass({
  displayName: 'HomeHero',
  mixins: [],
  getInitialState: function(){
    return {rotateVideo: true, showPlayers: true};
  },
  componentDidMount: function () {
    // var showPlayersTimeout = setTimeout(this.showPlayers, 3200);
    // this.setState({rotateVideo: true, showPlayersTimeout: showPlayersTimeout});
  },
  componentWillUnmount: function () {
    clearTimeout(this.state.showPlayersTimeout)
  },
  showPlayers: function(){
    this.setState({showPlayers: true});
  },
  render: function() {
    // <div className="hero-image broadcast"><img src="/images/home-hero/cine-broadcast.png" /></div>
    // <div className="hero-image arrow"><img src="/images/home-hero/cine-arrow.png" /></div>
    // <div className="hero-image cloud"><img src="/images/home-hero/cine-cloud.png" /></div>
    // <div className="hero-image arrow"><img src="/images/home-hero/cine-arrow.png" /></div>
    // <div className="hero-image play"><img src="/images/home-hero/cine-play.png" /></div>


    var stageClassName = cx({rotate: this.state.rotateVideo});
    playersClassnameOptions = {players: true, invisible: !this.state.showPlayers};
    var playersClassname = cx(playersClassnameOptions);
    return (
      <div className='home-hero'>
        <div className="nothing">
          <div className="hero-row hero-flow">
            <div className="hero-item">
              <div className='table-row broadcaster-wrapper'>
                <div className="hero-item broadcaster">
                  <div className="hero-image broadcast">
                    <img src="/images/home-hero/cine-broadcast.png" />
                  </div>
                </div>
                <div className="hero-item stage">
                  <video className={stageClassName} muted={true} autoPlay={true} loop={true}>
                    <source src="http://vod.cine.io/homepage/fireworks.mp4" type="video/mp4" />
                  </video>
                </div>
              </div>
            </div>
            <div className="hero-item arrow">
              <div className="hero-image">
                <img src="/images/home-hero/cine-arrow.png" />
              </div>
            </div>
            <div className="hero-item cloud">
              <div className="hero-image">
                <img src="/images/home-hero/cine-cloud.png" />
              </div>
            </div>

            <div className="hero-item arrow">
              <div className="hero-image">
                <img src="/images/home-hero/cine-arrow.png" />
              </div>
            </div>

            <div className="hero-item watch">
              <div className={playersClassname}>
                <div className="hero-image laptop-video">
                  <video muted={true} autoPlay={true} loop={true}>
                    <source src="http://vod.cine.io/homepage/fireworks.mp4" type="video/mp4" />
                  </video>
                  <img src="/images/home-hero/laptop.png" />
                </div>
                <div className="hero-image tablet-video">
                  <video muted={true} autoPlay={true} loop={true}>
                    <source src="http://vod.cine.io/homepage/fireworks.mp4" type="video/mp4" />
                  </video>
                  <img src="/images/home-hero/tablet.png" />
                </div>
                <div className="hero-image phone-video">
                  <video muted={true} autoPlay={true} loop={true}>
                    <source src="http://vod.cine.io/homepage/fireworks.mp4" type="video/mp4" />
                  </video>
                  <img src="/images/home-hero/phone.png" />
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className='hero-row hero-text'>
          <div className="hero-item">
            <h3>Broadcast</h3>
            <p>Broadcast using our native SDKs or popular broadcast software.</p>
          </div>
          <div className='hero-item'>
            <h3>Transcode, Record, Distribute</h3>
            <p>Automatic transcoding and transmuxing for playback on any device. Record directly to the cloud.</p>
          </div>
          <div className='hero-item'>
            <h3>Watch</h3>
            <p>View your content live or at a later time on any device.</p>
          </div>
        </div>
      </div>
    );
  }
});
