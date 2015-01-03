/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
Static = Cine.component('shared/_static');

module.exports = React.createClass({
  displayName: 'SolutionsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('redirect_to_dashboard_on_login')],
  getInitialState: function(){
    return{};
  },
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    var slug = this.props.model.id.split('/')[1]
      , classNames = {
          "ios" : ""
        , "android" : ""
        };
    classNames[slug] = "active";

    return (
      <PageWrapper app={this.props.app} wide={true}>
        <Static document={this.props.model.get('document')} />
      </PageWrapper>
    );
  }
});
