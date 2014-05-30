/** @jsx React.DOM */
var
  React = require('react'),
  StreamListItem = Cine.component('projects/_stream_list_item'),
  StreamDeets = Cine.component('homepage/_stream_deets'),
  NewStreamButton = Cine.component('homepage/_new_stream_button'),
  Streams = Cine.collection('streams'),
  Project = Cine.model('project'),
  InitializeCodeExample = Cine.component('homepage/code_examples/_initialize'),
  PlayCodeExample = Cine.component('homepage/code_examples/_play'),
  PublishCodeExample = Cine.component('homepage/code_examples/_publish');

module.exports = React.createClass({
  displayName: 'ProjectStreamsWrapper',
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
  render: function(){
    var selectedStreamId = this.state.selectedStreamId,
    streamDeets = '',
    publishAndPlay = '',
    streams = this.props.model.getStreams();
    var streamListItems = streams.map(function(model) {
      return (<option key={model.cid} value={model.cid}>{model.id}</option>);
    });
    // the selectedStreamId is null or not in the current list of streams,
    // select the first stream
    if ((!selectedStreamId || !streams.get(selectedStreamId)) && streams.length > 0){
      selectedStreamId = streams.models[0].id;
    }
    if (selectedStreamId){
      var selectedStream = streams.get(selectedStreamId);
      streamDeets = (<StreamDeets model={selectedStream} />);
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
            {streamDeets}
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
