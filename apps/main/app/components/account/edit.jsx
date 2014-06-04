/** @jsx React.DOM */
var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder');

module.exports = React.createClass({
  displayName: 'AccountEdit',
  mixins: [Cine.lib('requires_app'), Cine.lib('backbone_mixin'), Cine.lib('has_nav')],
  getBackboneObjects: function(){
    return this.props.model;
  },
  render: function() {
    return (
      <div id='legal'className={this.canvasClasses()}>
        <FlashHolder app={this.props.app}/>
        <div className="inner-wrap">
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <Header app={this.props.app} />
          <div className="container">
          </div>
        </div>
        <Footer />
      </div>
    );
  }
});
