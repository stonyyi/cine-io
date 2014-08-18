Account = Cine.server_model("account")
User = Cine.server_model("user")
Project = Cine.server_model("project")
_ = require('underscore')
addNextStreamToProject = Cine.server_lib('add_next_stream_to_project')
createNewAccount = Cine.server_lib('create_new_account')

describe 'createNewAccount', ->

  it 'creates a new acccount'
  it 'adds a plan to the account'
  it 'adds a billing source to the account'
  it 'creates a user'
  it 'creates a project linked to the account'
  it 'creates a stream associated with the project'

  it "adds a herokuId when it's from heroku"

  describe 'with an existing user', ->
    it 'adds the new account to the same user'
