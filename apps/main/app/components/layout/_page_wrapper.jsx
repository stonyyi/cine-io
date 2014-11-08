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
      className: React.PropTypes.string
  },
  getInitialState: function(){
    return {showingLogo: false};
  },
  // handleScroll: function(event){
  //   // console.log("scrolling", $(this.refs.pageWrapper.getDOMNode()).scrollTop());
  //   $(this.refs.pageWrapper.getDOMNode()).scrollTop()
  // },
  // componentDidMount: function() {
  //   console.log("mounting");
  //   $(this.refs.pageWrapper.getDOMNode()).on('scroll', this.handleScroll);
  // },
  // componentWillUnmount: function() {
  //   console.log("unmounting");
  //   $(this.refs.pageWrapper.getDOMNode()).off('scroll', this.handleScroll);
  // },
  onScroll: function(){
    var
      wrapper = this.refs.pageWrapper.getDOMNode(),
      header = this.refs.header.getDOMNode(),
      scrollOffset = wrapper.scrollTop;
    this.setState({showingLogo: scrollOffset >= 45});
  },
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
    var classNameOptions = {
      fixed: true
    };
    classNameOptions[this.props.className] = true;
    classNameOptions['show-logo'] = this.state.showingLogo;
    var className = cx(classNameOptions);

    return (
      <div ref="pageWrapper" id="page-layout" onScroll={this.onScroll} className={className}>
        <ModalHolder app={this.props.app} />
        <div className={this.canvasClasses('main-wrapper')}>
          <LeftNav app={this.props.app} showing={this.state.showingLeftNav}/>
          <FlashHolder app={this.props.app} />
          <div className="inner-wrap">
            <Header ref="header" app={this.props.app} />
            {children}
          </div>
          <div className='push'/>
        </div>
        <Footer />
      </div>
    );
  }
});
