/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'Marketplaces',
  render: function() {
    var squareSize = 32;
      multiplier = 2;
    squareSize *= multiplier;
    return (
      <section id="marketplaces">
        <div className="row text-center">
          <div className="medium-12 columns">
            <h2 className="bottom-margin-1">
              We work where you work.
            </h2>
            <p>
              cine.io supports one-click deployment with many popular PaaS providers, and can integrate with virtually any cloud infrastructure.
            </p>
            <ul className="icon-list">
              <li>
                <a target="_blank" href='https://addons.heroku.com/cine'>
                  <img src="/images/partner-logos/heroku.png" alt="Heroku logo" title="Heroku Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://console.run.pivotal.io/marketplace/cine-io'>
                  <img src="/images/partner-logos/engineyard.png" alt="PWS logo" title="Pivotal Web Services Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://addons.engineyard.com/addons/cineio'>
                  <img src="/images/partner-logos/pivotal-web-services.png" alt="Engineyard logo" title="Engineyard Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://marketplace.openshift.com/apps/14079'>
                  <img src="/images/partner-logos/redhat-openshift.png" alt="OpenShift logo" title="OpenShift Addon" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://marketplace.samsungknox.com/apps/639'>
                  <img src="/images/partner-logos/samsung-knox.png" alt="Samsung Knox logo" title="Samsung Knox Marketplace" />
                </a>
              </li>
            </ul>
          </div>
        </div>
      </section>
    );
  }
});
