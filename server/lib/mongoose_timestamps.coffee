timestampsPlugin = (schema, options) ->
  schema.add
    createdAt:
      type: Date
      default: new Date
    updatedAt:
      type: Date

  schema.pre "save", (next)->
    if @isNew
      @updatedAt = @createdAt
    else
      @updatedAt = new Date
    next()

module.exports = timestampsPlugin
