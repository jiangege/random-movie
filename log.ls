require! {
  colors
}
logWarning = (msg) ->
  console.log "[WARNING] ".bold.yellow + msg

logError = (msg) ->
  console.log "[ERROR] ".bold.red + msg.red

logInfo = (msg) ->
  console.log "[INFO] " + msg

logSuccess = (msg) ->
  console.log "[SUCCESS] ".bold.green + msg.green

logPerimary = (msg) ->
  console.log "[PERIMARY] ".bold.cyan + msg.cyan


module.exports = {
  logWarning
  logError
  logInfo
  logSuccess
  logPerimary
}
