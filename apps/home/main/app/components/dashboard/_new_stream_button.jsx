/** @jsx React.DOM */
var
  React = require('react'),
  cx = Cine.lib('cx'),
  Project = Cine.model('project'),
  Stream = Cine.model('stream');

module.exports = React.createClass({
  displayName: 'ProjectStreamsWrapper',
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    model: React.PropTypes.instanceOf(Project).isRequired,
  },
  getInitialState: function(){
    return {submitting: false};
  },
  doNothing: function(e){
    e.preventDefault();
  },
  createNewStream: function(e){
    e.preventDefault();
    if(this.state.submitting){return;}
    this.setState({submitting: true});
    var self = this,
      p = new Stream({secretKey: this.props.model.get('secretKey')}, {app: this.props.app});
    p.save(null, {
      success: function(model, response, options){
        var returnedExistingStream = self.props.model.getStreams().get(model.id);
        if (self.isMounted()){ self.setState({submitting: false}); }
        self.props.model.getStreams().add(model);
        if (!returnedExistingStream){
          self.props.model.set('streamsCount', self.props.model.get('streamsCount') + 1);
        }else{
          self.props.app.flash("This plan is at its maximum stream limit. Please <a href='/account'>upgrade your account</a>.", 'info');
        }
        self._owner.changeSelectedStreamId(model.id);
      },
      error: function(model, response, options){
        if (self.isMounted()){ self.setState({submitting: false}); }
      }
    });
  },
  render: function(){
    var
      disabled = this.state.submitting,
      linkClasses = cx({right: true, disabled: disabled}),
      clickHandler = disabled ? this.doNothing : this.createNewStream;
    return (
      <a href='' className={linkClasses} disabled={disabled} onClick={clickHandler}>
        <span className="fa-stack fa-lg">
          <i className="fa fa-square fa-stack-2x"></i>
          <i className="fa fa-plus fa-stack-1x fa-inverse"></i>
        </span>
      </a>
    );
  }
});
