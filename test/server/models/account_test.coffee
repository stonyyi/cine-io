Account = Cine.server_model('account')
_ = require('underscore')
modelTimestamps = Cine.require('test/helpers/model_timestamps')
Project = Cine.server_model('project')
ProvidersAndPlans = Cine.config('providers_and_plans')

describe 'Account', ->
  modelTimestamps(Account, productPlans: {broadcast: ['pro']}, billingProvider: 'cine.io')

  describe 'validations', ->
    describe 'billingProvider', ->
      _.each _.keys(ProvidersAndPlans), (billingProvider)->
        it "can accept #{billingProvider}", (done)->
          account = new Account(billingProvider: billingProvider)
          account.save (err, member)->
            done(err)

      it 'cannot be anything else', (done)->
        account = new Account(name: 'some name', billingProvider: 'NOT A PROVIDER')
        account.save (err, member)->
          expect(err).not.to.be.null
          done()

      it 'cannot be null', (done)->
        account = new Account
        account.save (err, member)->
          expect(err.errors.billingProvider.message).to.equal('Invalid billing provider')
          done()

    describe 'plans', ->

      it 'cannot be an unknown value', (done)->
        account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['enterprise'], peer: ["undefined"]})
        account.save (err, member)->
          expect(member.productPlans.peer).to.have.length(0)
          expect(member.productPlans.broadcast).to.have.length(1)
          expect(member.productPlans.broadcast[0]).to.equal('enterprise')
          done()

      it 'will preserve the known value', (done)->
        account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['enterprise'], peer: ["free", "undefined"]})
        account.save (err, member)->
          expect(member.productPlans.peer).to.have.length(1)
          expect(member.productPlans.peer[0]).to.equal('free')
          expect(member.productPlans.broadcast).to.have.length(1)
          expect(member.productPlans.broadcast[0]).to.equal('enterprise')
          done()

      it 'cannot be a strange value', (done)->
        account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['enterprise'], peer: "wtf"})
        account.save (err, member)->
          expect(member.productPlans.peer).to.have.length(0)
          expect(member.productPlans.broadcast).to.have.length(1)
          expect(member.productPlans.broadcast[0]).to.equal('enterprise')
          done()

    describe 'throttledReason', ->

      _.each ['cardDeclined', 'overLimit'], (throttledReason)->
        it "can accept #{throttledReason}", (done)->
          account = new Account(billingProvider: 'cine.io', throttledReason: throttledReason)
          account.save (err, member)->
            done(err)

      it 'cannot be anything else', (done)->
        account = new Account(billingProvider: 'cine.io', throttledReason: 'NOT A REASON')
        account.save (err, member)->
          expect(err.errors.throttledReason.message).to.equal('Invalid throttledReason')
          done()

      it 'can be unset', (done)->
        account = new Account(billingProvider: 'cine.io', throttledReason: 'cardDeclined')
        account.save (err, member)->
          expect(err).to.be.null
          account.throttledReason = undefined
          account.save done

  describe 'masterKey', ->
    it 'has a unique masterKey generated on save', (done)->
      account = new Account(billingProvider: 'cine.io', name: 'some name', productPlans: {broadcast: ['test']})
      account.save (err)->
        expect(err).to.be.null
        expect(account.masterKey.length).to.equal(64)
        done()

    it 'will not override the masterKey on future saves', (done)->
      account = new Account(billingProvider: 'cine.io', name: 'some name', productPlans: {broadcast: ['test']})
      account.save (err)->
        expect(err).to.be.null
        masterKey = account.masterKey
        expect(masterKey.length).to.equal(64)
        account.save (err)->
          expect(account.masterKey).to.equal(masterKey)
          done(err)

  describe 'streamLimit', ->
    testPlan = (plans..., limit)->
      plans = [plans] unless _.isArray(plans)
      account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: plans})

      expect(account.streamLimit()).to.equal(limit)

    it 'is 1 for free and starter', ->
      testPlan('free', 1)
      testPlan('starter', 1)

    it 'is 5 for solo', ->
      testPlan('solo', 5)

    it 'is 3 for free, free, and free', ->
      testPlan('free', 'free', 'free', 3)

    it 'is 6 for solo and free', ->
      testPlan('solo', 'free', 6)

    it 'is Infinite for basic, pro, test', ->
      testPlan('basic', Infinity)
      testPlan('pro', Infinity)
      testPlan('test', Infinity)

  describe '#projects', ->

    beforeEach (done)->
      @account = new Account(billingProvider: 'cine.io', productPlans: {broadcast: ['test']})
      @account.save done

    beforeEach (done)->
      @ownedProject1 = new Project(name: "in test project", _account: @account._id)
      @ownedProject1.save done
    beforeEach (done)->
      @ownedProject2 = new Project(name: "in test project2", _account: @account._id)
      @ownedProject2.save done
    beforeEach (done)->
      @notOwnedProject = new Project(name: "in test project3")
      @notOwnedProject.save done

    sortedIds = (ary)->
      _.chain(ary).pluck('id').invoke('toString').value().sort()

    it 'returns the projects', (done)->
      @account.projects (err, projects)=>
        expect(err).to.be.null
        expect(projects).to.have.length(2)
        actualIds = sortedIds(projects)
        expectedIds = sortedIds([@ownedProject1, @ownedProject2])
        expect(actualIds).to.deep.equal(expectedIds)
        done()
