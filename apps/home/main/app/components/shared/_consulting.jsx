/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'Consulting',
  render: function() {
    return (
      <section id="consulting">
        <div className="row">
          <div className="info text-center">
            <h2>
              Need help building your app?
            </h2>

            <p>
              Bypass your competition by letting us prototype or build your
              app for you.
            </p>

            <p>
              The developers behind cine.io have decades of experience
              building multi-platform, multi-tier web platforms, applications,
              and services. In their previous lives, they built products and
              platforms like <a target="_blank"
              href="https://www.change.org/">Change.org</a>,&nbsp; <a
              target="_blank" href="https://www.givingstage.com/">Giving
              Stage</a>,&nbsp; and <a target="_blank"
              href="https://www.ironport.com">IronPort Systems</a>.
            </p>

            <p>
               <a className="button radius primary" target="_blank" href="mailto:support@cine.io?subject=Business+Inquiry">
                 Talk to us
               </a>
            </p>

          </div>
        </div>
      </section>
    );
  }
});
