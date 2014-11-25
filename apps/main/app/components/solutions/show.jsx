/** @jsx React.DOM */
var React = require('react'),
PageWrapper = Cine.component('layout/_page_wrapper'),
Static = Cine.component('shared/_static');

module.exports = React.createClass({
  displayName: 'SolutionsShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],

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
      <PageWrapper app={this.props.app}>
        <dl className="sub-nav">
          <dd className={classNames['ios']}><a href="/solutions/ios">iOS</a></dd>
          <dd className={classNames['android']}><a href="/solutions/android">Android</a></dd>
        </dl>
        <Static document={this.props.model.get('document')} />
      </PageWrapper>
    );
  }
});
