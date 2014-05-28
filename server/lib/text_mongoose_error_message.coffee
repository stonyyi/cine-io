# loosely based off http://stackoverflow.com/questions/8986556/custom-user-friendly-validatorerror-message
module.exports = (err) ->

  #If it isn't a mongoose-validation error, just throw it.
  return err  if err.name isnt "ValidationError"

  messages =
    required: "%s is required."
    min: "%s below minimum."
    max: "%s above maximum."
    enum: "%s not an allowed value."


  #A validationerror can contain more than one error.
  errors = []

  #Loop over the errors object of the Validation Error
  Object.keys(err.errors).forEach (field) ->
    eObj = err.errors[field]

    if eObj.type == 'user defined'
      errors.push "#{eObj.path} #{eObj.message}."

    else if messages.hasOwnProperty(eObj.type)
      errors.push require("util").format(messages[eObj.type], eObj.path)

    else
      eObj.message

  errors[0]
