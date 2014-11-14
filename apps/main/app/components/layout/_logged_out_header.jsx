/** @jsx React.DOM */
var React = require('react')
  cx = Cine.lib('cx');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],
  propTypes: {
    selected: React.PropTypes.string
  },
  login: function() {
    this.props.app.trigger('show-login');
  },
  render: function() {
    var
      productsClass = cx({active: this.props.selected === "products"}),
      solutionsClass = cx({active: this.props.selected === "solutions"}),
      pricingClass = cx({active: this.props.selected === "pricing"}),
      docsClass = cx({active: this.props.selected === "docs"})
    ;
    return (
      <section className="top-bar-section">
        <ul className="right">
          <li className="outlined">
            <a onClick={this.login}>Sign In or Sign Up</a>
          </li>
        </ul>
        <ul className="right top-links">
          <li className={pricingClass}><a href="/pricing">Pricing</a></li>
          <li className={docsClass}><a href='/docs'>Docs</a></li>
        </ul>
      </section>
    );
  }
});
