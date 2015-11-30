require! {
  fs: {
    readFileSync
  }
  cheerio
  request
  "iconv-lite": iconv
  url
  async
  colors
  "./log": {
    logWarning
    logError
    logInfo
    logSuccess
    logPerimary
  }
}




class MovieCrawler

  (@url = "http://www.dy2018.com/0/") ->
    @networkMaxRetry = 5
    @networkMaxRetryTimeout = 3000

  get: (url, cb) ->
    request.get {
      url
      encoding: null
      timeout: 3000 * 10
    }, (err, res, body) ~>
      return cb err if err
      try
        cb null, cheerio.load iconv.decode(body, 'gb2312'), decodeEntities: false
      catch e
        cb e

  retryGet: (url, cb, retry) ->
    retry++
    if retry <= @networkMaxRetry
      logWarning """
        #{url} 正在重试#{retry}次
      """
      setTimeout ~>
        @smartGet url, cb, retry
      , @networkMaxRetryTimeout
    else
      logError """
        #{url} 获取失败!
      """
      cb new Error "好像无法获取哟~"

  smartGet: (url, cb, retry = 0) ->
    err, $ <~ @get url
    if err
      @retryGet url, cb, retry
    else
      if $(\#menu).length < 1
        return @retryGet url, cb, retry
      cb null, $


  getTotalColumn: (cb) ->
    err, $ <~ @smartGet @url
    return cb err if err
    totalColumn = []
    $(\.co_content2).first().find(\a).map (i, v) ~>
      totalColumn.push url.resolve @url, $(v).attr \href
    cb null, totalColumn

  getTotalPage: (specUrl, cb) ->
    err, $ <~ @smartGet specUrl
    return cb err if err
    totalPage = []
    $(".co_content8 .x select option").each (i, v) ~>
      totalPage.push url.resolve @url, $(v).attr \value
    cb null, totalPage

  getSpecPageMovieList: (specUrl, cb) ->
    err, $ <~ @smartGet specUrl
    return cb err if err
    movieList = []
    $(".co_content8 a[title]").each (i, v) ~>
      movieList.push url.resolve @url, $(v).attr \href

    cb null, movieList

  getMoiveDetail: (specUrl, cb) ->
    err, $ <~ @smartGet specUrl
    return cb err if err
    id = specUrl.match(/(\d+)\.html/)[1]
    title = $(".title_all h1").text!
    rank = (Number) $(".rank").text!
    classification = []
    downloadURL = []
    $(".co_content8 .position a").each (i, v) ~>
      classification.push $(v).text!
    $('a[href^="ftp://"]').each (i, v) ~>
      downloadURL.push $(v).text!

    cb null,{
      id
      title
      rank
      classification
      downloadURL
    }

  grab: (icb = ->, fin = ->)->
    err, totalColumn <~ @getTotalColumn
    if err
      logError err.message
      return fin err


    async.eachSeries totalColumn
    , (column, cb) ~>
      err, totalPage <~ @getTotalPage column
      if err
        logError "抓取#{column}栏目总页数失败"
        return cb null

      logPerimary "抓取#{column}栏目总页数成功"

      async.eachSeries totalPage, (page, cb) ~>
        err, movieList <~ @getSpecPageMovieList page
        if err
          logError "抓取列表失败#{page}"
          return cb null

        logPerimary "抓取列表成功#{page}"

        async.each movieList, (movieUrl, cb) ~>
          err, movie <~ @getMoiveDetail movieUrl
          if err
            logError "抓取电影信息失败#{movieUrl}"
            return cb null
          icb movie
          logSuccess "你抓到了 <<#{movie.title}>>"
          cb null
        , cb
      , cb
    , fin




module.exports = {
  MovieCrawler
}
