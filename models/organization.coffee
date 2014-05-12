mongoose = require 'mongoose'
mongooseUniqueSlugs = require 'mongoose-uniqueslugs'
mongooseHistoricalSlugs = Cine.lib 'mongoose_historical_slugs'
crypto = require('crypto')

OrganizationSchema = new mongoose.Schema
  name:
    type: String
    default: ''
  apiKey:
    type: String
    unique: true
    index: true
  images:
    profileUrl:
      type: String
  # slug # added by mongooseUniqueSlugs

mongooseUniqueSlugs.enhanceSchema(OrganizationSchema, source: 'name')
OrganizationSchema.plugin(mongooseHistoricalSlugs)

OrganizationSchema.plugin(Cine.lib('mongoose_timestamps'))

OrganizationSchema.pre 'save', (next)->
  return next() if @apiKey
  crypto.randomBytes 24, (ex, buf)=>
    @apiKey = buf.toString('hex')
    next()

OrganizationSchema.options.toJSON ||= {}
OrganizationSchema.options.toJSON.transform = (doc, ret, options)->
  ret.createdAt = ret.createdAt.toISOString()
  ret

Organization = mongoose.model 'Organization', OrganizationSchema

mongooseUniqueSlugs.enhanceModel(Organization)

module.exports = Organization
