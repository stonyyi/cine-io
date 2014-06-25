response =
  login: "growlypants"
  id: 135461
  avatar_url: "https://avatars.githubusercontent.com/u/135461?"
  gravatar_id: "bba54c3a83562ed78608ce44e7d60c4a"
  url: "https://api.github.com/users/growlypants"
  html_url: "https://github.com/growlypants"
  followers_url: "https://api.github.com/users/growlypants/followers"
  following_url: "https://api.github.com/users/growlypants/following{/other_user}"
  gists_url: "https://api.github.com/users/growlypants/gists{/gist_id}"
  starred_url: "https://api.github.com/users/growlypants/starred{/owner}{/repo}"
  subscriptions_url: "https://api.github.com/users/growlypants/subscriptions"
  organizations_url: "https://api.github.com/users/growlypants/orgs"
  repos_url: "https://api.github.com/users/growlypants/repos"
  events_url: "https://api.github.com/users/growlypants/events{/privacy}"
  received_events_url: "https://api.github.com/users/growlypants/received_events"
  type: "User"
  site_admin: false
  name: "Thomas Shafer"
  company: "Giving Stage"
  blog: "https://www.givingstage.com"
  location: "San Francisco, CA"
  email: "thomas@givingstage.com"
  hireable: false
  bio: null
  public_repos: 18
  public_gists: 45
  followers: 14
  following: 10
  created_at: "2009-10-05T20:24:38Z"
  updated_at: "2014-06-25T00:14:53Z"

module.exports = ->
  nock('https://api.github.com:443')
    .get('/user?access_token=5b375ac2ddd691be9a8468877ea38ad3ba86f440')
    .reply(200, response)
