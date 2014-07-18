/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'Footer',
  render: function() {
    return (
      <footer>
        <div className="row">
          <div className="info">Copyright &copy; 2014 cine.io. All rights reserved.</div>
        </div>
        <div className="row">
          <ul className="legal-links">
            <li><a href="https://blog.cine.io/">Blog</a></li>
            <li><a href="https://www.hipchat.com/gZCLRQ9Ih">Developer Chat</a></li>
            <li><a href="https://cineio.uservoice.com/">Feedback / Support</a></li>
            <li><a href="/legal/terms-of-service">Terms of Service</a></li>
            <li><a href="/legal/privacy-policy">Privacy Policy</a></li>
          </ul>
        </div>
      </footer>
    );
  }
});
