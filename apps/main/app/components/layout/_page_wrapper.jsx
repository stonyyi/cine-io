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
    var wide = this.props.wide || false
      , children = wide ?
        (
          <div className="wide-container">
            {this.props.children}
          </div>
        ) :
        (
          <div className="container">
            {this.props.children}
          </div>
        )

    return (
      <div id="page-layout">
        <div className={this.canvasClasses('main-wrapper')}>
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <FlashHolder app={this.props.app} />
          <div className="inner-wrap">
            <Header app={this.props.app} />
            {children}
          </div>
          <div className='push'/>
        </div>
        <Footer />
      </div>
    );
  }
});
