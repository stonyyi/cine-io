/** @jsx React.DOM */
var
  React = require('react');

module.exports = React.createClass({
  displayName: 'BroadcastDocumentation',
  render: function() {
    return (
      <div>
        <h4 className='top-margin-1'>
          <a target="_blank" href='http://developer.cine.io'>Full documentation</a>
        </h4>
        <h4 className='top-margin-1'>Client libraries</h4>
        <ul className="inline-list">
          <li>
            <a target="_blank" href='https://github.com/cine-io/peer-js-sdk'>
              <img width='36' height='36' src="/images/code-logos/javascript-logo.png" alt="JavaScript logo" title="The JavaScript SDK" />
            </a>
          </li>
        </ul>
      </div>
    )
  }
});
