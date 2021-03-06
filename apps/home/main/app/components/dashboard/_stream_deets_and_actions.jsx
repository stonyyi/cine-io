/** @jsx React.DOM */
var
  React = require('react'),
  Stream = Cine.model('stream'),
  SubmitButton = Cine.component('shared/_submit_button'),
  DeleteButtonWithInputConfirmation = Cine.component('shared/_delete_button_with_input_confirmation'),
  Project = Cine.model('project');

module.exports = React.createClass({
  displayName: 'StreamDeetsAndActions',
  mixins: [Cine.lib('backbone_mixin')],
  propTypes: {
    model: React.PropTypes.instanceOf(Stream).isRequired,
    project: React.PropTypes.instanceOf(Project).isRequired
  },
  getInitialState: function(){
    return {showingNameForm: false, newStreamName: null, submitting: false, isDeleting: false};
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  destroyStream: function(){
    if(this.state.isDeleting){return;}
    this.setState({isDeleting: true});
    var self = this,
      secretKey = this.props.project.get('secretKey');
    this.props.model.attributes.secretKey = secretKey;
    this.props.model.destroy({
      data: {
        secretKey: secretKey
      },
      processData: true,
      wait: true,
      success: function(model, response){
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
        self.props.project.set('streamsCount', self.props.project.get('streamsCount')-1);
      },
      error: function(model, response){
        if (self.isMounted()){
          self.setState({isDeleting: false});
        }
      }
    });
  },
  showNameForm: function(e){
    e.preventDefault();
    this.setState({showingNameForm: true, newStreamName: this.props.model.get('name')});
  },
  hideNameForm: function(e){
    e.preventDefault()
    this.setState({showingNameForm: false, newStreamName: null});
  },
  setStreamName: function(event){
    this.setState({newStreamName: event.target.value});
  },
  componentDidUpdate: function(){
    if (this.state.showingNameForm){
      this.refs.newNameInput.getDOMNode().focus();
    }
  },
  saveNewStreamName: function(e){
    e.preventDefault();
    if(this.state.submitting){return;}
    this.setState({submitting: true});
    var self = this,
      secretKey = this.props.project.get('secretKey');
    this.props.model.attributes.secretKey = secretKey;
    this.props.model.set({secretKey: secretKey, name: this.state.newStreamName});
    this.props.model.save(null, {
      success: function(model, response){
        model.store()
        self.setState({showingNameForm: false, newStreamName: null, submitting :false});
      },
      error: function(model, response){
        self.setState({submitting: false})
      }
    });
  },
  changeRecord: function(newRecordValue, e){
    e.preventDefault()
    var self = this,
      secretKey = this.props.project.get('secretKey');
    this.props.model.attributes.secretKey = secretKey;
    this.props.model.set({secretKey: secretKey, record: newRecordValue});
    this.props.model.save(null, {
      success: function(model, response){
        model.store();
      }
    });
  },
  doNothing: function(e){
    e.preventDefault();
  },
  render: function(){
    var model = this.props.model,
      confirmationAttribute = this.props.model.get('name') ? 'name' : 'id',
      embedUrl = "/embed/"+this.props.project.get('publicKey')+"/"+this.props.model.get('id'),
      modelName, record;
    if (this.state.showingNameForm){
      modelName = (
        <form onSubmit={this.saveNewStreamName} >
          <input ref='newNameInput' type="text" name='name' value={this.state.newStreamName} onChange={this.setStreamName} placeholder="Add a stream name" />
          <SubmitButton text="Save" submittingText="Saving" submitting={this.state.submitting}/>
          <a href='' onClick={this.hideNameForm} >cancel</a>
        </form>
      );
    }else if (model.get('name')){
      modelName = (<div>{model.get('name')} <a href='' onClick={this.showNameForm}>edit</a></div>);
    }else{
      modelName = (<div><a href='' onClick={this.showNameForm}>add stream name</a></div>);
    }
    if (model.get('record')){
      record = (
        <ul className="button-group radius">
          <li><a href="" onClick={this.doNothing} className="button tiny alert disabled">True</a></li>
          <li><a href="" onClick={this.changeRecord.bind(this, false)} className="button tiny secondary">Make False</a></li>
        </ul>
      );
    } else{
      record = (
        <ul className="button-group radius">
          <li><a href="" onClick={this.changeRecord.bind(this, true)} className="button tiny secondary">Make True</a></li>
          <li><a href="" onClick={this.doNothing}className="button tiny alert disabled">False</a></li>
        </ul>
      );
    }
    return (
      <div className="panel">
        <dl>
          <dt>id:</dt>
          <dd>{model.id}</dd>
          <dt>Name:</dt>
          <dd>{modelName}</dd>
          <dt>Record:</dt>
          <dd>{record}</dd>
          <dt>Assigned at:</dt>
          <dd>{model.assignedAt().toString()}</dd>
        </dl>
        <a target="_blank" href={embedUrl} data-pass-thru={true}>Quick embed url</a>
        <hr/>
        <dl>
          <dt>Play Details</dt>
          <dt>RTMP:</dt>
          <dd>{model.get('play').rtmp}</dd>
          <dt>HLS:</dt>
          <dd>{model.get('play').hls}</dd>
        </dl>
        <hr/>
        <dl>
          <dt>Publish Details</dt>
          <dt>Publish url:</dt>
          <dd>{model.get('publish').url}/{model.get('publish').stream}</dd>
          <dt>FMS url:</dt>
          <dd>{model.get('publish').url}</dd>
          <dt>Stream:</dt>
          <dd>{model.get('publish').stream}</dd>
        </dl>
        <DeleteButtonWithInputConfirmation isDeleting={this.state.isDeleting} model={this.props.model} confirmationAttribute={confirmationAttribute} deleteCallback={this.destroyStream} objectName="stream" />
      </div>
    );
  }
});
