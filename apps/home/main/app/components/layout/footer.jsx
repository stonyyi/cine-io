/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'Footer',
  render: function() {
    return (
      <footer>
        <div className="links">
          <div className="links-box">
            <div className="company-legal">
              <h4>Company</h4>
              <ul>
                <li><a href="http://blog.cine.io/">Blog</a></li>
              </ul>
              <h4>Legal</h4>
              <ul>
                <li><a href="/legal/terms-of-service">Terms of Service</a></li>
                <li><a href="/legal/privacy-policy">Privacy Policy</a></li>
              </ul>
            </div>
            <div className="feedback">
              <h4>Feedback and Support</h4>
              <ul>
                <li><a target="_blank" href="http://support.cine.io/">Get Support</a></li>
                <li><a target="_blank" href="http://support.cine.io/">Give us Feedback</a></li>
                <li><a href="http://status.cine.io/1228453">API Status</a></li>
              </ul>
            </div>
            <div className="developers">
              <h4>Developers</h4>
              <ul>
                <li><a target="_blank" href="http://devchat.cine.io/">Developer Chat</a></li>
                <li><a target="_blank" href="http://developer.cine.io/">Docs</a></li>
                <li><a href="/#libraries">SDKs</a></li>
                <li><a target="_blank" href="http://git.cine.io">Open Source</a></li>
              </ul>
            </div>
            <div className="social">
              <h4>Connect With Us</h4>
              <ul>
                <li><a target="_blank" href="http://git.cine.io"><i className="fa fa-github"></i> GitHub</a></li>
                <li><a target="_blank" href="https://twitter.com/cine_io"><i className="fa fa-twitter"></i> Twitter</a></li>
                <li><a target="_blank" href="https://www.facebook.com/cinedotio"><i className="fa fa-facebook"></i> Facebook</a></li>
                <li><a target="_blank" href="https://angel.co/cine-io"><i className="fa fa-angellist"></i> AngelList</a></li>
              </ul>
            </div>
          </div>
        </div>
        <div className="copyright">
          Copyright &copy; 2014 cine.io. All rights reserved.
        </div>
      </footer>
    );
  }
});
