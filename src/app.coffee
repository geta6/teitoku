'use strict'


fs = require 'fs'
path = require 'path'

gui = require 'nw.gui'
#gui.Window.get().showDevTools()


$win = $ window
$doc = $ document
$frame = null
$forms = null
$waits = null
$embed = null
$modal = null
$helps = null


$state =
  modal: null
  float: no
  start:
    width: gui.Window.get().width
    height: gui.Window.get().height


$win.on 'app:init', ->
  console.debug 'app:init'

  $frame = $ '#frame'
  $waits = $ '#waits'
  $embed = $ '#embed'
  $modal = $ '#modal'
  $helps = $ '#helps'

  $waits.fadeIn 60

  unless $frame.size()
    $frame = ($ '<iframe>').attr id: 'frame', frameborder: 0, marginwidth: 0, marginheight: 0
    ($ 'body').append $frame

  $frame.one 'load', ->
    return $win.trigger 'app:start' unless /\/login\//.test $frame.contents().get(0).baseURI

    login_id = localStorage.getItem 'login_id'
    password = localStorage.getItem 'password'
    return $win.trigger 'app:login' unless login_id and password

    $forms = $frame.contents().find 'form.validator'
    $forms.find('#login_id').val login_id
    $forms.find('#password').val password
    $frame.one 'load', ->
      return $win.trigger 'app:login' if /\/login\//.test $frame.contents().get(0).baseURI
      return $win.trigger 'app:start'
    $forms.find('input[type=submit]').trigger 'click'
  $frame.attr 'src', 'http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/'


$win.on 'app:login', ->
  console.debug 'app:login'
  $forms = $frame.contents().find 'form.validator'
  $frame.fadeIn queue: no, duration: 480, always: ->
    $forms.one 'submit', (event) ->
      event.preventDefault()
      localStorage.setItem 'login_id', $forms.find('#login_id').val()
      localStorage.setItem 'password', $forms.find('#password').val()
      $frame.fadeOut queue: no, duration: 480, always: ->
        $win.trigger 'app:init'


$win.on 'app:start', ->
  console.debug 'app:start'
  $waits.addClass 'starting'
  getEmbed = ->
    return $frame.contents().find('iframe').contents().find('embed')
  loading = setInterval ->
    if (embed = $frame.contents().find('iframe').contents().find 'embed').size()
      clearInterval loading
      $frame.remove()
      $win.trigger 'app:run', embed
    else if /Adobe Flash Player/.test $frame.contents().find('iframe').contents().find('#flashWrap').text()
      clearInterval loading
      $frame.remove()
      embed = ($ embed).attr 'src', 'lib/expressInstall.swf'
      $win.trigger 'app:run', embed
  , 200


$win.on 'app:run', (event, embed) ->
  console.debug 'app:run'
  param =
    width: '100%'
    height: '100%'
    src: $(embed).attr 'src'
    id: 'frame'
  swfFrame = $('<iframe>')
  swfFrame.on 'load', ->
    window.focus()
    $waits.fadeOut 600
  $('body').append swfFrame.attr(param).show()
  setInterval ->
    window.focus()
  , 1000


$win.on 'app:modal', (event, message) ->
  console.debug 'app:modal'
  clearTimeout $state.modal
  $modal.text message
  $modal.stop().fadeIn 60
  $state.modal = setTimeout ->
    $modal.stop().fadeOut 480
  , 1000


$ ->

  $doc.on 'contextmenu', '#embed', (event) ->
    event.preventDefault()
    return no


  $doc.on 'click', 'a[rel=external]', (event) ->
    event.preventDefault()
    gui.Shell.openExternal ($ event.currentTarget).attr 'href'


  capture = (savepath, data) ->
    if (fs.existsSync savepath) and (fs.statSync savepath).isDirectory()
      fs.writeFile (path.resolve savepath, "teitoku_#{Date.now()}.png"), data, 'base64', (err) ->
        if err
          localStorage.removeItem 'savepath'
          $win.trigger 'app:modal', err.message
    else
      localStorage.removeItem 'savepath'
      $win.trigger 'app:modal', 'Invalid save path.'


  $win.on 'keyup', (event) ->
    event.preventDefault()
    switch event.keyCode

      when 67 # C, Capture
        gui.Window.get().capturePage (img) ->
          data = img.replace /^data:image\/(png|jpg|jpeg);base64,/, ''
          savepath = localStorage.getItem 'savepath'
          unless savepath or fs.existsSync savepath
            alert 'キャプチャの保存場所を設定します(初回のみ)'
            ($ '#shots')
              .one 'change', ->
                localStorage.setItem 'savepath', savepath = ($ @).val()
                alert "設定しました、次回より自動的に'#{savepath}'へ保存されます"
                capture savepath, data
              .trigger 'click'
          else
            capture savepath, data

      when 69 # E, Erase
        if window.confirm '本当に初期化しますか?'
          localStorage.clear()
          alert '全ての設定情報を消去しました、アプリケーションを再起動してください'

      when 70 # F, Float
        gui.Window.get().setAlwaysOnTop $state.float = !$state.float
        $win.trigger 'app:modal', if $state.float then 'Float.' else 'Release.'

      when 72 # H, Help
        $helps.fadeToggle 120

      when 77 # M, Restore
        gui.Window.get().leaveFullscreen()
        gui.Window.get().resizeTo $state.start.width, $state.start.height
        $win.trigger 'app:modal', 'Restore size.'

      when 82 # R, Reload
        if window.confirm 'リロードしますか?'
          $win.trigger 'app:modal', 'Reload app.'
          $win.trigger 'app:init'

      else
        console.log event.keyCode


  $win.trigger 'app:init'

