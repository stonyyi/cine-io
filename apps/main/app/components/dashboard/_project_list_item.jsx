/** @jsx React.DOM */
var
  React = require('react'),
  Project = Cine.model('project'),
  SubmitButton = Cine.component('shared/_submit_button'),
  DeleteButtonWithInputConfirmation = Cine.component('shared/_delete_button_with_input_confirmation'),
  cx = Cine.lib('cx');
module.exports = React.createClass({
  displayName: 'ProjectListItem',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired
  },
  getInitialState: function(){
    return {showingSettings: false, showingNameForm: false, newProjectName: null, submitting: false, isDeleting: false};
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  accessSettings: function (e) {
    e.preventDefault();
    e.stopPropagation();
    this.setState({showingSettings: !this.state.showingSettings});
  },
  showNameForm: function(e){
    e.preventDefault();
    this.setState({showingNameForm: true, newProjectName: this.props.model.get('name')});
  },
  hideNameForm: function(e){
    e.preventDefault();
    this.setState({showingNameForm: false, newProjectName: null});
  },
  setProjectName: function(event){
    this.setState({newProjectName: event.target.value});
  },
  componentDidUpdate: function(){
    if (this.state.showingNameForm){
      this.refs.newNameInput.getDOMNode().focus();
    }
  },
  saveNewProjectName: function(e){
    e.preventDefault();
    if (this.state.submitting){return;}
    this.setState({submitting: true});
    var self = this;
    this.props.model.set({name: this.state.newProjectName});
    this.props.model.save(null, {
      success: function(model, response){
        self.setState({showingNameForm: false, newProjectName: null, submitting: false});
      }, error: function(model, response){
        if (self.isMounted()){ self.setState({submitting: false}); }
      }
    });
  },
  showStreams: function(e){
    this._owner.selectProject(this.props.model);
  },
  destroyProject: function(){
    if(this.state.isDeleting){return;}
    var self = this;
    this.setState({isDeleting: true});
    this.props.model.destroy({
      data: {
        secretKey: this.props.model.get('secretKey')
      },
      processData: true,
      wait: true,
      success: function(model, response){
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
      },
      error: function(model, response){
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
      }
    });
  },
  render: function() {
    var model = this.props.model,
      classes = cx({selected: this.props.selected}),
      insideContent, modelName;


    if (this.state.showingSettings){
      if (this.state.showingNameForm){
        modelName = (
          <form onSubmit={this.saveNewProjectName} >
            <input ref='newNameInput' required='required' type="text" name='name' value={this.state.newProjectName} onChange={this.setProjectName} placeholder="Add a project name" />
            <SubmitButton text="Save" submittingText="Saving" submitting={this.state.submitting}/>
            <a href='' onClick={this.hideNameForm} >cancel</a>
          </form>
        );
      }else if (model.get('name')){
        modelName = (<div>{model.get('name')} <a href='' onClick={this.showNameForm}>edit</a></div>);
      }else{
        modelName = (<div><a href='' onClick={this.showNameForm}>add project name</a></div>);
      }
      insideContent = (
        <div>
          <div>{modelName}</div>
          <dl>
            <dt>Public key</dt>
            <dd>{model.get('publicKey')}</dd>
            <dt>Secret key</dt>
            <dd>{model.get('secretKey')}</dd>
            <dt>Streams count</dt>
            <dd>{model.get('streamsCount')}</dd>
          </dl>
          <DeleteButtonWithInputConfirmation model={model} isDeleting={this.state.isDeleting} confirmationAttribute='name' deleteCallback={this.destroyProject} objectName="project" />
        </div>
      );
    }else{
      insideContent = (<div>{model.get('name')}</div>)
    }
    return (
      <tr onClick={this.showStreams} className={classes}>
        <td className='no-move'>
          {insideContent}
        </td>
        <td className='place-top'>
          <a href='' onClick={this.accessSettings}>
            <i className="fa fa-cogs fa-2x"></i>
          </a>
        </td>
      </tr>
    );
  }
});
