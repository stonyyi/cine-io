/** @jsx React.DOM */
var React = require('react')
  , App = Cine.arch('shared_app')
  , _ = require('underscore')
  , FlashMessage = Cine.component('layout/_flash_message')
  , flashTimeout = 5000 // milliseconds
;
module.exports = React.createClass({
  displayName: 'FlashHolder',
  mixins: [Cine.lib('requires_app')],
  getInitialState: function(){
    return {flashMessages: [], nextId: 0};
  },
  // data is message, kind
  addFlash: function(data){
    var
      self = this
      , id = this.state.nextId
    ;
    data.id = id;
    setTimeout(function(){
      message = _.find(self.state.flashMessages, function(flashMessage){
        return flashMessage.id === id;
      });
      self.setState({flashMessages: _.without(self.state.flashMessages, message)});
    }, flashTimeout);
    this.setState({nextId: self.state.nextId+1, flashMessages: self.state.flashMessages.concat(data)});
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
      , messageMap = function(flashMessage, i) {
        return (
          <FlashMessage key={flashMessage.id} kind={flashMessage.kind} message={flashMessage.message} closeAlert={self.closeAlert.bind(self, i)} />
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
