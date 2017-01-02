# # # # # # # # # # # # # # # # # # # #
# buffer
# # # # # # # # # # # # # # # # # # # #

nextTick = (func) ->
  setTimeout(0, func)
  return

updateAnime = do ->
  winRequestAnime =
    window.requestAnimationFrame or
    window.mozRequestAnimationFrame or
    window.webkitRequestAnimationFrame or
    null
  if 'function' == typeof(winRequestAnime)
    requestAnime = winRequestAnime.bind(window)
  else
    requestAnime = do ->
      lastTime = 0
      return (callback) ->
        currentTime = (new Date()).getTime()
        timeToCall = Math.max(0, 16 - (currentTime - lastTime))
        lastTime = currentTime + timeToCall
        return setTimeout(() ->
            callback(lastTime * 1000)
        , timeToCall)
  return (func) ->
    wrapFunc = () ->
      func()
      requestAnime(wrapFunc)
    requestAnime(wrapFunc)
    return

window.util =
  nextTick: nextTick
  updateAnime: updateAnime
