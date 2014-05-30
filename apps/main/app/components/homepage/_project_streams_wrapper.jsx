/** @jsx React.DOM */
var
  React = require('react'),
  StreamListItem = Cine.component('projects/_stream_list_item'),
  StreamDeets = Cine.component('homepage/_stream_deets'),
  Streams = Cine.collection('streams'),
  Project = Cine.model('project'),
  IntalizeCodeExample = Cine.component('homepage/code_examples/_initialize');
  PlayCodeExample = Cine.component('homepage/code_examples/_play');
  PublishCodeExample = Cine.component('homepage/code_examples/_publish');

module.exports = React.createClass({
  displayName: 'ProjectStreamsWrapper',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    project: React.PropTypes.instanceOf(Project).isRequired,
  },
  getInitialState: function(){
    return {selectedStreamId: null};
  },
  getBackboneObjects: function(){
    return [this.props.model, this.props.model.getStreams()];
  },
  changeSelectedStreamId: function(event) {
    this.setState({selectedStreamId: event.target.value});
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
              <h3> Streams </h3>
              <a href='' className='right' onClick={this.createNewStream}>
                <span className="fa-stack fa-lg">
                  <i className="fa fa-square fa-stack-2x"></i>
                  <i className="fa fa-plus fa-stack-1x fa-inverse"></i>
                </span>
              </a>
            </div>
            <select value={selectedStreamId} onChange={this.changeSelectedStreamId}>
              {streamListItems}
            </select>
            {streamDeets}
          </div>
        </div>
        <div className='medium-6 columns'>
          <IntalizeCodeExample publicKey={this.props.model.get('publicKey')}/>
          {publishAndPlay}
        </div>
      </div>
    );
  }


});
