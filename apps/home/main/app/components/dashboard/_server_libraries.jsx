/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'ServerLibraries',
  render: function() {
    return (
      <div>
        <h4 className='top-margin-1'>Server side libraries</h4>
        <ul className="inline-list">
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-ruby'>
              <img width='36' height='36' src="/images/code-logos/ruby-logo.png" alt="Ruby logo" title="The Ruby Gem" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-python'>
              <img width='36' height='36' src="/images/code-logos/python-logo.png" alt="Python logo" title="The Python Egg" />
            </a>
          </li>
          <li>
            <a target="_blank" href='https://github.com/cine-io/cineio-node'>
              <img width='36' height='36' src="/images/code-logos/nodejs-logo.png" alt="Node.js logo" title="The Node.js Package" />
            </a>
          </li>
        </ul>

      </div>
    )
  }
});
