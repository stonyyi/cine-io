/** @jsx React.DOM */
var React = require('react'),
  parseUri = Cine.lib('parse_uri'),
  qs = require('qs'),
  PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'ErrorsUnauthorized',
  mixins: [Cine.lib('requires_app')],
  showSignIn: function(e){
    e.preventDefault();
    this.props.app.trigger('show-login');
  },
  moveToOriginalUrl: function(){
    uri = parseUri(window.location.href)
    params = qs.parse(uri.query)
    url = params.originalUrl || '/'
    this.props.app.router.redirectTo(url)
  },
  componentDidMount: function () {
    this.props.app.currentUser.on('login', this.moveToOriginalUrl);
  },
  componentWillUnmount: function () {
    this.props.app.currentUser.off('login', this.moveToOriginalUrl);
  },
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <div className="row">
          <div className="large-12 columns">
            <h1>Unauthorized</h1>
            <p>Please <a href="" onClick={this.showSignIn}> log in</a> to access this resource.</p>
          </div>
        </div>
      </PageWrapper>
    );
  }
});
