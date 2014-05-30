/** @jsx React.DOM */
var React = require('react')
  , flashDetect = Cine.lib('flash_detect')
  , cx = Cine.lib('cx');


exports.HomeHero = React.createClass({
  displayName: 'HomeHero',
  getApiKey: function(e){
    e.preventDefault();
    this._owner.openNav();
  },
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
              <a href="" onClick={this.getApiKey} className="button radius">Get API Key</a>

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
  displayName: 'About',
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
              You do not want to think about configuring a CDN, building a
              cross-platform viewing experience, or learning a new tool.
              <strong> You want to write code.</strong> cine.io lets you
              programatically set up, configure, and provision your streams
              through a RESTful API. That means less hassle, less wasted time,
              and happy developers. There are no account minimums, and you can
              get started today.
            </p>
          </div>
        </div>
      </section>
    );
  }
});

exports.Example = React.createClass({
  displayName: 'Example',
  getInitialState: function() {
    return {
      exampleApiKey: '18b4c471bdc2bc1d16ad3cb338108a33',
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
  componentDidMount: function(){
    CineIO.init(this.state.exampleApiKey);
  },
  componentWillUnmount: function(){
    CineIO.reset();
  },
  render: function() {
    var publishTry = this.state.publishing ? 'Stop publisher' : (this.state.hasPublished ? 'Start publisher' : 'See it in action')
      , topGist = ''
      , publishClasses = cx({
          'hide': !flashDetect(),
          'row': true,
          'top-margin-2': true
        })
      , headCode = [
          "&lt;script src='https://www.cine.io/compiled/cine.js'&gt;"
        , "&lt;script&gt;"
        , "  CineIO.init('38b8a26eff0dacbc1d5369eaa568b9df'); // your cine.io publicKey"
        , "&lt;/script&gt;"
        ].join('\n')
      , publishCode = [
          "var streamId = '53718cef450ff80200f81856'"
        , "  , password = 'bass35'"
        , ", domId = 'publisher-example';"
        , ""
        , "var publisher = CineIO.publish("
        , "  streamId, password, domId"
        , ");"
        , ""
        , "publisher.start();"
        ].join('\n')
      , playCode = [
          "var streamId = '53718cef450ff80200f81856'"
        , "  , domId = 'player-example';"
        , ""
        , "CineIO.play(streamId, domId);"
        , ""
        , "// We default the example to muted so that"
        , "// you don't get horrible microphone"
        , "// feedback from the publisher while"
        , "// checking out this example."
        ].join('\n');

    return (
      <section id="example">
        <div className="row top-margin-2">
          <div className="head-script">
            <pre>
              <code className='language-markup' dangerouslySetInnerHTML={{__html: headCode }} />
            </pre>
          </div>
        </div>
        <div className="row">
          <div className="publish-script">
            <div className='bottom-margin-1'>
              <pre>
                <code className='language-javascript' dangerouslySetInnerHTML={{__html: publishCode }} />
              </pre>
            </div>
            <div id={this.state.publisherId}></div>
          </div>
          <div className="play-script">
            <div className='bottom-margin-1'>
              <pre>
                <code className='language-javascript' dangerouslySetInnerHTML={{__html: playCode }} />
              </pre>
            </div>
            <div id={this.state.playerId}></div>
          </div>
        </div>
        <div className={publishClasses}>
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
  displayName: 'Pricing',
  getApiKey: function(e){
    e.preventDefault();
    this._owner.openNav();
  },

  render: function() {
    return (
       <section id="pricing">
          <div className="row">
            <div className="info text-center">
              <h2>Simple, developer-friendly pricing.</h2>

              <i className="fa fa-2x fa-smile-o"></i>

              <div className="pitch">
                All plans include live-streaming <strong>to and from any
                device</strong> (web, iOS, Android), distribution via our
                Global CDN (5,000 interconnected networks on 5 continents), no
                ads of any kind, and email support from our developers.
              </div>

              <div className="prices">
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Solo</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">20 / mo</span>
                    </li>
                    <li className="description">Great for starting out.</li>
                    <li className="bullet-item">5 streams</li>
                    <li className="bullet-item">20GB transferred</li>
                    <li className="cta-button"><a className="button radius" href="" onClick={this.getApiKey}>Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Startup</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">100 / mo</span>
                    </li>
                    <li className="description">Affordable, with few limits.</li>
                    <li className="bullet-item">unlimited streams</li>
                    <li className="bullet-item">150 GB transferred</li>
                    <li className="cta-button">
                      <a className="button radius" href="" onClick={this.getApiKey}>Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Enterprise</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">500 / mo</span>
                    </li>
                    <li className="description">For heavy-lifting apps.</li>
                    <li className="bullet-item">unlimited streams</li>
                    <li className="bullet-item">1 TB transferred</li>
                    <li className="cta-button">
                      <a className="button radius" href="" onClick={this.getApiKey}>Select</a>
                    </li>
                  </ul>
                </div>
              </div>

              <div className="postscript">
                <div>Or, <a href="#">try for free</a>.</div>
                <div>
                  If you expect to tranfer more than 1 TB, <a href="#">talk to us</a>. We can work with you on pricing.
                </div>
              </div>

            </div>
          </div>
        </section>
    );
  }
});
