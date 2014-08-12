/** @jsx React.DOM */

var React = require('react'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder');

module.exports = React.createClass({
  displayName: 'PageWrapper',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  render: function() {
    return (
      <div id="page-layout">
        <div className='main-wrapper' className={this.canvasClasses()}>
          <FlashHolder app={this.props.app} />
          <div className="inner-wrap">
            <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
            <Header app={this.props.app} />
            <div className="container">
              {this.props.children}
            </div>
          </div>
          <div className='push'/>
        </div>
        <Footer />
      </div>
    );
  }
});
