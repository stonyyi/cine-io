/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'Products',
  render: function() {
    return (
      <section id="product-list">
        <div className="row">

          <div className="product-panel">
            <div className="panel">
              <h2>
                <a href="/products/broadcast">
                  <i className="cine-broadcast"></i>&nbsp;Broadcast
                </a>
              </h2>

              <p>
                Live video-streaming using RTMP and HLS, complete with
                lightning-fast global CDN.
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
                Video-conferencing using WebRTC, complete with global
                signaling infrastructure.
              </p>

              <a className="button radius primary" href="/products/peer">
                Learn More
              </a>
            </div>
          </div>

        </div>
      </section>
    );
  }
});

