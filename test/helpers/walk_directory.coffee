fs = require("fs")

# http://stackoverflow.com/questions/5827612/node-js-fs-readdir-recursive-directory-search
walkDirectory = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err)  if err
    pending = list.length
    return done(null, results)  unless pending
    list.forEach (file) ->
      file = dir + "/" + file
      fs.stat file, (err, stat) ->
        if stat and stat.isDirectory()
          walkDirectory file, (err, res) ->
            results = results.concat(res)
            done null, results  unless --pending
            return

        else
          results.push file
          done null, results  unless --pending

module.exports = walkDirectory
