timestampsPlugin = (schema, options) ->
  schema.add
    createdAt:
      type: Date
      default: Date.now
    updatedAt:
      type: Date

  schema.pre "save", (next)->
    if @isNew
      @updatedAt = @createdAt
    else
      @updatedAt = new Date
    next()

module.exports = timestampsPlugin
