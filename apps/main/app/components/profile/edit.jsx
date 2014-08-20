/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
ProfileForm = Cine.component('profile/_profile_form');

module.exports = React.createClass({
  displayName: 'ProfileEdit',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    return (
      <PageWrapper app={this.props.app}>
        <h1 className="bottom-margin-1">Profile Information</h1>
        <ProfileForm app={this.props.app}/>
      </PageWrapper>
    );
  }
});
