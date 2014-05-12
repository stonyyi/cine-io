Organization = Cine.model('organization')
HistoricalSlug = Cine.model('historical_slug')
modelTimestamps = Cine.require('test/helpers/model_timestamps')

describe 'Organization', ->
  modelTimestamps(Organization, name: 'hey')

  describe 'slug', ->

    it 'has a unique slug based on name', (done)->
      organization = new Organization(name: 'amnesty international')
      organization.save (err)->
        expect(err).to.be.null
        expect(organization.slug).to.equal('amnesty-international')
        HistoricalSlug.count (err,count)->
          expect(count).to.equal(0)
          done()

    it "creates a historical slug when the slug changes", (done)->
      organization = new Organization(name: 'amnesty international')
      organization.save (err)->
        expect(err).to.be.null
        expect(organization.slug).to.equal('amnesty-international')
        organization.slug = 'new-slug'
        organization.save (err)->
          expect(organization.slug).to.equal('new-slug')
          HistoricalSlug.count (err,count)->
            expect(count).to.equal(1)
            HistoricalSlug.findById 'amnesty-international', (err, hs)->
              expect(hs._id).to.equal("amnesty-international")
              expect(hs.ownerId.toString()).to.equal(organization._id.toString())
              expect(hs.ownerType).to.equal("Organization")
              done(err)

  describe 'api_key', ->
    it 'has a unique api_key generated on save', (done)->
      org = new Organization(name: 'some name')
      org.save (err)->
        expect(err).to.be.null
        expect(org.apiKey.length).to.equal(48)
        done()

    it 'will not override the password change request on future saves', (done)->
      org = new Organization(name: 'some name')
      org.save (err)->
        expect(err).to.be.null
        apiKey = org.apiKey
        expect(apiKey.length).to.equal(48)
        org.save (err)->
          expect(org.apiKey).to.equal(apiKey)
          done(err)
