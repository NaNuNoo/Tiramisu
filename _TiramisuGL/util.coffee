# # # # # # # # # # # # # # # # # # # #
# File: Tiramisu/util/util.coffee
# Author: NaNuNo
# Project: https://github.com/NaNuNoo/Tiramisu
# WebSite: http://FenQi.IO
# # # # # # # # # # # # # # # # # # # #

nextTick = (func) ->
  if 'function' == typeof(func)
    setTimeout(0, func)
  return

delayTime = (millisecond, func) ->
  if 'function' == typeof(func)
    setTimeout(millisecond, func)
  return

winRequestAnime =
  window.requestAnimationFrame ?
  window.mozRequestAnimationFrame ?
  window.webkitRequestAnimationFrame
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


imagePromise = (url) ->
  return new Promise (resolve, reject) ->
    image = new Image()
    image.onload = () ->
      resolve(image)
    image.onerror = () ->
      reject(new Error("Load Image ERR. <#{url}>"))
    image.src = url

onHttpLoad = (resolve, reject) ->
  if xhr.response
    return resolve(xhr.response)
  else if 'json' == xhr.responseType
    try
      return resolve(JSON.parse(xhr.responseText))
    catch error
      return reject(error)
  else
    return reject(new Error("Unkonw response type."))

onHttpError = (resolve, reject) ->
  return reject(new Error("HTTP #{xhr.status}."))

onHttpTimeout = (resolve, reject) ->
  return reject(new Error("HTTP time out."))

httpGetPromise = (url, header, resType, timeout) ->
  timeout = timeout ? 5000
  resType = resType ? 'text'
  return new Promise (resolve, reject) ->
    xhr = new XMLHttpRequest()
    xhr.onload = onHttpLoad(resolve, reject)
    xhr.onerror = onHttpError(resolve, reject)
    xhr.ontimeout = onHttpTimeout(resolve, reject)
    if header
      for key, val of header
        xhe.setRequestHeader(key, val)
    xhr.responseType = resType
    xhr.timeout = timeout
    xhr.open("GET", url)
    xhr.send(null)

httpPostPromise = (url, header, body, resType, timeout) ->
  timeout = timeout ? 5000
  resType = resType ? 'text'
  return new Promise (resolve, reject) ->
    xhr = new XMLHttpRequest()
    xhr.onload = onHttpLoad(resolve, reject)
    xhr.onerror = onHttpError(resolve, reject)
    xhr.ontimeout = onHttpTimeout(resolve, reject)
    if header
      for key, val of header
        xhe.setRequestHeader(key, val)
    xhr.responseType = resType
    xhr.timeout = timeout
    xhr.open("POST", url)
    xhr.send(body)


tiGL.nextTick = nextTick
tiGL.delayTime = delayTime
tiGL.updateAnime = updateAnime
tiGL.cancelAnime = cancelAnime
