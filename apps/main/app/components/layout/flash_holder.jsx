/** @jsx React.DOM */
var React = require('react')
  , App = Cine.arch('app')
  , _ = require('underscore')
;
module.exports = React.createClass({
  displayName: 'FlashHolder',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    return {flashMessages: []};
  },
  // data is message, kind
  addFlash: function(data){
    this.setState({flashMessages: this.state.flashMessages.concat(data)});
  },
  componentDidMount: function(){
    this.props.app.on(App.flashEvent, this.addFlash, this);
  },
  componentWillUnmount: function(){
    this.props.app.off(App.flashEvent, this.addFlash);
  },
  closeAlert: function(i, e){
    e.preventDefault();
    this.state.flashMessages.splice(i, 1);
    this.setState({flashMessages: this.state.flashMessages});
  },
  render: function() {
    var
      self = this
      , messageMap = function(message, i) {
        var alertClasses = [message.kind, 'alert-box', 'radius'].join(' ');
        return (
          <div key={i} data-alert className={alertClasses}>
            <span className='alert-body'>{message.message}</span>
            <a href="" className='close-alert' onClick={self.closeAlert.bind(self, i)}>
              <i className="fa fa-times"></i>
            </a>
          </div>
          );
        }
      , flashMessages = _.map(this.state.flashMessages, messageMap);
    return (
      <div className='flash-holder'>
        {flashMessages}
      </div>
    );
  }
});
