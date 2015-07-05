/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'HomeHero',
  getApiKey: function(e){
    e.preventDefault();

    this.props.app.tracker.getApiKey({value: 0});
    this.props.app.trigger('show-login');
  },

  render: function() {
    return (
      <div className="home-hero">
        <div className="brand-wrapper">
          <a href="/" title="cine.io">
            <h1 className="brand">cine.io</h1>
          </a>
          <h3>Build powerful video apps.</h3>
        </div>

        <div className="hero-content row">
          <div className="medium-12 columns top-margin-2">
            <div className="text-center medium-8 medium-offset-2 columns end">
              <span style={{color: "yellow"}}>
                NOTE: cine.io is shutting down on August 31st. {"  "}
                <a style={{color: "white", textDecoration: "underline"}} href="http://blog.cine.io/">Read more</a>.
              </span>
            </div>
          </div>
        </div>

        <div className="hero-content row">
          <div className="medium-12 columns top-margin-2">
            <div className="text-center medium-8 medium-offset-2 columns end">
              Live video-streaming. Audio- and video-conferencing. Focus on
              coding your app and let us take care of your video needs.
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

