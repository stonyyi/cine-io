/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper');

module.exports = React.createClass({
  displayName: 'ErrorsUnauthorized',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  showSignIn: function(e){
    e.preventDefault();
    this.props.app.trigger('show-login');
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
