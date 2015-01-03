/** @jsx React.DOM */
var React = require('react');

module.exports = React.createClass({
  displayName: 'Libraries',
  render: function() {
    var squareSize = 32;
      multiplier = 2;
    squareSize *= multiplier;
    return (
      <section id="libraries">
        <div className="row text-center">
          <div className="medium-12 columns">
            <h2 className="bottom-margin-2">
              We speak your language.
            </h2>
            <ul className="icon-list">
              <li>
                <a target="_blank" href='https://github.com/cine-io/js-sdk'>
                  <img src="/images/code-logos/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-broadcast-ios'>
                  <img src="/images/code-logos/ios-logo.png" alt="iOS logo" title="The iOS SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-broadcast-android'>
                  <img src="/images/code-logos/android-logo.png" alt="Android logo" title="The Android SDK" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-ruby'>
                  <img src="/images/code-logos/ruby-logo.png" alt="Ruby logo" title="The Ruby Gem" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-python'>
                  <img src="/images/code-logos/python-logo.png" alt="Python logo" title="The Python Egg" />
                </a>
              </li>
              <li>
                <a target="_blank" href='https://github.com/cine-io/cineio-node'>
                  <img src="/images/code-logos/nodejs-logo.png" alt="Node.js logo" title="The Node.js Package" />
                </a>
              </li>
              <li className="show-for-medium-up">
                <a target="_blank" href='https://github.com/cine-io'>
                  <img src="/images/code-logos/github-logo.png" alt="GitHub logo" title="Find us on GitHub" />
                </a>
              </li>
            </ul>
            <div>
              <p>Working in another framework / language? Don&apos;t sweat it. Our <a target="_blank" href='http://developer.cine.io'>REST API</a> has you covered.</p>
            </div>
            <div className="developer-actions">
              <div>
                <a target="_blank" href='http://developer.cine.io' className="button radius">View Docs</a>
              </div>
              <div>
                <a target="_blank" href="http://devchat.cine.io" className="button radius">Developer chat</a>
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }
});
