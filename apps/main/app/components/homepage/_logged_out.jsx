/** @jsx React.DOM */
var React = require('react'),
  flashDetect = Cine.lib('flash_detect'),
  cx = Cine.lib('cx'),
  InitializeCodeExample = Cine.component('homepage/code_examples/_initialize'),
  PlayCodeExample = Cine.component('homepage/code_examples/_play'),
  PublishCodeExample = Cine.component('homepage/code_examples/_publish');


exports.HomeHero = React.createClass({
  displayName: 'HomeHero',
  mixins: [Cine.lib('requires_app')],

  getApiKey: function(e){
    e.preventDefault();

    this.props.app.tracker.getApiKey({value: 0});
    this.props.app.trigger('show-login');
  },
  showSignIn: function(e){
    e.preventDefault();
    this.props.app.trigger('show-login');
  },
  revealAbout: function(e){
    e.preventDefault();
    $('#homepage-logged-out').scrollTo('#about', 250);
    window.history.pushState(null, "#about", "#about");
  },
  render: function() {
    var squareSize = 32;

    return (
      <section id="home-hero">
        <div className="row">
          <div className="info">
            <a href="/" title="cine.io">
              <h1 className="brand">cine.io</h1>
            </a>
            <h2 className="subtitle">Build powerful live-streaming apps.</h2>
            <h3 className="pitch">Get started for free.</h3>
            <div className="actions">
              <a href="" onClick={this.getApiKey} className="button radius">Get API Key</a><br/>
              <a href="" className="sign-in-link" onClick={this.showSignIn}>Already a customer? Sign in.</a>
            </div>
          </div>
        </div>

        <div className="scrollhint">
          <a href="" onClick={this.revealAbout}>
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
            </p>
            <p className="hook">
              Build ... ship ... <a target="_blank" href="https://www.youtube.com/watch?v=zS1cLOIxsQ8&amp;t=28s">do the happy dance</a>.
            </p>
          </div>
        </div>
      </section>
    );
  }
});


