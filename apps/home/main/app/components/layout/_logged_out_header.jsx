/** @jsx React.DOM */
var React = require('react')
  cx = Cine.lib('cx');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    selected: React.PropTypes.string
  },
  getInitialState: function(){
    return {solutionsMoved: false, productsMoved: false};
  },
  login: function() {
    this.props.app.trigger('show-login');
  },
  toggleSolutionsMoved: function(e){
    e.preventDefault();
    this.setState({solutionsMoved: !this.state.solutionsMoved});
  },
  toggleProductsMoved: function(e){
    e.preventDefault();
    this.setState({productsMoved: !this.state.productsMoved});
  },
  render: function() {
    var
      pricingClass = cx({active: this.props.selected === "pricing"}),
      docsClass = cx({active: this.props.selected === "docs"}),
      solutionsClasses = cx({
        active: this.props.selected === "solutions",
        moved: this.state.solutionsMoved,
        'has-dropdown': true,
        'not-click': true
      }),
      productsClasses = cx({
        active: this.props.selected === "products",
        moved: this.state.productsMoved,
        'has-dropdown': true,
        'not-click': true
      }),
      productsDropDown = (
        <li className={productsClasses}>
          <a href="" onClick={this.toggleProductsMoved}>Products</a>
          <ul className="dropdown">
            <li>
              <a href="/products/broadcast">
                <i className="cine-broadcast" />
                &nbsp;Broadcast
              </a>
            </li>
            <li>
              <a href="/products/peer">
                <i className="cine-conference" />
                &nbsp;Peer
              </a>
            </li>
            <li>
              <a href="/products/webrtc-broadcast">
                <i className="cine-conference" />
                <i className="fa fa-long-arrow-right" />
                <i className="cine-broadcast" />
                &nbsp;Bridge
              </a>
            </li>
          </ul>
        </li>
      )
      solutionsDropDown = (
        <li className={solutionsClasses}>
          <a href="" onClick={this.toggleSolutionsMoved}>Solutions</a>
          <ul className="dropdown">
            <li><a href="/solutions/ios">iOS</a></li>
            <li><a href="/solutions/android">Android</a></li>
          </ul>
        </li>
      )
    ;

    return (
      <section className="top-bar-section">
        <ul className="right">
          <li className="outlined">
            <a onClick={this.login}>Sign In</a>
          </li>
        </ul>
        <ul className="right top-links">
          {productsDropDown}
          {solutionsDropDown}
          <li className={pricingClass}><a href="/pricing">Pricing</a></li>
          <li className={docsClass}><a target="_blank" href='http://developer.cine.io'>Docs</a></li>
        </ul>
      </section>
    );
  }
});
