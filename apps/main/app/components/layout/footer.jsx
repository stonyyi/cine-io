/** @jsx React.DOM */
var React = require('react');
Footer = Cine.component('layout/footer');

module.exports = React.createClass({
  render: function() {
    return (
      <footer>
        <div className="row">
          <div className="info">Copyright &copy; 2014 cine.io. All rights reserved.</div>
        </div>
      </footer>
    );
  }
});
