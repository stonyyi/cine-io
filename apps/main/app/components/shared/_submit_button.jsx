/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'SubmitButton',
  propTypes:{
    submitting: React.PropTypes.bool.isRequired,
    text: React.PropTypes.string.isRequired,
    className: React.PropTypes.string,
    submittingText: React.PropTypes.string.isRequired
  },
  doNothing: function(e){
    e.preventDefault();
  },
  render: function() {
    if (this.props.submitting) {
      return (<button className={this.props.className} disabled onclick={this.doNothing}>{this.props.submittingText}</button>);
    } else {
      return (<button className={this.props.className} type='submit'>{this.props.text}</button>);
    }
  }
});
