require! {
  tingodb
  async
}
{Db} = tingodb()



db = new Db "#{__dirname}/data", searchInArray: true


addMovie = (movie, cb = ->) ->
  col = db.collection \movies
  (err) <~ col.update {
    id: movie.id
  },{
    $set: movie
  },{
    upsert: true
  }
  cb ...


random = ({
    ciAry = ["恐怖"]
    rank = 6.0
    limit = 1
}, cb = ->) ->
  col = db.collection \movies
  ciAry = ciAry.map (v)->
    classification:
      $regex: v
  err, count <~ col.count {
    $or: ciAry
    rank:
      $gte: rank
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

    cb err, resultAry



module.exports = {
  addMovie
}


err, docs <~ random {rank: 6}
console.log docs
