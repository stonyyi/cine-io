HistoricalSlug = Cine.model('historical_slug')
Organization = Cine.model('organization')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'HistoricalSlug', ->
  beforeEach resetMongo

  modelTimestamps HistoricalSlug, owner: new Organization, _id: 'some-id'

  describe 'ownerType and ownerId', ->
    it 'reflects an object', (done)->
      organization = new Organization
      attributes = owner: organization, _id: 'the-slug'
      slug = new HistoricalSlug(attributes)
      slug.save (err)->
        expect(err).to.be.null
        HistoricalSlug.findById 'the-slug', (err, hs)->
          expect(hs._id).to.equal("the-slug")
          expect(hs.ownerId.toString()).to.equal(organization._id.toString())
          expect(hs.ownerType).to.equal("Organization")
          done(err)
