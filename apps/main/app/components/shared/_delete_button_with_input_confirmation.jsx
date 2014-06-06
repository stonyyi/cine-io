/** @jsx React.DOM */
var React = require('react'),
  BaseModel = Cine.model('base');

module.exports = React.createClass({
  displayName: 'DeleteButtonWithInputConfirmation',
  propTypes:{
    model: React.PropTypes.instanceOf(BaseModel).isRequired,
    confirmationAttribute: React.PropTypes.string.isRequired,
    deleteCallback: React.PropTypes.func.isRequired
  },
  getInitialState: function(){
    return {isDeleting: false, deletingObjectName: ''};
  },
  deleteObject: function(e){
    var attribute = this.props.model.get(this.props.confirmationAttribute);

    e.preventDefault();
    if (this.state.isDeleting && this.state.deletingObjectName == attribute){
      this.setState(this.getInitialState());
      this.props.deleteCallback();
    } else {
      this.setState({isDeleting: true});
    }
  },
  cancelDeleting: function(e){
    this.setState({isDeleting: false});
  },
  changeObjectDeletingName: function(e){
    this.setState({deletingObjectName: event.target.value});
  },
  componentDidUpdate: function(){
    var deleteNameInput = this.refs.deleteNameInput;
    if (deleteNameInput){
      deleteNameInput.getDOMNode().focus();
    }
  },
  render: function() {
    var
      attribute = this.props.model.get(this.props.confirmationAttribute),
      deleteObject, deleteObjectSubmitButton;
    if (this.state.isDeleting){
      if (this.state.deletingObjectName == attribute){
        deleteObjectSubmitButton = (<button className='button alert tiny' type='submit'>Delete {attribute}</button>);
      }else{
        deleteObjectSubmitButton = (<button className='button alert tiny' disabled='disabled' type='submit'>Delete {attribute}</button>);
      }
      return (
        <form onSubmit={this.deleteObject}>
          <label htmlFor='delete-input'>
            {"Type "}
            <code>{attribute}</code>
            {" to delete your project."}
          </label>
          <input ref='deleteNameInput' id='delete-input' type="text" value={this.deletingObjectName} onChange={this.changeObjectDeletingName} />
          {deleteObjectSubmitButton}
        </form>
      );
    }else{
      return (<button className='button alert tiny' onClick={this.deleteObject}>Delete {attribute}</button>);
    }
  }
});
