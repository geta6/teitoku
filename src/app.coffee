'use strict'


fs = require 'fs'
path = require 'path'
gui = require 'nw.gui'

# gui.Window.get().showDevTools()

$win = $ window
$doc = $ document
$frame = null
$frwin = null
$forms = null
$waits = null
$embed = null
$modal = null
$helps = null


$state =
  modal: null
  float: no
  klock: no
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
    $frame = ($ '<iframe>').attr
      id: 'frame'
      frameborder: 0
      marginwidth: 0
      marginheight: 0
    ($ 'body').append $frame

  $frame.one 'load', ->
    unless /\/login\//.test $frame.contents().get(0).baseURI
      return $win.trigger 'app:start'

    login_id = localStorage.getItem 'login_id'
    password = localStorage.getItem 'password'

    unless login_id and password
      return $win.trigger 'app:login'

    $forms = $frame.contents().find 'form.validator'
    $forms.find('#login_id').val login_id
    $forms.find('#password').val password
    $frame.one 'load', ->
      if /\/login\//.test $frame.contents().get(0).baseURI
        return $win.trigger 'app:login'
      return $win.trigger 'app:start'
    $forms.find('input[type=submit]').trigger 'click'

  $frame.attr
    src: 'http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/'


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
    $contents = $frame.contents().find('iframe').contents()
    if (embed = $contents.find 'embed').size()
      clearInterval loading
      #$frame.remove()
      $win.trigger 'app:run', embed
    else if /Adobe Flash Player/.test $contents.find('#flashWrap').text()
      clearInterval loading
      #$frame.remove()
      embed = ($ embed).attr 'src', 'lib/expressInstall.swf'
      $win.trigger 'app:run', embed
  , 200


$win.on 'app:run', (event, embed) ->
  console.debug 'app:run'
  $frame.attr('src', $(embed).attr 'src').one 'load', ->
    $ $frame.show().get(0).contentWindow
    .on 'blur', ->
      ($ @).focus()
    .on 'keyup', (event) ->
      $win.trigger 'app:keyup', event.keyCode
    .focus()
    $waits.fadeOut queue: no, duration: 600, always: ->
      $waits.remove()


$win.on 'app:modal', (event, message) ->
  console.debug 'app:modal'
  clearTimeout $state.modal
  $modal.text message
  $modal.stop().fadeIn 60
  $state.modal = setTimeout ->
    $modal.stop().fadeOut 480
  , 1000


$win.on 'app:capture', (event, options = {}) ->
  {savepath, data} = options
  if (fs.existsSync savepath) and (fs.statSync savepath).isDirectory()
    dest = path.resolve savepath, "teitoku_#{Date.now()}.png"
    fs.writeFile dest, data, 'base64', (err) ->
      if err
        localStorage.removeItem 'savepath'
        $win.trigger 'app:modal', err.message
  else
    localStorage.removeItem 'savepath'
    $win.trigger 'app:modal', 'Invalid save path.'


$win.on 'app:keyup', (event, keyCode) ->
  switch keyCode

    when 67 # C, Capture
      unless $state.klock
        gui.Window.get().capturePage (img) ->
          data = img.replace /^data:image\/(png|jpg|jpeg);base64,/, ''
          savepath = localStorage.getItem 'savepath'
          unless savepath or fs.existsSync savepath
            alert 'キャプチャの保存場所を設定します(初回のみ)'
            ($ '#shots')
              .one 'change', ->
                localStorage.setItem 'savepath', savepath = ($ @).val()
                alert "設定しました、次回より自動的に'#{savepath}'へ保存されます"
                $win.trigger 'app:capture', savepath: savepath, data: data
              .trigger 'click'
          else
            $win.trigger 'app:capture', savepath: savepath, data: data

    when 69 # E, Erase
      unless $state.klock
        if window.confirm '本当に初期化しますか?'
          localStorage.clear()
          alert '全ての設定情報を消去しました、アプリケーションを再起動してください'

    when 70 # F, Float
      unless $state.klock
        gui.Window.get().setAlwaysOnTop $state.float = !$state.float
        if $state.float
          $win.trigger 'app:modal', 'Float.'
        else
          $win.trigger 'app:modal', 'Release.'

    when 72 # H, Help
      unless $state.klock
        $helps.fadeToggle 120

    when 77 # M, Restore
      unless $state.klock
        gui.Window.get().leaveFullscreen()
        gui.Window.get().resizeTo $state.start.width, $state.start.height
        $win.trigger 'app:modal', 'Restore size.'

    when 82 # R, Reload
      unless $state.klock
        if window.confirm 'リロードしますか?'
          $win.trigger 'app:modal', 'Reload app.'
          $win.trigger 'app:init'

    when 27 # Esc, Key-Lock
      if $state.klock = !$state.klock
        $win.trigger 'app:modal', 'Lock. (Esc to Toggle)'
      else
        $win.trigger 'app:modal', 'Unlock.'

    else
      console.debug keyCode


$ ->

  $doc.on 'contextmenu', '#embed', (event) ->
    event.preventDefault()
    return no


  $doc.on 'click', 'a[rel=external]', (event) ->
    event.preventDefault()
    gui.Shell.openExternal ($ event.currentTarget).attr 'href'


  $win.on 'keyup', (event) ->
    $win.trigger 'app:keyup', event.keyCode


  $win.trigger 'app:init'

