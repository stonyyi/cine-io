AccountThrottler = Cine.server_lib('account_throttler')
Account = Cine.server_model('account')
Project = Cine.server_model('project')

describe 'AccountThrottler', ->
  beforeEach (done)->
    @account = new Account(billingProvider: 'cine.io')
    @account.save done
  beforeEach (done)->
    @accountProject1 = new Project(_account: @account._id)
    @accountProject1.save done
  beforeEach (done)->
    @accountProject2 = new Project(_account: @account._id)
    @accountProject2.save done
  beforeEach (done)->
    @notAccountProject = new Project
    @notAccountProject.save done

  describe '.throttle', ->
    beforeEach ->
      expect(@account.throttledAt).to.be.undefined
      expect(@accountProject1.throttledAt).to.be.undefined
      expect(@accountProject2.throttledAt).to.be.undefined
      expect(@notAccountProject.throttledAt).to.be.undefined

    describe 'without a throttle date', ->
      beforeEach (done)->
        AccountThrottler.throttle @account, 'overLimit', (err, @savedAccount)=>
          done(err)

      it 'returns the account', ->
        expect(@savedAccount._id.toString()).to.equal(@account._id.toString())
        expect(@savedAccount.throttledAt).to.be.instanceOf(Date)
        expect(@savedAccount.throttledReason).to.equal('overLimit')

      it 'throttles an account', (done)->
        Account.findById @account._id, (err, account)->
          expect(err).to.be.null
          expect(account.throttledAt).to.be.instanceOf(Date)
          expect(account.throttledReason).to.equal('overLimit')
          done()

      it 'throttles the projects of the account', (done)->
        Project.findById @accountProject1._id, (err, project1)=>
          expect(err).to.be.null
          expect(project1.throttledAt).to.be.instanceOf(Date)
          Project.findById @accountProject2._id, (err, project2)=>
            expect(err).to.be.null
            expect(project2.throttledAt).to.be.instanceOf(Date)
            Project.findById @notAccountProject._id, (err, notAccountProject)->
              expect(err).to.be.null
              expect(notAccountProject.throttledAt).to.be.undefined
              done()

    describe 'with a throttle date', ->
      beforeEach (done)->
        @throttleDate = new Date
        @throttleDate.setDate(@throttleDate.getDate() + 10)
        AccountThrottler.throttle @account, 'cardDeclined', @throttleDate, (err, @savedAccount)=>
          done(err)

      it 'returns the account', ->
        expect(@savedAccount._id.toString()).to.equal(@account._id.toString())
        expect(@savedAccount.throttledAt.toString()).to.equal(@throttleDate.toString())
        expect(@savedAccount.throttledReason).to.equal('cardDeclined')

      it 'throttles an account', (done)->
        Account.findById @account._id, (err, account)=>
          expect(err).to.be.null
          expect(account.throttledAt.toString()).to.equal(@throttleDate.toString())
          expect(account.throttledReason).to.equal('cardDeclined')
          done()

      it 'throttles the projects of the account', (done)->
        Project.findById @accountProject1._id, (err, project1)=>
          expect(err).to.be.null
          expect(project1.throttledAt.toString()).to.equal(@throttleDate.toString())
          Project.findById @accountProject2._id, (err, project2)=>
            expect(err).to.be.null
            expect(project2.throttledAt.toString()).to.equal(@throttleDate.toString())
            Project.findById @notAccountProject._id, (err, notAccountProject)->
              expect(err).to.be.null
              expect(notAccountProject.throttledAt).to.be.undefined
              done()

  describe '.unthrottle', ->
    beforeEach (done)->
      @account.throttledAt = @accountProject1.throttledAt = @accountProject2.throttledAt = @notAccountProject.throttledAt = new Date
      @account.throttledReason = 'cardDeclined'
      @account.save (err)=>
        expect(err).to.be.null
        @accountProject1.save (err)=>
          expect(err).to.be.null
          @accountProject2.save (err)=>
            expect(err).to.be.null
            @notAccountProject.save done

    beforeEach ->
      expect(@account.throttledAt).to.be.instanceOf(Date)
      expect(@accountProject1.throttledAt).to.be.instanceOf(Date)
      expect(@accountProject2.throttledAt).to.be.instanceOf(Date)
      expect(@notAccountProject.throttledAt).to.be.instanceOf(Date)

    beforeEach (done)->
      AccountThrottler.unthrottle @account, (err, @savedAccount)=>
        done(err)

    it 'returns the account', ->
      expect(@savedAccount._id.toString()).to.equal(@account._id.toString())
      expect(@savedAccount.throttledAt).to.be.undefined
      expect(@savedAccount.throttledReason).to.be.undefined

    it 'unthrottles an account', (done)->
      Account.findById @account._id, (err, account)->
        expect(err).to.be.null
        expect(account.throttledAt).to.be.undefined
        expect(account.throttledReason).to.be.undefined
        done()
    it 'unthrottles the projects of the account', (done)->
      Project.findById @accountProject1._id, (err, project1)=>
        expect(err).to.be.null
        expect(project1.throttledAt).to.be.undefined
        Project.findById @accountProject2._id, (err, project2)=>
          expect(err).to.be.null
          expect(project2.throttledAt).to.be.undefined
          Project.findById @notAccountProject._id, (err, notAccountProject)->
            expect(err).to.be.null
            expect(notAccountProject.throttledAt).to.be.instanceOf(Date)
            done()
