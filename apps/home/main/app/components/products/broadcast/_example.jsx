/** @jsx React.DOM */
var React = require('react'),
  flashDetect = Cine.lib('flash_detect'),
  cx = Cine.lib('cx'),
  InitializeCodeExample = Cine.component('products/broadcast/code_examples/_initialize'),
  PlayCodeExample = Cine.component('products/broadcast/code_examples/_play'),
  PublishCodeExample = Cine.component('products/broadcast/code_examples/_publish');


module.exports = React.createClass({
  displayName: 'PeerExample',
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
      , publishClasses = cx({
          'hide': !flashDetect(),
          'row': true,
          'top-margin-2': true
        })

    return (
      <section id="broadcast-example">
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
