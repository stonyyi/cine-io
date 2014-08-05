/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
AccountForm = Cine.component('account/_account_form');

module.exports = React.createClass({
  displayName: 'AccountEdit',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
          <div className="row">
            <dl className="columns large-12">
              <dt>Master Key</dt>
              <dd>{this.props.app.currentUser.get('masterKey')}</dd>
            </dl>
          </div>
          <AccountForm app={this.props.app}/>
      </PageWrapper>
    );
  }
});
