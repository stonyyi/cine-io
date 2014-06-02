/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],

  login: function() {
    this.props.app.trigger('show-login');
  },

  render: function() {
    return (
      <section className="top-bar-section">
        <ul className="right show-for-large-up">
          <li className="active"><a onClick={this.login}>Sign In or Sign Up</a></li>
        </ul>
      </section>
    );
  }
});
