/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer');

module.exports = React.createClass({

  render: function() {
    return (
      <div>
        <Header app={this.props.app}/>
        <Footer />
      </div>
    );
  }
});
