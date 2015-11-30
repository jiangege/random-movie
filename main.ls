require! {
  "./crawler": {
    MovieCrawler
  }
  "./persistence": {
    addMovie
  }
  "./log": {
    logWarning
    logError
    logInfo
    logSuccess
  }
}

mc = new MovieCrawler

mc.grab (movie)->
  err <~ addMovie movie
  if err
    logError "持久化<<#{movie.title}>>失败"
  else
    logInfo "持久化<<#{movie.title}>>成功"
, ->
