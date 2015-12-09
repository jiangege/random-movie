require! {
  "./crawler": {
    MovieCrawler
  }
  "./persistence": {
    addMovie
    smartRandomMovieOne
    ignoreMovie
    cleanIgnoreMovie
  }
  "./log": {
    logWarning
    logError
    logInfo
    logSuccess
  }
  "cli-spinner":{
    Spinner
  }
  async
  prompt
}


mc = new MovieCrawler

execGrap = (cb = ->) ->
  mc.grab (movieList, next)->
    async.eachSeries movieList, (movie, cb) ->
      err <~ addMovie movie
      if err
        logError "持久化<<#{movie.title}>>失败"
      else
        logInfo "持久化<<#{movie.title}>>成功"
      cb!
    , next
  , cb


execSmartRandomMovie = (opts) ->
  console.log "\r"
  spinner = new Spinner "  🎥  找电影呀找电影 %s ".bold.green
  spinner.setSpinnerString '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  spinner.start!

  err, data <- smartRandomMovieOne opts
  spinner.stop!
  if err or not data.movie?
    return console.log "\r\n未找到任何电影!!".bold.red
  {
    movie
    count
  } = data
  downloadURLStr = ""
  movie.downloadURL.forEach (v) ->
    downloadURLStr += "  #{v}".underline.bold+"\r\n"

  desc = """\r
    片名: #{movie.title.bold.blue}\r
    分类: #{movie.classification}
    评分: #{(movie.rank + "").bold.red}
    详细: #{movie.link.underline.bold}\r\n
    下载链接:\r
    #{downloadURLStr}\r\n
    该类目下共计: (#{count}) 个资源\r\n
  """
  console.log desc

  prompt.message = "🎥"
  prompt.start!
  err, result <- prompt.get {
    properties:
      seen:
        description: "看过了? y/n"
  }
  return if err
  {seen} = result
  if seen is "y"
    ignoreMovie movie.id

execClean = ->
  cleanIgnoreMovie!
  console.log "清除完毕!".green

module.exports = {
  execGrap
  execSmartRandomMovie
  execClean
}
