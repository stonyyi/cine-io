/** @jsx React.DOM */
var
  React = require('react'),
  NewProject = Cine.component('homepage/_new_project'),
  ListItem = Cine.component('homepage/_project_list_item'),
  Projects = Cine.collection('projects'),
  StreamListItem = Cine.component('projects/_stream_list_item');


module.exports = React.createClass({
  displayName: 'LoggedIn',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    collection: React.PropTypes.instanceOf(Projects).isRequired
  },
  getInitialState: function(){
    return {selectedProjectId: null, selectedStreamId: null};
  },
  componentDidMount: function() {
    this.props.collection.fetch();
  },
  getBackboneObjects: function(){
    return this.props.collection;
  },
  showCreateNewProject: function(e){
    e.preventDefault();
    alert('new project not implemented');
  },
  createNewStream: function(e){
    e.preventDefault();
    alert('new stream not implemented');
  },
  changeSelectedStreamId: function(event) {
    this.setState({selectedStreamId: event.target.value});
  },

  selectProject: function(project){
    this.setState({selectedProjectId: project.id});
  },
  render: function() {
    var selectedProjectId = this.state.selectedProjectId,
    selectedStreamId = this.state.selectedStreamId
    // if nothing is selected, and we have a project, default select the first item
    if(!selectedProjectId && this.props.collection.length > 0){
      selectedProjectId = this.props.collection.models[0].id;
    }
    var
      createNewProject = ''
      , streamsPanel = ''
      , listItems = this.props.collection.map(function(model) {
        var selected = model.id === selectedProjectId;
        return (<ListItem key={model.cid} model={model} selected={selected}/>);
      });
    if (this.props.collection.length > 0){
      createNewProject = (
        <a href='' className='right' onClick={this.showCreateNewProject}>
          <span className="fa-stack fa-lg">
            <i className="fa fa-square fa-stack-2x"></i>
            <i className="fa fa-plus fa-stack-1x fa-inverse"></i>
          </span>
        </a>
      );
    }
    if (selectedProjectId){
      var selectedProject = this.props.collection.get(selectedProjectId);
      if (!selectedProject.streams){
        this.listenToBackboneChangeEvents(selectedProject.getStreams());
      }
      var streamListItems = selectedProject.getStreams().map(function(model) {
        return (<option key={model.cid} value={model.cid}>{model.id}</option>);
      });
      // the selectedStreamId is null or not in the current list of streams,
      // select the first stream
      if ((!selectedStreamId || !selectedProject.streams.get(selectedStreamId)) && selectedProject.getStreams().length > 0){
        selectedStreamId = selectedProject.getStreams().models[0].id;
      }
      var streamDeets = '';
      if (selectedStreamId){
        var selectedStream = selectedProject.getStreams().get(selectedStreamId);
        streamDeets = (
          <div className="panel">
           <dl>
             <dt>RTMP:</dt>
             <dd>{selectedStream.get('play').rtmp}</dd>
             <dt>HLS:</dt>
             <dd>{selectedStream.get('play').hls}</dd>
           </dl>
           <hr/>
           <dl>
             <dt>Stream:</dt>
             <dd>{selectedStream.get('publish').stream}</dd>
             <dt>FMS url:</dt>
             <dd>{selectedStream.get('publish').url}</dd>
           </dl>
          </div>
        );
      }

      streamsPanel = (
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
            HERE LIVES THE EXAMPLE CODE
          </div>
        </div>
      );
    }
    return (
      <div>
        <div className='row'>
          <div className='medium-8 columns'>
            <div className="panels-wrapper panel">
              <div className='panel-heading clearfix'>
                <h3> Projects </h3>
                {createNewProject}
              </div>
              <table className='clickable-row'>
                <thead>
                  <tr>
                    <th width='500'> Name </th>
                    <th width='30'> Plan </th>
                    <th width='60'> Actions </th>
                  </tr>
                </thead>
                <tbody>
                  {listItems}
                </tbody>
              </table>
            </div>
          </div>
          <div className='medium-4 columns'>
            DOCS HERE YO
          </div>
        </div>
        {streamsPanel}
        <div className="panel">
          <NewProject app={this.props.app} projects={this.props.collection}/>
        </div>
      </div>
    );
  }
});
