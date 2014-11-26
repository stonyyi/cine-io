/** @jsx React.DOM */
var
  React = require('react'),
  _ = require('underscore'),
  ProvidersAndPlans = Cine.require('config/providers_and_plans'),
  UsageReport = Cine.model('usage_report'),
  humanizeBytes = Cine.lib('humanize_bytes');

module.exports = React.createClass({
  mixins: [Cine.lib('requires_app')],
  displayName: 'Pricing',

  getApiKey: function(plan, value, e){
    e.preventDefault();

    this.props.app.tracker.getApiKey({value: value});
    this.props.app.trigger('set-signup-plan', plan);
    this.props.app.trigger('show-login');
  },

  showCalculatorModal: function(e) {
    e.preventDefault();
    this.props.app.trigger('show-modal', 'homepage/_bandwidth_calculator');
  },

  getPlanRows: function(plans, mobile) {
    // console.log("plans=", plans);
    var
      self = this,
      rows = plans.map(function(plan, i) {
        var
          planName = plan.name.charAt(0).toUpperCase() + plan.name.slice(1),
          streams = (typeof(plan.streams) === "string") ? plan.streams.charAt(0).toUpperCase() + plan.streams.slice(1) : plan.streams;
          bandwidth = humanizeBytes(plan.bandwidth, ',', 0),
          storage = humanizeBytes(plan.storage, ',', 0),
          cost = (plan.price === 0) ? "Free" : "$" + plan.price.toFixed(0).replace(/\d(?=(\d{3})+$)/g, '$&,');

        if (mobile) {
          return (
            <tr>
              <td className="plan-name">{planName}</td>
              <td>
                <strong>Streams:</strong> {streams}<br/>
                <strong>Xfer:</strong> {bandwidth}<br/>
                <strong>Storage:</strong> {storage}<br/>
                <strong>Cost:</strong> {cost}<br/><br/>
                <a className="button tiny radius" href="" onClick={self.getApiKey.bind(self, plan.name, i+1)}>Select</a><br/>
              </td>
            </tr>
          )
        } else {
          return (
            <tr>
              <td className="plan-name">{planName}</td>
              <td>{streams}</td>
              <td>{bandwidth}</td>
              <td>{storage}</td>
              <td className="cost">{cost}</td>
              <td><a className="button tiny radius" href="" onClick={self.getApiKey.bind(self, plan.name, i+1)}>Select</a></td>
            </tr>
          )
        }
      });

    return rows;
  },

  render: function() {

    var cinePlans = UsageReport.sortedCinePlans(),
      mobilePlanRows = this.getPlanRows(cinePlans, true),
      planRows = this.getPlanRows(cinePlans, false);

    return (
      <div>
       <section id="pricing">
          <div className="info">
            <h2>Simple, developer-friendly pricing.</h2>

            <div className="prices">
              <table className="hide-for-medium-up">
                <tbody>
                  {mobilePlanRows}
                  <tr>
                    <td className="plan-name">Custom</td>
                    <td>
                      <strong>Streams:</strong> Unlimited<br/>
                      <strong>Xfer:</strong> &gt;15 TiB<br/>
                      <strong>Storage:</strong> &gt;=1 TiB<br/>
                      <strong>Cost:</strong> Negotiable<br/><br/>
                      <a className="button tiny radius" target="_blank" href="mailto:support@cine.io?subject=Business+Inquiry">Talk to Us</a><br/>
                    </td>
                  </tr>
                </tbody>
              </table>
              <table className="show-for-medium-up">
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
                  {planRows}
                  <tr>
                    <td className="plan-name">Custom</td>
                    <td>Unlimited</td>
                    <td>&gt; 15 TiB</td>
                    <td>&gt;= 1 TiB</td>
                    <td className="cost">Negotiable</td>
                    <td><a className="button tiny radius" target="_blank" href="mailto:support@cine.io?subject=Business+Inquiry">Talk to Us</a></td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div className="row show-for-medium-up">
              <div className="column-12 columns text-center">
                <a className="button radius" href="" onClick={this.showCalculatorModal}>Bandwidth Calculator</a>
              </div>
            </div>

          </div>

          <div className="postscript">
            <div className="limits">
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

            <div className="included">
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
                <li>Discounts for inbound links to cine.io.</li>
              </ul>
            </div>

            <div className="byo-cdn">
              <h4>Already paying for a CDN?</h4>
              <p>
                If you already have an RTMP-capable CDN configured (such as
                Akamai, EdgeCast, or Level3), we can probably help you integrate
                it with our infrastructure so that you can save on bandwidth
                costs. Consulting fees may apply.

                <div className="text-center">
                  <a className="button radius" target="_blank" href="mailto:support@cine.io?subject=Business+Inquiry">Talk to Us</a>
                </div>
              </p>
            </div>
          </div>

        </section>
      </div>
    );
  }
});
