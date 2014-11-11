/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],
  displayName: 'Pricing',
  getApiKey: function(plan, value, e){
    e.preventDefault();

    this.props.app.tracker.getApiKey({value: value});
    this.props.app.trigger('set-signup-plan', plan);
    this.props.app.trigger('show-login');
  },
  showCalculatorModal: function(e){
    e.preventDefault();
    this.props.app.trigger('show-modal', 'homepage/_bandwidth_calculator');
  },
  render: function() {
    return (
       <section id="pricing">
          <div className="row">
            <div className="info text-center">
              <h2>Simple, developer-friendly pricing.</h2>

              <i className="fa fa-2x fa-smile-o"></i>

              <div className="pitch">
                <h4>All plans include:</h4>
                <ul className="features">
                  <li>HD live-streaming <strong>to and from any
                  device</strong> (web, iOS, Android)</li>
                  <li>archiving / recording of streams</li>
                  <li>distribution via our <strong>global CDN</strong></li>
                  <li><strong>no ads</strong> of any kind</li>
                  <li><a href="http://cineio.uservoice.com">email</a> {" + "}
                  <strong><a href="https://www.hipchat.com/gZCLRQ9Ih">live chat support</a></strong>
                  &nbsp;from our developers</li>
                </ul>
              </div>

              <div className="prices">
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Solo</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">20 / mo</span>
                    </li>
                    <li className="description">Great for starting out.</li>
                    <li className="bullet-item">5 simultaneous streams</li>
                    <li className="bullet-item">20 GiB transferred</li>
                    <li className="bullet-item">5 GiB storage</li>
                    <li className="bullet-item">$0.90 per additional GiB transferred</li>
                    <li className="bullet-item">$0.90 per additional GiB storage</li>
                    <li className="cta-button"><a className="button radius" href="" onClick={this.getApiKey.bind(this, 'solo', 2)}>Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Basic</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">100 / mo</span>
                    </li>
                    <li className="description">Affordable, with few limits.</li>
                    <li className="bullet-item">unlimited streams</li>
                    <li className="bullet-item">150 GiB transferred</li>
                    <li className="bullet-item">25 GiB storage</li>
                    <li className="bullet-item">$0.80 per additional GiB transferred</li>
                    <li className="bullet-item">$0.80 per additional GiB storage</li>
                    <li className="cta-button">
                      <a className="button radius" href="" onClick={this.getApiKey.bind(this, 'basic', 3)}>Select</a>
                    </li>
                  </ul>
                </div>
                <div className="plan">
                  <ul className="pricing-table">
                    <li className="title">Pro</li>
                    <li className="price">
                      <span className="currency">$</span>
                      <span className="amount">500 / mo</span>
                    </li>
                    <li className="description">For heavy-lifting apps.</li>
                    <li className="bullet-item">unlimited streams</li>
                    <li className="bullet-item">1 TiB transferred</li>
                    <li className="bullet-item">100 GiB storage</li>
                    <li className="bullet-item">$0.70 per additional GiB transferred</li>
                    <li className="bullet-item">$0.70 per additional GiB storage</li>
                    <li className="cta-button">
                      <a className="button radius" href="" onClick={this.getApiKey.bind(this, 'pro', 4)}>Select</a>
                    </li>
                  </ul>
                </div>
              </div>
              <div className="postscript">
                <div>
                  <p>Or, <a href="" onClick={this.getApiKey.bind(this, 'free', 1)}>try for free</a>.</p>
                </div>
                <div>
                  <p>Need more than our <strong>Professional</strong> plan offers?&nbsp;&nbsp;
                  <a href="http://cineio.uservoice.com/">Contact us.</a></p>
                </div>
              </div>
            </div>
            <div className="row show-for-medium-up">
              <div className="column-12 columns text-center">
                <a className="button radius" href="" onClick={this.showCalculatorModal}>Bandwidth Calculator</a>
              </div>
            </div>
          </div>
        </section>
    );
  }
});
