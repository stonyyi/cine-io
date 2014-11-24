/** @jsx React.DOM */
var React = require('react'),
  flashDetect = Cine.lib('flash_detect'),
  cx = Cine.lib('cx'),
  InitializeCodeExample = Cine.component('homepage/code_examples/_initialize'),
  PlayCodeExample = Cine.component('homepage/code_examples/_play'),
  PublishCodeExample = Cine.component('homepage/code_examples/_publish');


exports.About = React.createClass({
  displayName: 'About',
  render: function() {
    return (
      <section id="about" className='top-margin-2'>
        <div className="row">
          <div className="info text-center">
            <h2>
              The first live-streaming service built
              <em> by </em> and
              <em> for </em> developers.
            </h2>
            <p>
              Leave the CDN and cross-platform viewing experience to us.
              Launch your live- streaming and video-conferencing apps in a
              matter of minutes using our APIs and SDKs for iOS, Android, and
              the web. We handle all of your RTC, RTMP, and HLS needs.
            </p>
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
      streamId: '5423749488b97308000d0763',
      streamPassword: 'tune8',
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

exports.Marketplaces = React.createClass({
  displayName: 'Marketplaces',
  render: function() {
    var squareSize = 32;
      multiplier = 2;
    squareSize *= multiplier;
    return (
      <section id="marketplaces">
        <div className="row text-center">
          <div className="medium-12 columns">
            <h2 className="bottom-margin-1">
              We work where you work.
            </h2>
            <p>
              cine.io supports one-click deployment with many popular PaaS providers, and can integrate with virtually any cloud infrastructure.
            </p>
            <ul className="icon-list">
              <li>
                <a target="_blank" href='https://addons.heroku.com/cine'>
                  <img src="/images/partner-logos/heroku.png" alt="Heroku logo" title="Heroku Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://console.run.pivotal.io/marketplace/cine-io'>
                  <img src="/images/partner-logos/engineyard.png" alt="PWS logo" title="Pivotal Web Services Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://addons.engineyard.com/addons/cineio'>
                  <img src="/images/partner-logos/pivotal-web-services.png" alt="Engineyard logo" title="Engineyard Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://marketplace.openshift.com/apps/14079'>
                  <img src="/images/partner-logos/redhat-openshift.png" alt="OpenShift logo" title="OpenShift Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://marketplace.samsungknox.com/apps/639'>
                  <img src="/images/partner-logos/samsung-knox.png" alt="Samsung Knox logo" title="Samsung Knox Marketplace" />
                </a>
              </li>
            </ul>
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
               <a className="button radius primary" target="_blank" href="mailto:support@cine.io?subject=Business+Inquiry">
                 Talk to us
               </a>
            </p>

          </div>
        </div>
      </section>
    );
  }
});



