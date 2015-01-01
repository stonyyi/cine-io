/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'PeerHero',
  mixins: [Cine.lib('requires_app')],

  getApiKey: function(e){
    e.preventDefault();

    this.props.app.tracker.getApiKey({value: 0});
    this.props.app.trigger('show-login');
  },
  getInitialState: function(){
    return {};
  },
  render: function() {
    return (
      <div className='peer-hero'>

        <div className="row brand-wrapper">
          <a href="/" title="cine.io">
            <h1 className="brand">cine.io</h1>
          </a>
          <h3>Build powerful realtime video apps.</h3>
        </div>
        <div className="hero-content row">
          <div className="show-for-medium-up">
            <div className="hero-row hero-flow">

              <div className="hero-item chat">
                <div className="players">
                  <div className="hero-image phone-video">
                    <img src="/images/peer-hero/phone.png" />
                  </div>
                  <div className="hero-image tablet-video">
                    <img src="/images/peer-hero/tablet.png" />
                  </div>
                  <div className="hero-image laptop-video">
                    <img src="/images/peer-hero/laptop.png" />
                  </div>
                </div>
              </div>


              <div className="hero-item cloud">
                <div className="hero-image">
                  <img src="/images/cine-cloud.png" />
                </div>
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
