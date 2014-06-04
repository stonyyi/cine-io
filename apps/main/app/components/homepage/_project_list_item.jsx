/** @jsx React.DOM */
var
  React = require('react')
  , Project = Cine.model('project')
  , cx = Cine.lib('cx');
module.exports = React.createClass({
  displayName: 'ProjectListItem',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired
  },
  getInitialState: function(){
    return {showingSettings: false, isDeleting: false, deletingProjectName: ''};
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  accessSettings: function (e) {
    e.preventDefault();
    e.stopPropagation();
    this.setState({showingSettings: !this.state.showingSettings});
  },
  showStreams: function(e){
    this._owner.selectProject(this.props.model);
  },
  deleteProject: function(e){
    e.preventDefault();
    if (this.state.isDeleting && this.state.deletingProjectName == this.props.model.get('name')){
      this.actuallyDestroyProject();
    } else {
      this.setState({isDeleting: true, focusDeleteInput: true});
    }
  },
  cancelDeleting: function(e){
    this.setState({isDeleting: false});
  },
  changeProjectName: function(e){
    this.setState({deletingProjectName: event.target.value});
  },
  componentDidUpdate: function(){
    var deleteNameInput = this.refs.deleteNameInput;
    if (deleteNameInput){
      deleteNameInput.getDOMNode().focus();
    }
  },
  actuallyDestroyProject: function(){
    this.props.model.destroy({
      data: {
        secretKey: this.props.model.get('secretKey')
      },
      processData: true,
      wait: true
    });
  },
  render: function() {
    var model = this.props.model,
      classes = cx({selected: this.props.selected}),
      settings = '', deleteProject, deleteProjectSubmitButton;

    if (this.state.showingSettings){
      if (this.state.isDeleting){
        if (this.state.deletingProjectName == this.props.model.get('name')){
          deleteProjectSubmitButton = (<button className='button alert tiny' type='submit'>Delete {this.props.model.get('name')}</button>);
        }else{
          deleteProjectSubmitButton = (<button className='button alert tiny' disabled='disabled' type='submit'>Delete {this.props.model.get('name')}</button>);
        }
        deleteProject = (
          <form onSubmit={this.deleteProject}>
            <label htmlFor='delete-input'>{ "Type " + this.props.model.get('name') + " to delete your project."}</label>
            <input ref='deleteNameInput' id='delete-input' type="text" value={this.deletingProjectName} onChange={this.changeProjectName} />
            {deleteProjectSubmitButton}
          </form>
        );
      }else{
        deleteProject = (<button className='button alert tiny' onClick={this.deleteProject}>Delete {model.get('name')}</button>);
      }
      settings = (
        <div>
          <dl>
            <dt>Public key</dt>
            <dd>{model.get('publicKey')}</dd>
            <dt>Secret key</dt>
            <dd>{model.get('secretKey')}</dd>
            <dt>Streams count</dt>
            <dd>{model.get('streamsCount')}</dd>
          </dl>
          {deleteProject}
        </div>
      );
    }
    return (
      <tr onClick={this.showStreams} className={classes}>
        <td className='no-move'>
          <div>{model.get('name')}</div>
          {settings}
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
