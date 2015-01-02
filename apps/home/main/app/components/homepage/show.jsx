/** @jsx React.DOM */
var React = require('react'),
  PageWrapper = Cine.component('layout/_page_wrapper'),
  PeerHero = Cine.component('products/peer/_peer_hero'),
  BroadcastHero = Cine.component('products/broadcast/_broadcast_hero');

module.exports = React.createClass({
  displayName: 'HomepageShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.app.currentUser;
  },
  redirectToDashboard: function(){
    this.props.app.router.redirectTo('/dashboard');
  },
  componentDidMount: function() {
    this.props.app.currentUser.on('login', this.redirectToDashboard);
  },
  componentWillUnmount: function() {
    this.props.app.currentUser.off('login', this.redirectToDashboard);
  },

  render: function() {
      return (
        <PageWrapper app={this.props.app} wide={true} fixedNav={true} fadeLogo={true} className="homepage-logged-out">
          <div className="home-hero">

            <div className="brand-wrapper">
              <a href="/" title="cine.io">
                <h1 className="brand">cine.io</h1>
              </a>
              <h3>Build powerful video apps.</h3>
            </div>

            <div className="hero-content row">
              <div className="text-center">
                Put some marketing text here and figure out why button is not right.
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

          <div className="product-list">
            <div className="row">

              <div className="product-panel">
                <div className="panel">
                  <h2>
                    <a href="/products/broadcast">
                      <i className="cine-broadcast"></i>&nbsp;Broadcast
                    </a>
                  </h2>

                  <p>
                    Talk about broadcast.
                  </p>

                  <a className="button radius primary" href="/products/broadcast">
                    Learn More
                  </a>
                </div>
              </div>

              <div className="product-panel">
                <div className="panel">
                  <h2>
                    <a href="/products/peer">
                      <i className="cine-conference"></i>&nbsp;Peer
                    </a>
                  </h2>

                  <p>
                    Talk about peer.
                  </p>

                  <a className="button radius primary" href="/products/peer">
                    Learn More
                  </a>
                </div>
              </div>

            </div>
          </div>
        </PageWrapper>
      );
  }
});
