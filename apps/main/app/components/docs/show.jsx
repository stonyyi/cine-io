/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
Static = Cine.component('legal/_static');

module.exports = React.createClass({
  displayName: 'LegalShow',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    return (
      <div id='legal'>
        <Header app={this.props.app} />
          <div className="container">
            <Static document={this.props.model.get('document')} />
          </div>
        <Footer />
      </div>
    );
  }
});
