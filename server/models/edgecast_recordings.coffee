mongoose = require 'mongoose'
Schema = mongoose.Schema
findOrCreate = require('mongoose-findorcreate')
_ = require('underscore')

EdgecastRecording = new Schema
  name: String
  size: Number
  date: Date
  deletedAt: Date
  vodBookkeeperTest: Boolean

EdgecastRecordingsSchema = new Schema
  _edgecastStream:
    type: mongoose.Schema.Types.ObjectId
    ref: 'EdgecastStream'
  recordings: [EdgecastRecording]

EdgecastRecordingsSchema.plugin(Cine.server_lib('mongoose_timestamps'))

EdgecastRecordingsSchema.plugin(findOrCreate)

# if the entry was created after this month then false
# if the entry was created before this month but deleted before this month then false
activeInSameMonth = (entry, dateToCheck)->
  entryCreatedAt = entry.date
  # created after this month
  return false if entryCreatedAt.getFullYear() > dateToCheck.getFullYear()
  return false if entryCreatedAt.getFullYear() == dateToCheck.getFullYear() && entryCreatedAt.getMonth() > dateToCheck.getMonth()
  # ok now the entry was created before or during this month
  # return true if the entry is still active
  return true unless entry.deletedAt?
  entryDeletedAt = entry.deletedAt
  # return false if it was deleted before this year
  return false if entryDeletedAt.getFullYear() < dateToCheck.getFullYear()
  # return false if it was deleted before this month on this year
  return false if entryDeletedAt.getFullYear() <= dateToCheck.getFullYear() && (entryDeletedAt.getMonth() <= dateToCheck.getMonth())
  # return true because it was deleted after this month, and therefor in use during this month
  return true

# dateToCheck is a full date
EdgecastRecordingsSchema.methods.bytesForMonth = (dateToCheck)->
  addBytesIfSameMonth = (accum, entry)->
    if activeInSameMonth(entry, dateToCheck)
      accum + entry.size
    else
      accum
   _.chain(@recordings).where(vodBookkeeperTest: undefined).reduce(addBytesIfSameMonth, 0).value()

EdgecastRecordingsSchema.methods.totalBytes = ->
  accumEntryBytes = (accum, entry)->
    accum + entry.size

  _.chain(@recordings)
    .where(deletedAt: undefined)
    .where(vodBookkeeperTest: undefined)
    .reduce(accumEntryBytes, 0)
    .value()

EdgecastRecordings = mongoose.model 'EdgecastRecordings', EdgecastRecordingsSchema

module.exports = EdgecastRecordings