exports.Libraries = React.createClass({
  displayName: 'Libraries',
  render: function() {
    var squareSize = 32;
      multiplier = 2;
    squareSize *= multiplier;
    return (
      <section id="libraries">
        <div className="row text-center">
          <div className="medium-12 columns">
            <h2 className="bottom-margin-2">
              We speak your language.
            </h2>
            <ul className="icon-list">
              <li>
                <a target="_blank" href='https://github.com/cine-io/js-sdk'>
                  <img src="/images/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-ios'>
                  <img src="/images/ios-logo.png" alt="iOS logo" title="The iOS SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-android'>
                  <img src="/images/android-logo.png" alt="Android logo" title="The Android SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-ruby'>
                  <img src="/images/ruby-logo.png" alt="Ruby logo" title="The Ruby Gem" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-python'>
                  <img src="/images/python-logo.png" alt="Python logo" title="The Python Egg" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-node'>
                  <img src="/images/nodejs-logo.png" alt="Node.js logo" title="The Node.js Package" />
                </a>
              </li>
              <li className="show-for-medium-up">
                <a target="_blank" href='https://github.com/cine-io'>
                  <img src="/images/github-logo.png" alt="GitHub logo" title="Find us on GitHub" />
                </a>
              </li>
            </ul>
            <div>
              <p>Working in another framework / language? Don&apos;t sweat it. Our <a href="/docs">REST API</a> has you covered.</p>
            </div>
            <div className="developer-actions">
              <div>
                <a href="/docs" className="button radius">View documentation</a>
              </div>
              <div>
                <a href="https://www.hipchat.com/gZCLRQ9Ih" className="button radius">Developer chat</a>
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }
});


exports.Example = React.createClass({
  displayName: 'Example',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function() {
    return {
      examplePublicKey: '18b4c471bdc2bc1d16ad3cb338108a33',
      streamId: '53718cef450ff80200f81856',
      streamPassword: 'bass35',
      playerId: 'player-example',
      publisherId: 'publisher-example',
      hasPublished: false,
      publishing: false
    };
  },
  publisherExample: function(e){
    e.preventDefault();
    // very first call, start jwplayer and publisher
    if (!this.state.hasPublished){
      CineIO.play(this.state.streamId, this.state.playerId, {mute: true});
      this.publisher = CineIO.publish(this.state.streamId, this.state.streamPassword, this.state.publisherId);
      this.props.app.tracker.startedDemo()
    }
    this.setState({hasPublished: true});
    if (this.state.publishing){
      this.publisher.stop();
    }else{
      this.publisher.start();
    }
    this.setState({publishing: !this.state.publishing});
  },
  componentDidMount: function(){
    CineIO.init(this.state.examplePublicKey);
  },
  componentWillUnmount: function(){
    CineIO.reset();
  },
  render: function() {
    var publishTry = this.state.publishing ? 'Stop publisher' : (this.state.hasPublished ? 'Start publisher' : 'Watch demo')
      , topGist = ''
      , publishClasses = cx({
          'hide': !flashDetect(),
          'row': true,
          'top-margin-2': true
        })

    return (
      <section id="example">
        <div className="row">
          <div className="head-script">
            <InitializeCodeExample publicKey={this.state.examplePublicKey} />
          </div>
        </div>
        <div className="row">
          <div className="publish-script">
            <div className='bottom-margin-1'>
              <PublishCodeExample streamId={this.state.streamId} password={this.state.streamPassword}/>
            </div>
            <div className="show-for-medium-up" id={this.state.publisherId}>
              <div className="aspect-wrapper">
                <div className="main">
                  <div className="center-wrapper">
                    <div className='center-content'>
                      <p>During the demo, this box will be connected to your webcam.</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div className="play-script">
            <div className='bottom-margin-1'>
              <PlayCodeExample streamId={this.state.streamId}/>
            </div>
            <div className="show-for-medium-up" id={this.state.playerId}>
              <div className="aspect-wrapper">
                <div className="main">
                  <div className="center-wrapper">
                    <div className='center-content'>
                      <p>During the demo, this box will deliver your live-stream from our global CDN.</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
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
  mixins: [Cine.lib('requires_app')],

  displayName: 'Pricing',
  getApiKey: function(plan, value, e){
    e.preventDefault();

    this.props.app.tracker.getApiKey({value: value});
    this.props.app.trigger('set-signup-plan', plan);
    this.props.app.trigger('show-login');
  },

  render: function() {
    return (
       <section id="pricing">
          <div className="row">
            <div className="info text-center">
              <h2>Simple, developer-friendly pricing.</h2>

              <i className="fa fa-2x fa-smile-o"></i>

              <div className="pitch">
                <h4>All plans include:</h4>
                <ul className="features">
                  <li>HD live-streaming <strong>to and from any
                  device</strong> (web, iOS, Android)</li>
                  <li>archiving / recording of streams</li>
                  <li>distribution via our <strong>global CDN</strong> (2,000
                  interconnected networks across 5 continents)</li>
                  <li><strong>no ads</strong> of any kind</li>
                  <li><a href="http://cineio.uservoice.com">email</a> {" + "}
                  <strong><a href="https://www.hipchat.com/gZCLRQ9Ih">live chat support</a></strong>
                  &nbsp;from our developers</li>
                </ul>
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
                    <li className="bullet-item">5 simultaneous streams</li>
                    <li className="bullet-item">20 GiB transferred</li>
                    <li className="bullet-item">5 GiB storage</li>
                    <li className="bullet-item">$0.90 per additional GiB transferred</li>
                    <li className="bullet-item">$0.90 per additional GiB storage</li>
                    <li className="cta-button"><a className="button radius" href="" onClick={this.getApiKey.bind(this, 'solo', 2)}>Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Basic</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">100 / mo</span>
                    </li>
                    <li className="description">Affordable, with few limits.</li>
                    <li className="bullet-item">unlimited streams</li>
                    <li className="bullet-item">150 GiB transferred</li>
                    <li className="bullet-item">25 GiB storage</li>
                    <li className="bullet-item">$0.80 per additional GiB transferred</li>
                    <li className="bullet-item">$0.80 per additional GiB storage</li>
                    <li className="cta-button">
                      <a className="button radius" href="" onClick={this.getApiKey.bind(this, 'basic', 3)}>Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Pro</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">500 / mo</span>
                    </li>
                    <li className="description">For heavy-lifting apps.</li>
                    <li className="bullet-item">unlimited streams</li>
                    <li className="bullet-item">1 TiB transferred</li>
                    <li className="bullet-item">100 GiB storage</li>
                    <li className="bullet-item">$0.70 per additional GiB transferred</li>
                    <li className="bullet-item">$0.70 per additional GiB storage</li>
                    <li className="cta-button">
                      <a className="button radius" href="" onClick={this.getApiKey.bind(this, 'pro', 4)}>Select</a>
                    </li>
                  </ul>
                </div>
              </div>
              <div className="postscript">
                <div>
                  <p>Or, <a href="" onClick={this.getApiKey.bind(this, 'free', 1)}>try for free</a>.</p>
                </div>
                <div>
                  <p>Need more than our <strong>Professional</strong> plan offers?&nbsp;&nbsp;
                  <a href="http://cineio.uservoice.com/">Contact us.</a></p>
                </div>
              </div>
            </div>
          </div>
        </section>
    );
  }
});


exports.Consulting = React.createClass({
  displayName: 'Consulting',
  render: function() {
    return (
      <section id="consulting">
        <div className="row">
          <div className="info text-center">
            <h2>
              Need help building your app?
            </h2>

            <p>
              Bypass your competition by letting us prototype or build your
              app for you.
            </p>

            <p>
              The developers behind cine.io have decades of experience
              building multi-platform, multi-tier web platforms, applications,
              and services. In their previous lives, they built products and
              platforms like <a target="_blank"
              href="https://www.change.org/">Change.org</a>,&nbsp; <a
              target="_blank" href="https://www.givingstage.com/">Giving
              Stage</a>,&nbsp; and <a target="_blank"
              href="https://www.ironport.com">IronPort Systems</a>.
            </p>

            <p>
               <a className="button radius secondary" href="mailto:support@cine.io?subject=consulting+services">
                 Talk to us
               </a>
            </p>

          </div>
        </div>
      </section>
    );
  }
});



