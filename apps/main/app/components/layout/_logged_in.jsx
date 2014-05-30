/** @jsx React.DOM */
var React = require('react')
  , authentication = Cine.lib('authentication');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],

  logout: function(e) {
    e.preventDefault()
    var _this = this
      , app = this.props.app
      , options = {
          success: function() {
            _this.props.app.router.redirectTo('/');
          }
        };
    authentication.logout(app, options);
  },
  doNothing: function(e){
    e.preventDefault();
  },
  collectFeedback: function(e) {
    e.preventDefault();
    var isServer = (typeof window === 'undefined')
      , user = this.props.app.currentUser;

    if (!isServer && window.UserVoice) {
      UserVoice=window.UserVoice||[];

      UserVoice.push(['identify', {
        email: user.get('email'),
        name: user.get('name'),
        created_at: user.get('created_at')
      }]);

      // (JW) customizing colors doesn't work for some reason
      // UserVoice.push(['set', {
      //   accent_color: '#128c87'
      // }]);

      UserVoice.push(['autoprompt', {}]);
    }
  },
  render: function() {
    var
      name = this.props.app.currentUser.get('name'),
      plan = this.props.app.currentUser.get('plan');

    return (
      <section className="top-bar-section">
        <ul className="right">
          <li>
            {plan}
          </li>
          <li className="has-dropdown not-click">
            <a href="" onClick={this.doNothing}>{name}</a>
            <ul id="user-menu" className="dropdown">
              <li><a href='' onClick={this.collectFeedback} data-uv-trigger="smartvote">Submit an Idea</a></li>
              <li><a href='' onClick={this.collectFeedback} data-uv-trigger="contact">Contact Us</a></li>
              <li><a href='' onClick={this.logout}>Sign Out</a></li>
            </ul>
          </li>
          <li className="menu-icon"><a href="#"></a></li>
        </ul>
      </section>
    );
  }
});
