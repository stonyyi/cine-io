deleteUser = Cine.server_lib('delete_user')
User = Cine.server_model('user')

describe 'deleteUser', ->

  beforeEach (done)->
    @user = new User(plan: 'test')
    @user.save done

  beforeEach (done)->
    deleteUser @user, done

  it "adds deletedAt to a user", (done)->
    User.findById @user._id, (err, user)->
      expect(err).to.be.null
      expect(user.deletedAt).to.be.instanceOf(Date)
      done()
