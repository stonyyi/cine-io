/** @jsx React.DOM */
var React = require('react');

exports.HomeHero = React.createClass({
  render: function() {
    return (
      <section id="home-hero">
        <div className="row">
          <div className="info">
            <a href="/" title="cine.io">
              <h1 className="brand">cine.io</h1>
            </a>
            <h2 className="subtitle">Device-agnostic live-streaming.</h2>
            <h3 className="pitch">Set up for your app in under 5 minutes.</h3>
            <div className="actions">
              <a href="#" className="button radius" data-reveal-id="not-ready-yet">Get API Key</a>

              <div id="not-ready-yet" className="reveal-modal" data-reveal>
                <h2>We are not ready yet!</h2>
                <p className="lead">Sorry &mdash; we need a few more weeks until we go live.</p>
                <p>Sorry for any confusion. You should check back on
                  <strong>2014-Jun-01</strong>. We should be ready by then.
                </p>
                <a className="close-reveal-modal"><i className="fa fa-times"></i></a>
              </div>
            </div>
          </div>
        </div>

        <div className="scrollhint">
          <a href="#about">
            Learn More<br/>
            <i className="fa fa-caret-down"></i>
          </a>
        </div>
      </section>
    );
  }
});

exports.About = React.createClass({
  render: function() {
    return (
      <section id="about">
        <div className="row">
          <div className="info text-center">
            <h2>
              The first live-streaming service built
              <em> by </em> and
              <em> for </em> developers.
            </h2>

            <p>
              You do not want to think about configuring a CDN, building a cross-platform viewing experience, or learning a new tool.
              <strong>You want to write code.</strong>cine.io lets you programatically set up, configure, and provision your streams through a RESTful API. That means less hassle, less wasted time, and happy developers. There are no account minimums, and you can get started today.
            </p>
          </div>
        </div>
      </section>
    );
  }
});

exports.Example = React.createClass({
  getInitialState: function() {
    return {
      exampleApiKey: '38b8a26eff0dacbc1d5369eaa568b9df',
      streamId: '53718cef450ff80200f81856',
      streamPassword: 'bass35',
      playerId: 'player-example',
      publisherId: 'publisher-example'
    };
  },
  publisherExample: function(e){
    e.preventDefault();
    if (!this.state.hasPublished){
      CineIO.play(this.state.streamId, this.state.playerId, {mute: true});
      this.setState({playing: true});
    }
    this.setState({hasPublished: true});
    if (!this.publisher){
      this.publisher = CineIO.publish(this.state.streamId, this.state.streamPassword, this.state.publisherId);
    }
    if (this.state.publishing){
      this.publisher.stop();
    }else{
      this.publisher.start();
    }
    this.setState({publishing: !this.state.publishing});
  },
  render: function() {
    var publishTry = this.state.publishing ? 'Stop publisher' : (this.state.hasPublished ? 'Start publisher' : 'See it in action');
    return (
      <section id="example">
        <div className="row top-margin-2">
          <div className="small-12 columns">
            <script src="https://gist.github.com/cine-dev/9a9133c5c4fe494ded22.js"></script>
          </div>
        </div>
        <div className="row">
          <div className="small-6 columns">
            <div className='bottom-margin-1'>
              <script src="https://gist.github.com/cine-dev/b7873efd692b54d7f5e5.js"></script>
            </div>
            <div id={this.state.publisherId}></div>
          </div>
          <div className="small-6 columns">
            <div className='bottom-margin-1'>
              <script src="https://gist.github.com/cine-dev/b00457a695d88863056c.js"></script>
            </div>
            <div id={this.state.playerId}></div>
          </div>
        </div>
        <div className="row top-margin-2">
          <div className="small-12 columns">
            <div className='text-center'>
              <button className='button radius' onClick={this.publisherExample}>{publishTry}</button>
            </div>
          </div>
        </div>

      </section>
    );
  }
});

exports.Pricing = React.createClass({
  render: function() {
    return (
       <section id="pricing">
          <div className="row">
            <div className="info text-center">
              <i className="fa fa-2x fa-smile-o"></i>
              <h2>Pricing</h2>

              <h3 className="subtitle">
                Simple, developer-friendly pricing.
              </h3>

              <div className="pitch">
                It is free to start out. We can work with you on pricing if you expect heavy volume. Get your API key today; you can be up and running in minutes.
              </div>

              <div className="prices">
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Free</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">0 / mo</span>
                    </li>
                    <li className="description">Get started for free!</li>
                    <li className="bullet-item">1 stream</li>
                    <li className="bullet-item">1GB transferred</li>
                    <li className="cta-button"><a className="button radius" href="#" data-reveal-id="not-ready-yet">Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Developer</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">20 / mo</span>
                    </li>
                    <li className="description">Great for starting out.</li>
                    <li className="bullet-item">5 streams</li>
                    <li className="bullet-item">25GB transferred</li>
                    <li className="cta-button"><a className="button radius" href="#" data-reveal-id="not-ready-yet">Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Enterprise</li>
                    <li className="price">
                      <span className="currency"></span>
                      <span className="amount">contact us</span>
                    </li>
                    <li className="description">For heavy-lifting apps.</li>
                    <li className="bullet-item">unlimited streams</li>
                    <li className="bullet-item">pay per GB transferred</li>
                    <li className="cta-button">
                      <a className="button radius" href="#" data-reveal-id="not-ready-yet">Select</a>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </section>
    );
  }
});
