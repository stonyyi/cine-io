/** @jsx React.DOM */
var
  React = require('react'),
  StreamDeetsAndActions = Cine.component('dashboard/_stream_deets_and_actions'),
  NewStreamButton = Cine.component('dashboard/_new_stream_button'),
  Streams = Cine.collection('streams'),
  Project = Cine.model('project'),
  InitializeCodeExample = Cine.component('products/broadcast/code_examples/_initialize'),
  PlayCodeExample = Cine.component('products/broadcast/code_examples/_play'),
  PublishCodeExample = Cine.component('products/broadcast/code_examples/_publish');

module.exports = React.createClass({
  displayName: 'BroadcastDashboardContent',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired,
  },
  getInitialState: function(){
    return {selectedStreamId: null};
  },
  getBackboneObjects: function(){
    return [this.props.model, this.props.model.getStreams()];
  },
  handleStreamChangeSelect: function(event) {
    this.changeSelectedStreamId(event.target.value);
  },
  changeSelectedStreamId: function(streamId) {
    this.setState({selectedStreamId: streamId});
  },
  componentWillReceiveProps: function(nextProps){
    this.listenToBackboneChangeEvents(nextProps.model.getStreams());
  },
  render: function(){
    var selectedStreamId = this.state.selectedStreamId,
    streamDeetsAndActions = '',
    publishAndPlay = '',
    streams = this.props.model.getStreams();
    var streamListItems = streams.map(function(stream) {
      var text = stream.get('name') || stream.id;
      return (<option key={stream.cid} value={stream.id}>{text}</option>);
    });
    // the selectedStreamId is null or not in the current list of streams,
    // select the first stream
    if ((!selectedStreamId || !streams.get(selectedStreamId)) && streams.length > 0){
      selectedStreamId = streams.models[0].id;
    }
    if (selectedStreamId){
      var selectedStream = streams.get(selectedStreamId);
      streamDeetsAndActions = (<StreamDeetsAndActions model={selectedStream} project={this.props.model}/>);
      publishAndPlay = (
        <div>
          <PublishCodeExample streamId={selectedStream.id} password={selectedStream.get('password')}/>
          <PlayCodeExample streamId={selectedStream.id}/>
        </div>
      );
    }
    return (
      <div className='row'>
        <div className='medium-6 columns'>
          <div className="panels-wrapper panel">
            <div className='panel-heading clearfix'>
              <h3> {this.props.model.get('streamsCount')} Streams </h3>
              <NewStreamButton app={this.props.app} model={this.props.model} />
            </div>
            <select value={selectedStreamId} onChange={this.handleStreamChangeSelect}>
              {streamListItems}
            </select>
            {streamDeetsAndActions}
          </div>
        </div>
        <div className='medium-6 columns'>
          <InitializeCodeExample publicKey={this.props.model.get('publicKey')}/>
          {publishAndPlay}
        </div>
      </div>
    );
  }


});
