/** @jsx React.DOM */
var
  React = require('react'),
  NewProject = Cine.component('dashboard/_new_project'),
  ListItem = Cine.component('dashboard/_project_list_item'),
  Projects = Cine.collection('projects'),
  ProjectStreamsWrapper = Cine.component('dashboard/_project_streams_wrapper'),
  FlashMessage = Cine.component('layout/_flash_message'),
  cx = Cine.lib('cx');

module.exports = React.createClass({
  displayName: 'LoggedIn',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  propTypes: {
    masterKey: React.PropTypes.string.isRequired
  },
  getInitialState: function(){
    var projects = {}
    projects[this.props.masterKey] = this._createNewProject(this.props.masterKey);
    return {
      selectedProjectId: null, showingNewProject: false, projects: projects};
  },
  componentWillReceiveProps: function(nextProps){
    // allow the focus to be hijacked when not showing
    if (this.state.projects[nextProps.masterKey]) { return; }
    var newProjects = this._createNewProject(nextProps.masterKey);
    this.state.projects[nextProps.masterKey] = newProjects;
    this.listenToBackboneChangeEvents(newProjects);
    this.setState({projects: this.state.projects});
  },
  _createNewProject: function(masterKey){
    var newProjects = new Projects([], {app: this.props.app});
    newProjects.fetch({ data: { masterKey: masterKey} });
    return newProjects;
  },
  getBackboneObjects: function(){
    return this.getCurrentCollection();
  },
  showCreateNewProject: function(e){
    e.preventDefault();
    this.setState({showingNewProject: !this.state.showingNewProject});
  },
  selectProject: function(project){
    this.setState({selectedProjectId: project.id});
  },
  getCurrentCollection: function(){
    return this.state.projects[this.props.masterKey];
  },
  addProject: function(project){
    this.setState({showingNewProject: false});
    this.getCurrentCollection().add(project);
    this.selectProject(project);
  },
  render: function() {
    var
      selectedProjectId = this.state.selectedProjectId,
      currentAccount = this.props.app.currentAccount(),
      planNeedsCreditCard;
    // if something is selected and but it doesn't exist in the collection, remove it.
    if (selectedProjectId && !this.getCurrentCollection().get(selectedProjectId)){
      selectedProjectId = null;
    }
    // if nothing is selected, and we have a project, default select the first item
    if(!selectedProjectId && this.getCurrentCollection().length > 0){
      selectedProjectId = this.getCurrentCollection().models[0].id;
    }
    var
      streamsPanel = '',
      newProject = '',
      listItems = this.getCurrentCollection().map(function(model) {
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
    if (currentAccount.isDisabled()){
      var message;
      if (currentAccount.get('disabledReason')){
        message = '<i class="fa fa-2x fa-exclamation-triangle"></i><span>Your previous payment was unsuccessful. Please <a href="'+currentAccount.updateAccountUrl()+'">update your payment information</a> to immediatly reinstate your account. If you have questions feel free to <a target="_blank" href="mailto:support@cine.io?subject=Account disabled&body=Account Number: '+currentAccount.get('id')+'">contact support</a>.</span>';
      }
      else {
        message = '<i class="fa fa-2x fa-exclamation-triangle"></i><span>Your account is currently disabled. Please <a href="'+currentAccount.updateAccountUrl()+'">update your plan or payment information</a> to immediatly reinstate your account. If you have questions feel free to <a target="_blank" href="mailto:support@cine.io?subject=Account disabled&body=Account Number: '+currentAccount.get('id')+'">contact support</a>.</span>';
      }
      planNeedsCreditCard = (<FlashMessage message={message} kind="warning"/>)
    } else if (currentAccount.needsCreditCard()){
      var message = '<i class="fa fa-2x fa-exclamation-triangle"></i><span>Your account is currently limited to the free plan. To activate all the benefits of your <strong>'+currentAccount.firstPlan() +'</strong> plan, please go to your <a href="/account">account page</a> to enter a credit card.</span>'
      planNeedsCreditCard = (<FlashMessage message={message} kind="warning"/>)
    }

    if (this.state.showingNewProject){
      newProject = (<NewProject app={this.props.app} masterKey={this.props.masterKey}/>);
    }
    if (selectedProjectId){
      var selectedProject = this.getCurrentCollection().get(selectedProjectId);
      streamsPanel = (<ProjectStreamsWrapper app={this.props.app} model={selectedProject} />);
    }
    return (
      <div id="homepage-logged-in">
        <div className='row'>
          {planNeedsCreditCard}
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
                <a target="_blank" href='https://github.com/cine-io/broadcast-js-sdk'>
                  <img width='36' height='36' src="/images/code-logos/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-ios'>
                  <img width='36' height='36' src="/images/code-logos/ios-logo.png" alt="iOS logo" title="The iOS SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-broadcast-android'>
                  <img width='36' height='36' src="/images/code-logos/android-logo.png" alt="Android logo" title="The Android SDK" />
                </a>
              </li>
            </ul>

            <h4 className='top-margin-1'>Server side libraries</h4>
            <ul className="inline-list">
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-ruby'>
                  <img width='36' height='36' src="/images/code-logos/ruby-logo.png" alt="Ruby logo" title="The Ruby Gem" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-python'>
                  <img width='36' height='36' src="/images/code-logos/python-logo.png" alt="Python logo" title="The Python Egg" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-node'>
                  <img width='36' height='36' src="/images/code-logos/nodejs-logo.png" alt="Node.js logo" title="The Node.js Package" />
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
