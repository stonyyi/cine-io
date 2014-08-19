/** @jsx React.DOM */
var
  React = require('react'),
  NewProject = Cine.component('homepage/_new_project'),
  ListItem = Cine.component('homepage/_project_list_item'),
  Projects = Cine.collection('projects'),
  ProjectStreamsWrapper = Cine.component('homepage/_project_streams_wrapper'),
  cx = Cine.lib('cx');

module.exports = React.createClass({
  displayName: 'LoggedIn',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    collection: React.PropTypes.instanceOf(Projects).isRequired,
    masterKey: React.PropTypes.string.isRequired
  },
  getInitialState: function(){
    return {selectedProjectId: null, showingNewProject: false, };
  },
  componentDidMount: function() {
    this.props.collection.fetch({ data: { masterKey: this.props.masterKey} });
  },
  getBackboneObjects: function(){
    return this.props.collection;
  },
  showCreateNewProject: function(e){
    e.preventDefault();
    this.setState({showingNewProject: !this.state.showingNewProject});
  },
  selectProject: function(project){
    this.setState({selectedProjectId: project.id});
  },
  addProject: function(project){
    this.setState({showingNewProject: false});
    this.props.collection.add(project);
    this.selectProject(project);
  },
  render: function() {
    var selectedProjectId = this.state.selectedProjectId;
    // if something is selected and but it doesn't exist in the collection, remove it.
    if (selectedProjectId && !this.props.collection.get(selectedProjectId)){
      selectedProjectId = null;
    }
    // if nothing is selected, and we have a project, default select the first item
    if(!selectedProjectId && this.props.collection.length > 0){
      selectedProjectId = this.props.collection.models[0].id;
    }
    var
      streamsPanel = '',
      newProject = '',
      listItems = this.props.collection.map(function(model) {
        var selected = model.id === selectedProjectId;
        return (<ListItem key={model.cid} model={model} selected={selected}/>);
      });
    createNewProjectClasses = cx({
      'fa': true,
      'fa-stack-1x': true,
      'fa-inverse': true,
      'fa-plus': !this.state.showingNewProject,
      'fa-minus': this.state.showingNewProject
    });

    if (this.state.showingNewProject){
      newProject = (<NewProject app={this.props.app} masterKey={this.props.masterKey}/>);
    }
    if (selectedProjectId){
      var selectedProject = this.props.collection.get(selectedProjectId);
      streamsPanel = (<ProjectStreamsWrapper app={this.props.app} model={selectedProject} />);
    }
    return (
      <div id="homepage-logged-in">
        <div className='row'>
          <div className='medium-8 columns'>
            <div className="panels-wrapper panel">
              <div className='panel-heading clearfix'>
                <h3> Projects </h3>
                  <a href='' className='right' onClick={this.showCreateNewProject}>
                  <span className="fa-stack fa-lg">
                    <i className="fa fa-square fa-stack-2x"></i>
                    <i className={createNewProjectClasses}></i>
                  </span>
                </a>
              </div>
              {newProject}
              <table className='clickable-row'>
                <thead>
                  <tr>
                    <th width='500'> Name </th>
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
            <h4 className='top-margin-1'>
             <a href='/docs'>Full documentation</a>
            </h4>
            <h4 className='top-margin-1'>Client libraries</h4>
            <ul className="inline-list">
              <li>
                <a target="_blank" href='https://github.com/cine-io/js-sdk'>
                  <img width='36' height='36' src="/images/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-ios'>
                  <img width='36' height='36' src="/images/ios-logo.png" alt="iOS logo" title="The iOS SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-android'>
                  <img width='36' height='36' src="/images/android-logo.png" alt="Android logo" title="The Android SDK" />
                </a>
              </li>
            </ul>

            <h4 className='top-margin-1'>Server side libraries</h4>
            <ul className="inline-list">
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-ruby'>
                  <img width='36' height='36' src="/images/ruby-logo.png" alt="Ruby logo" title="The Ruby Gem" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-python'>
                  <img width='36' height='36' src="/images/python-logo.png" alt="Python logo" title="The Python Egg" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-node'>
                  <img width='36' height='36' src="/images/nodejs-logo.png" alt="Node.js logo" title="The Node.js Package" />
                </a>
              </li>
            </ul>

            <h4 className='top-margin-1'>Mobile apps</h4>
            <a target="_blank" href='https://itunes.apple.com/us/app/cine.io-console/id900579145'>
              <img className='bottom-margin-1' width='135' height='40' src="/images/app-store-badge-135x40.svg" alt="App Store Badge" title="cine.io Console app" />
            </a>
          </div>
        </div>
        {streamsPanel}
      </div>
    );
  }
});
