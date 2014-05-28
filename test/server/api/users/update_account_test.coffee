User = Cine.server_model('user')
UpdateAccount = testApi Cine.api('users/update_account')

describe 'UpdateAccount', ->

  it "updates the user fields", (done)->
    u = new User name: 'Mah name', email: 'mah email'
    u.save (err)->
      expect(err).to.equal(null)
      params = {name: 'New Name', email: 'new email'}
      session = {user: u}
      callback = (err, response)->
        expect(err).to.equal(null)
        expect(response.name).to.equal('New Name')
        expect(response.email).to.equal('new email')
        User.findById u._id, (err, user)->
          expect(user.name).to.equal('New Name')
          expect(user.email).to.equal('new email')
          done()

      UpdateAccount params, session, callback

  describe "won't overwrite with blank values", ->
    it "won't overwrite with blank name", (done)->
      u = new User name: 'Mah name', email: 'mah email'
      u.save (err)->
        expect(err).to.equal(null)
        params = {name: '', email: 'new email'}
        session = {user: u}
        callback = (err, response)->
          expect(err).to.equal(null)
          expect(response.name).to.equal('Mah name')
          expect(response.email).to.equal('new email')
          User.findById u._id, (err, user)->
            expect(user.name).to.equal('Mah name')
            expect(user.email).to.equal('new email')
            done()

        UpdateAccount params, session, callback

    it "won't overwrite with blank email", (done)->
      u = new User name: 'Mah name', email: 'mah email'
      u.save (err)->
        expect(err).to.equal(null)
        params = {name: 'New Name', email: ''}
        session = {user: u}
        callback = (err, response)->
          expect(err).to.equal(null)
          expect(response.name).to.equal('New Name')
          expect(response.email).to.equal('mah email')
          User.findById u._id, (err, user)->
            expect(user.name).to.equal('New Name')
            expect(user.email).to.equal('mah email')
            done()

        UpdateAccount params, session, callback
