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
  showToolTip: function(e){
    e.preventDefault();
    console.log(this, e.target);
  },
  render: function() {
    return (
      <div>
       <section id="pricing">
          <div className="info">
            <h2>Simple, developer-friendly pricing.</h2>

            <div className="prices">
              <table>
                <thead>
                  <tr>
                    <th></th>
                    <th>Included Streams</th>
                    <th>Included Bandwidth</th>
                    <th>Included Storage</th>
                    <th>Cost / Month</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Developer</td>
                    <td>1</td>
                    <td>1 GiB</td>
                    <td>0.5 GiB</td>
                    <td className="cost">Free</td>
                    <td><a className="button tiny radius" href="" onClick={this.getApiKey.bind(this, 'free', 1)}>Select</a></td>
                  </tr>
                  <tr>
                    <td>Solo</td>
                    <td>5</td>
                    <td>20 GiB</td>
                    <td>5 GiB</td>
                    <td className="cost">$20</td>
                    <td><a className="button tiny radius" href="" onClick={this.getApiKey.bind(this, 'solo', 2)}>Select</a></td>
                  </tr>
                  <tr>
                    <td>Basic</td>
                    <td>25</td>
                    <td>150 GiB</td>
                    <td>25 GiB</td>
                    <td className="cost">$100</td>
                    <td><a className="button tiny radius" href="" onClick={this.getApiKey.bind(this, 'basic', 3)}>Select</a></td>
                  </tr>
                  <tr>
                    <td>Premium</td>
                    <td>100</td>
                    <td>500 GiB</td>
                    <td>50 GiB</td>
                    <td className="cost">$300</td>
                    <td><a className="button tiny radius" href="" onClick={this.getApiKey.bind(this, 'premium', 4)}>Select</a></td>
                  </tr>
                  <tr>
                    <td>Pro</td>
                    <td>500</td>
                    <td>1 TiB</td>
                    <td>100 GiB</td>
                    <td className="cost">$500</td>
                    <td><a className="button tiny radius" href="" onClick={this.getApiKey.bind(this, 'pro', 5)}>Select</a></td>
                  </tr>
                  <tr>
                    <td>Startup</td>
                    <td>Unlimited</td>
                    <td>5 TiB</td>
                    <td>250 GiB</td>
                    <td className="cost">$2,000</td>
                    <td><a className="button tiny radius" href="" onClick={this.getApiKey.bind(this, 'startup', 6)}>Select</a></td>
                  </tr>
                  <tr>
                    <td>Enterprise</td>
                    <td>Unlimited</td>
                    <td>15 TiB</td>
                    <td>500 GiB</td>
                    <td className="cost">$5,000</td>
                    <td><a className="button tiny radius" href="" onClick={this.getApiKey.bind(this, 'enterprise', 7)}>Select</a></td>
                  </tr>
                  <tr>
                    <td>Custom</td>
                    <td>Unlimited</td>
                    <td>&gt; 10 TiB</td>
                    <td>&gt;= 1 TiB</td>
                    <td className="cost">Negotiable</td>
                    <td><a className="button tiny radius" href="http://cineio.uservoice.com/">Contact Us</a></td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="row show-for-medium-up">
              <div className="column-12 columns text-center">
                <a className="button radius" href="" onClick={this.showCalculatorModal}>Bandwidth Calculator</a>
              </div>
            </div>

            <div className="postscript">
              <div>
                <h4>All plans include:</h4>
                <ul className="features">
                  <li>HD live-streaming</li>
                  <li>native mobile support (iOS and Android)</li>
                  <li>archiving / recording of streams</li>
                  <li>distribution via our <strong>global CDN</strong></li>
                  <li><strong>no ads</strong> of any kind</li>
                  <li><a href="http://cineio.uservoice.com">email</a> {" + "}
                  <strong><a href="https://www.hipchat.com/gZCLRQ9Ih">live chat support</a></strong>
                  &nbsp;from our developers</li>
                </ul>
              </div>

              <div>
                <h4>What if I exceed my usage limits?</h4>
                <p>
                  As long as you&apos;re on one of our paid plans, if you
                  exceed your usage limits, we&apos;ll automatically upgrade
                  you to the next plan and notify you. However, if you exceed
                  the limits while of our free&nbsp;
                  <strong>Developer</strong> plan, you won&apos;t be able to
                  continue to use your account until you enter a credit card.
                </p>
              </div>
            </div>

            <div className="whats-included">
            </div>

          </div>
        </section>
      </div>
    );
  }
});
