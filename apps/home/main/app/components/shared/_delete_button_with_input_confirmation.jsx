/** @jsx React.DOM */
var React = require('react'),
  BaseModel = Cine.model('base');

module.exports = React.createClass({
  displayName: 'DeleteButtonWithInputConfirmation',
  propTypes:{
    model: React.PropTypes.instanceOf(BaseModel).isRequired,
    confirmationAttribute: React.PropTypes.string.isRequired,
    objectName: React.PropTypes.string.isRequired,
    deleteCallback: React.PropTypes.func.isRequired,
    isDeleting: React.PropTypes.bool.isRequired
  },
  getInitialState: function(){
    return {showDeleteButton: false, deletingObjectName: ''};
  },
  doNothing: function(e){
    e.preventDefault();
  },
  deleteObject: function(e){
    var attribute = this.props.model.get(this.props.confirmationAttribute);

    e.preventDefault();
    if (this.state.showDeleteButton && this.state.deletingObjectName == attribute){
      this.setState(this.getInitialState());
      this.props.deleteCallback();
    } else {
      this.setState({showDeleteButton: true});
    }
  },
  cancelDeleting: function(e){
    this.setState({showDeleteButton: false});
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
      deleteObjectSubmitButton;
    if (this.state.showDeleteButton){
      if (this.state.deletingObjectName == attribute){
        deleteObjectSubmitButton = (<button className='button alert tiny' type='submit'>Delete {attribute}</button>);
      }else{
        deleteObjectSubmitButton = (<button className='button alert tiny' disabled type='submit'>Delete {attribute}</button>);
      }
      return (
        <form onSubmit={this.deleteObject}>
          <label htmlFor='delete-input'>
            {"Type "}
            <code>{attribute}</code>
            {" to delete your " + this.props.objectName + "."}
          </label>
          <input ref='deleteNameInput' id='delete-input' type="text" value={this.deletingObjectName} onChange={this.changeObjectDeletingName} />
          {deleteObjectSubmitButton}
        </form>
      );
    }else if (this.props.isDeleting) {
      return (<button className='button alert tiny'disabled  onClick={this.doNothing}>Deleting {attribute}</button>);
    }else {
      return (<button className='button alert tiny' onClick={this.deleteObject}>Delete {attribute}</button>);
    }
  }
});
