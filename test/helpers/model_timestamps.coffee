module.exports = (Model, attributes={})->
  describe 'timestamps', ->
    beforeEach resetMongo

    it 'adds a createdAt and updatedAt', (done)->
      expect(attributes.createdAt).to.be.undefined
      e = new Model(attributes)
      expect(e.createdAt).to.be.instanceof(Date)
      expect(e.updatedAt).to.be.undefined
      e.save (err)->
        expect(err).to.be.null
        expect(e.createdAt).to.be.instanceof(Date)
        expect(e.updatedAt).to.be.instanceof(Date)
        expect(e.createdAt).to.equal(e.updatedAt)
        done()

    it 'changes the updatedAt on save', (done)->
      expect(attributes.createdAt).to.be.undefined
      e = new Model(attributes)
      expect(e.createdAt).to.be.instanceof(Date)
      expect(e.updatedAt).to.be.undefined
      e.save (err)->
        expect(err).to.be.null
        e.save (err)->
          expect(err).to.be.null
          expect(e.createdAt).not.to.equal(e.updatedAt)
          done()
