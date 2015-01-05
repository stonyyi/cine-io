/** @jsx React.DOM */
var
  React = require('react'),
  NewProject = Cine.component('dashboard/_new_project'),
  ListItem = Cine.component('dashboard/_project_list_item'),
  Projects = Cine.collection('projects'),

  BroadcastDashboardContent = Cine.component('dashboard/_broadcast_dashboard_content'),
  PeerDashboardContent = Cine.component('dashboard/_peer_dashboard_content'),

  BroadcastClientLibraries = Cine.component('dashboard/_broadcast_client_libraries'),
  PeerClientLibraries = Cine.component('dashboard/_peer_client_libraries'),
  ServerLibraries = Cine.component('dashboard/_server_libraries'),
  BroadcastMobileApps = Cine.component('dashboard/_broadcast_mobile_apps'),
  PeerMobileApps = Cine.component('dashboard/_peer_mobile_apps'),

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
      selectedProjectId: null,
      showingNewProject: false,
      projects: projects,
      showing: 'broadcast'
    };
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
  selectTab: function(tab, event){
    event.preventDefault();
    this.setState({showing: tab});
  },

  render: function() {
    var
      selectedProjectId = this.state.selectedProjectId,
      currentAccount = this.props.app.currentAccount(),
      documentationLink,
      planNeedsCreditCard, Documentation;
    // if something is selected and but it doesn't exist in the collection, remove it.
    if (selectedProjectId && !this.getCurrentCollection().get(selectedProjectId)){
      selectedProjectId = null;
    }
    // if nothing is selected, and we have a project, default select the first item
    if(!selectedProjectId && this.getCurrentCollection().length > 0){
      selectedProjectId = this.getCurrentCollection().models[0].id;
    }
    var
      bottomContent = '',
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
      if (this.state.showing === 'broadcast')
        bottomContent = (<BroadcastDashboardContent app={this.props.app} model={selectedProject} />);
      else
        bottomContent = (<PeerDashboardContent app={this.props.app} model={selectedProject} />);
    }
    if (this.state.showing === 'broadcast'){
      ClientLibraries = BroadcastClientLibraries;
      MobileApps = BroadcastMobileApps;
      documentationLink = "http://developer.cine.io/broadcast"
    } else {
      ClientLibraries = PeerClientLibraries;
      MobileApps = PeerMobileApps;
      documentationLink = "http://developer.cine.io/peer"
    }
    return (
      <div id="homepage-logged-in">
        <div className='row'>
          {planNeedsCreditCard}
          <div className='medium-12 columns'>
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
        </div>
        <div className='row'>
          <div className='medium-12 columns'>

            <div className="tabs-wrapper">
              <ul className="tabs" data-tab role="tablist">
                <li className={cx({'tab-title': true, active: this.state.showing === 'broadcast'})} role="presentational" >
                  <a onClick={this.selectTab.bind(this, 'broadcast')} href="" role="tab" tabIndex="0" aria-selected={this.state.showing === 'broadcast'}><i className="cine-broadcast"></i>&nbsp;Broadcast</a>
                </li>
                <li className={cx({'tab-title': true, active: this.state.showing === 'peer'})} role="presentational" >
                  <a onClick={this.selectTab.bind(this, 'peer')} href="" role="tab" tabIndex="1"aria-selected={this.state.showing === 'peer'}><i className="cine-conference"></i>&nbsp;Peer</a>
                </li>
              </ul>
            </div>
          </div>
        </div>
        <div className='row'>

          <div className='medium-3 columns'>
            <h4 className='top-margin-1'>
              <a target="_blank" href={documentationLink}>Full documentation</a>
            </h4>
          </div>
          <div className='medium-3 columns'>
            <ClientLibraries />
          </div>
          <div className='medium-3 columns'>
            <ServerLibraries />
          </div>
          <div className='medium-3 columns'>
            <MobileApps />
          </div>
        </div>
        {bottomContent}
      </div>
    );
  }
});
