/** @jsx React.DOM */
var React = require('react'),
  _ = require('underscore'),
  flashDetect = Cine.lib('flash_detect'),
  cx = Cine.lib('cx'),
  InitializeCodeExample = Cine.component('products/webrtc_broadcast/code_examples/_initialize'),
  PlayCodeExample = Cine.component('products/webrtc_broadcast/code_examples/_play');
  PublishCodeExample = Cine.component('products/webrtc_broadcast/code_examples/_publish');

module.exports = React.createClass({
  displayName: 'WebRTCToRTMPExample',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function() {
    return {
      examplePublicKey: '18b4c471bdc2bc1d16ad3cb338108a33',
      streamId: '54daf4676b57790900eedfcf',
      streamPassword: 'notes19',
      playerId: 'player-example',
      hasPublished: false,
      publishing: false,
      peersId: "peers",
      peers: []
    };
  },
  peerExample: function(e){
    e.preventDefault();
    // very first call, setup event listeners
    if (!this.state.hasPublished){
      CineIO.play(this.state.streamId, this.state.playerId, {mute: true});
      CineIOPeer.on('media-added', this._mediaAdded);
      CineIOPeer.on('media-removed', this._mediaRemoved);
    }
    if (this.state.publishing){
      CineIOPeer.stopCameraAndMicrophone();
      CineIOPeer.stopCameraAndMicrophoneBroadcast()
    }else{
      CineIOPeer.startCameraAndMicrophone(this._startBroadcast);
    }
    this.setState({hasPublished: true, publishing: !this.state.publishing});
  },
  componentDidMount: function(){
    CineIO.init(this.state.examplePublicKey);
    CineIOPeer.init(this.state.examplePublicKey);
  },
  // todo use update: http://facebook.github.io/react/docs/update.html
  // instead of force update
  _mediaAdded: function(data){
    this.state.peers.push(data.videoElement)
    this.forceUpdate();
  },
  _startBroadcast: function(err){
    if (err) {return console.log("ERROR", err);}
    CineIOPeer.broadcastCameraAndMicrophone(this.state.streamId, this.state.streamPassword)
  },
  _mediaRemoved: function(data){
    var peers = this.state.peers;
    indexOfPeer = _.indexOf(peers, data.videoElement);
    peers.splice(indexOfPeer, 1);
    this.forceUpdate();
  },
  componentWillUnmount: function(){
    CineIO.reset();
    CineIOPeer.reset();
    CineIOPeer.off('media-added', this._mediaAdded);
    CineIOPeer.off('media-removed', this._mediaRemoved);
  },
  render: function() {
    var peerTry = this.state.publishing ? 'Stop publishing' : (this.state.hasPublished ? 'Start publishing' : 'Start demo')
      , peerStartClasses = cx({
          'hide': !flashDetect(),
          'row': true,
          'top-margin-2': true,
          'show-for-medium-up': true
        })
      , peers;
    if (!this.state.hasPublished){
      peers = (
        <div className="aspect-wrapper">
          <div className="main">
            <div className="center-wrapper">
              <div className='center-content'>
                <p>During the demo, this box will be connected to your webcam.</p>
              </div>
            </div>
          </div>
        </div>
      );
    }else{
      peers = _.map(this.state.peers, function(video){
        return (<video key={video.src} src={video.src} muted={true} autoPlay />);
      });
    }
    return (
      <section className="full-code-example">
        <div className="row">
          <div className="head-script">
            <InitializeCodeExample publicKey={this.state.examplePublicKey} />
          </div>
        </div>
        <div className="row">
          <div className="right-script">
            <div className='bottom-margin-1'>
              <PublishCodeExample streamId={this.state.streamId} password={this.state.streamPassword}/>
            </div>

            <div className="show-for-medium-up center-video" id={this.state.peersId}>
              {peers}
            </div>
          </div>
          <div className="left-script">
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

        <div className={peerStartClasses}>
          <div className="small-12 columns">
            <div className='text-center'>
              <button className='button radius' onClick={this.peerExample}>{peerTry}</button>
            </div>
          </div>
        </div>
      </section>
    );
  }
});
