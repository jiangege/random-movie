require! {
  tingodb
  async
  "node-localstorage": {
    JSONStorage
  }
}
{Db} = tingodb()



db = new Db "#{__dirname}/data", searchInArray: true
jsonStorage = new JSONStorage "#{__dirname}/data/localStorage"

addMovie = (movie, cb = ->) ->
  col = db.collection \movies
  (err) <~ col.createIndex "classification", _tiarr: true
  return cb ... if err
  col.update {
    id: movie.id
  }, {
    $set: movie
  }, {
    upsert: true
  }, cb


randomMovie = ({
    ciAry = []
    rank = 0
    limit = 1
    excludeIds = []
}, cb = ->) ->
  col = db.collection \movies
  ciAry = ciAry.map (v) ->
    classification:
      $regex: v
  err, count <~ col.count {
    $or: ciAry
    rank:
      $gte: rank
    id: $nin: excludeIds
  }

  return cb err if err
  limit := limit <? count

  rAry = for i from 0 til limit
    Math.floor Math.random! * count

  resultAry = []
  async.eachSeries rAry, (r, cb) ->
    err, obj <~ col.findOne {
      $or: ciAry
      rank:
        $gte: rank
      id: $nin: excludeIds
    }, {
      limit: 1
      skip: r
    }
    if not err and obj?
      resultAry.push obj
    cb null
  , (err) ->
    unless err
      resultAry.sort (a, b) -> if a.rank < b.rank then 1 else -1

    cb err, {
      count,
      resultAry
    }

smartRandomMovieOne = (opts, cb = ->) ->
  opts = ^^opts
  opts <<< {
    limit: 1
    excludeIds: getIgnoreMovie!
  }
  err, data <- randomMovie opts
  return cb err if err
  cb null, {
    count: data.count
    movie: data.resultAry[0] or null
  }

getIgnoreMovie = ->
  igms = jsonStorage.getItem "ignoreMovie" or []

cleanIgnoreMovie = ->
  jsonStorage.removeItem \ignoreMovie

ignoreMovie = (id) ->
  igms = jsonStorage.getItem "ignoreMovie" or []
  igms.push id
  jsonStorage.setItem "ignoreMovie", igms

module.exports = {
  addMovie
  smartRandomMovieOne
  ignoreMovie
  cleanIgnoreMovie
}
