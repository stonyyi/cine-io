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
    var doubleArrow = (
      <div className="double-arrow">
        <div className="arrow-right" />
        <div className="arrow-body">
          <div className="arrow-inner-body" />
        </div>
        <div className="arrow-left" />
      </div>
      )
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
                <div className="players left">
                  <div className="hero-image phone">
                    <img className="device" src="/images/peer-hero/phone.png" />
                    <img className="avatar" src="/images/peer-hero/user-female.png" />
                    {doubleArrow}
                  </div>
                  <div className="hero-image tablet">
                    <img className="device" src="/images/peer-hero/tablet.png" />
                    <img className="avatar" src="/images/peer-hero/user-male.png" />
                    {doubleArrow}
                  </div>
                  <div className="hero-image laptop">
                    <img className="device" src="/images/peer-hero/laptop.png" />
                    <img className="avatar" src="/images/peer-hero/user-male.png" />
                    {doubleArrow}
                  </div>
                </div>
              </div>


              <div className="hero-item cloud">
                <div className="hero-image">
                  <img src="/images/cine-cloud.png" />
                </div>
              </div>


              <div className="hero-item chat">
                <div className="players right">
                  <div className="hero-image laptop">
                    {doubleArrow}
                    <img className="device" src="/images/peer-hero/laptop.png" />
                    <img className="avatar" src="/images/peer-hero/user-female.png" />
                  </div>
                  <div className="hero-image tablet">
                    {doubleArrow}
                    <img className="device" src="/images/peer-hero/tablet.png" />
                    <img className="avatar" src="/images/peer-hero/user-female.png" />
                  </div>
                  <div className="hero-image phone">
                    {doubleArrow}
                    <img className="device" src="/images/peer-hero/phone.png" />
                    <img className="avatar" src="/images/peer-hero/user-male.png" />
                  </div>
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
