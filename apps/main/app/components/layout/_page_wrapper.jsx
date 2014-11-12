/** @jsx React.DOM */

var React = require('react'),
cx = Cine.lib('cx'),
Header = Cine.component('layout/header'),
Footer = Cine.component('layout/footer'),
ModalHolder = Cine.component('layout/modal_holder'),
LeftNav = Cine.component('layout/left_nav'),
FlashHolder = Cine.component('layout/flash_holder');

var MaxHeaderHeight = 45;
module.exports = React.createClass({
  displayName: 'PageWrapper',
  mixins: [Cine.lib('requires_app'), Cine.lib('has_nav')],
  propTypes: {
      wide: React.PropTypes.bool,
      className: React.PropTypes.string,
      selected: React.PropTypes.string,
      fixedNav: React.PropTypes.bool
  },
  getInitialState: function(){
    return {showingLogo: false};
  },
  onScroll: function(){
    var
      wrapper = this.refs.pageWrapper.getDOMNode(),
      header = this.refs.header.getDOMNode(),
      scrollOffset = wrapper.scrollTop;
    this.setState({showingLogo: scrollOffset >= 45});
  },
  render: function() {
    var
      wide = this.props.wide || false
      , children = (wide ?
        (<div className="wide-container"> {this.props.children} </div>) :
        (<div className="container"> {this.props.children} </div>)
      ),
      classNameOptions = {
        fixed: !!this.props.fixedNav
      }, className;
    if (this.props.className){
      classNameOptions[this.props.className] = true;
    }
    if (this.props.fixedNav){
      classNameOptions['show-logo'] = this.state.showingLogo;
      scrollHandler = this.onScroll;
    } else {
      classNameOptions['show-logo'] = true;
      scrollHandler = false;
    }
    console.log('classNameOptions', classNameOptions)
    className = cx(classNameOptions);

    return (
      <div ref="pageWrapper" id="page-layout" onScroll={scrollHandler} className={className}>
        <ModalHolder app={this.props.app} />
        <div className={this.canvasClasses('main-wrapper')}>
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <FlashHolder app={this.props.app} />
          <div className="inner-wrap">
            <Header ref="header" selected={this.props.selected} app={this.props.app} />
            {children}
          </div>
          <div className='push'/>
        </div>
        <Footer />
      </div>
    );
  }
});
