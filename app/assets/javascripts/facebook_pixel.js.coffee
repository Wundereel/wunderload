class @FacebookPixel
  @load: ->
    return if window.fbq

    fbq = window.fbq = ->
      if fbq.callMethod
        fbq.callMethod.apply(fbq, arguments)
      else
        fbq.queue.push(arguments)

    window._fbq ?= fbq

    fbq.push = fbq
    fbq.loaded = true
    fbq.version = '2.0'
    fbq.queue = []

    fb = document.createElement('script')
    fb.async = true
    fb.src = 'https://connect.facebook.net/en_US/fbevents.js'

    firstScript = document.getElementsByTagName('script')[0]
    firstScript.parentNode.insertBefore(fb, firstScript)

    window.fbq 'init', @analyticsId()

    if typeof Turbolinks isnt 'undefined' and Turbolinks.supported
      document.addEventListener "page:change", (->
        FacebookPixel.trackPageview()
      ), true
    else
      FacebookPixel.trackPageview()

  @isLocalRequest: ->
    FacebookPixel.documentDomainIncludes "local"

  @documentDomainIncludes: (str) ->
    document.domain.indexOf(str) isnt -1

  @trackPageview: (url) ->
    FacebookPixel.track 'PageView'

  @track: (args...) ->
    if FacebookPixel.isLocalRequest()
      console.log 'FBTrack', 'track', args...
    else
      window.fbq 'track', args...

  @analyticsId: ->
    '1123840241013717'

FacebookPixel.load()
