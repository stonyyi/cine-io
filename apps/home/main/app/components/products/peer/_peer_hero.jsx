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
    var avatarBackground = (<div className="avatar-background" />)
    return (
      <div className='peer-hero'>

        <div className="row">
          <h1><i className="cine-conference"></i>&nbsp;Peer</h1>
          <h3>Build powerful real-time video apps.</h3>
        </div>
        <div className="hero-content row">
          <div className="hero-content-inner show-for-medium-up">
            <div className="hero-row hero-flow">

              <div className="hero-item chat">
                <div className="players left">
                  <div className="hero-image tablet">
                    <img className="device" src="//cdn.cine.io/images/peer-hero/tablet.png" />
                    <img className="avatar" src="//cdn.cine.io/images/peer-hero/user-male.png" />
                    {avatarBackground}
                    {doubleArrow}
                  </div>
                  <div className="hero-image laptop">
                    <img className="device" src="//cdn.cine.io/images/peer-hero/laptop.png" />
                    <img className="avatar" src="//cdn.cine.io/images/peer-hero/user-female.png" />
                    {avatarBackground}
                    {doubleArrow}
                  </div>
                </div>
              </div>


              <div className="hero-item cloud">
                <div className="hero-image">
                  <img src="//cdn.cine.io/images/cine-cloud.png" />
                </div>
              </div>


              <div className="hero-item chat">
                <div className="players right">

                  <div className="hero-image desktop">
                    {doubleArrow}
                    <img className="device" src="//cdn.cine.io/images/peer-hero/desktop.png" />
                    <img className="avatar" src="//cdn.cine.io/images/peer-hero/user-male.png" />
                    {avatarBackground}
                  </div>

                  <div className="hero-image phone">
                    {doubleArrow}
                    <img className="device" src="//cdn.cine.io/images/peer-hero/phone.png" />
                    <img className="avatar" src="//cdn.cine.io/images/peer-hero/user-female.png" />
                    {avatarBackground}
                  </div>

                </div>
              </div>


            </div>
          </div>
          <div className="hero-text">
            <h4>Device agnostic video chat</h4>
            <p>
              Make and receive calls from iOS*, Android*, or compatable
              web-browsers with minimal effort and very little code.
              <small>(*native mobile support coming soon)</small>
            </p>
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
