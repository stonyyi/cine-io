/** @jsx React.DOM */
var React = require('react'),
  _ = require('underscore'),
  flashDetect = Cine.lib('flash_detect'),
  cx = Cine.lib('cx'),
  InitializeCodeExample = Cine.component('products/peer/code_examples/_initialize'),
  EventsCodeExample = Cine.component('products/peer/code_examples/_events'),
  JoinCodeExample = Cine.component('products/peer/code_examples/_join');


module.exports = React.createClass({
  displayName: 'PeerExample',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function() {
    return {
      examplePublicKey: '18b4c471bdc2bc1d16ad3cb338108a33',
      hasTested: false,
      testing: false,
      peersId: "peers",
      room: 'homepage-room',
      peers: []
    };
  },
  peerExample: function(e){
    e.preventDefault();
    // very first call, setup event listeners
    if (!this.state.hasTested){
      CineIOPeer.on('media-added', this._mediaAdded);
      CineIOPeer.on('media-removed', this._mediaRemoved);
      this.props.app.tracker.startedDemo('peer')
    }
    if (this.state.testing){
      CineIOPeer.stopCameraAndMicrophone();
      CineIOPeer.leave(this.state.room);
    }else{
      CineIOPeer.startCameraAndMicrophone();
      CineIOPeer.join(this.state.room);
    }
    this.setState({hasTested: true, testing: !this.state.testing});
  },
  componentDidMount: function(){
    CineIOPeer.init(this.state.examplePublicKey);
  },
  // todo use update: http://facebook.github.io/react/docs/update.html
  // instead of force update
  _mediaAdded: function(data){
    this.state.peers.push(data.videoElement)
    this.forceUpdate();
  },
  _mediaRemoved: function(data){
    var peers = this.state.peers;
    indexOfPeer = _.indexOf(peers, data.videoElement);
    peers.splice(indexOfPeer, 1);
    this.forceUpdate();
  },
  componentWillUnmount: function(){
    CineIOPeer.reset();
    CineIOPeer.off('media-added', this._mediaAdded);
    CineIOPeer.off('media-removed', this._mediaRemoved);
  },
  render: function() {
    var peerTry = this.state.testing ? 'Leave room' : (this.state.hasTested ? 'Join room' : 'Start demo')
      , peerStartClasses = cx({
          'hide': !flashDetect(),
          'row': true,
          'top-margin-2': true,
          'show-for-medium-up': true
        })
      , peers;
    if (!this.state.hasTested){
      peers = (
        <div className="aspect-wrapper">
          <div className="main">
            <div className="center-wrapper">
              <div className='center-content'>
                <p>During the demo, this box show people in the room.</p>
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
          <div className="left-script">
            <div className='bottom-margin-1'>
              <EventsCodeExample />
            </div>
          </div>
          <div className="right-script">
            <div className='bottom-margin-1'>
              <JoinCodeExample room={this.state.room}/>
            </div>
          </div>
        </div>
        <div className="row show-for-medium-up">
          <div id={this.state.peersId}>
            {peers}
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
