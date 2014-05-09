mongoose = require 'mongoose'
mongooseUniqueSlugs = require 'mongoose-uniqueslugs'
mongooseHistoricalSlugs = SS.lib 'mongoose_historical_slugs'
_ = require('underscore')

OrganizationSchema = new mongoose.Schema
  name:
    type: String
    default: ''
  images:
    profileUrl:
      type: String
  # slug # added by mongooseUniqueSlugs

mongooseUniqueSlugs.enhanceSchema(OrganizationSchema, source: 'name')
OrganizationSchema.plugin(mongooseHistoricalSlugs)

OrganizationSchema.plugin(SS.lib('mongoose_timestamps'))

OrganizationSchema.options.toJSON ||= {}
OrganizationSchema.options.toJSON.transform = (doc, ret, options)->
  ret.createdAt = ret.createdAt.toISOString()
  ret

Organization = mongoose.model 'Organization', OrganizationSchema

mongooseUniqueSlugs.enhanceModel(Organization)

module.exports = Organization
