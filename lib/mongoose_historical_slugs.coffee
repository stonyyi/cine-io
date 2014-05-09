HistoricalSlug = SS.model('historical_slug')

# conflict ways
# 1: slug on actual models conflict (easy, unique index check)
# 2: slug on model conflicts with historical slug _id

module.exports = (schema)->

  slugSaver = (newSlug)->
    if @slug? && @slug != newSlug
      @_oldSlug = @slug
    return newSlug

  # make sure the new slug doesn't conflict with history
  checkConflictingHistoricalSlug = (callback)->
    HistoricalSlug.findOne _id: @slug, ownerType: this.constructor.modelName, (err, hs)=>
      return callback(err) if err
      if hs
        @invalidate("slug","slug must be unique")
        return callback(new Error("slug must be unique"))
      callback()

  createHistoricalSlug = (next)->
    checkConflictingHistoricalSlug.call this, (err)=>
      return next(err) if err
      historicalSlug = new HistoricalSlug(owner: this, _id: @_oldSlug)
      historicalSlug.save next

  createHistoricalSlugIfNecessary = (next)->
    return next() unless @_oldSlug
    return next() if @isNew
    createHistoricalSlug.call(this, next)

  schema.pre 'save', createHistoricalSlugIfNecessary

  schema.path('slug').set slugSaver
