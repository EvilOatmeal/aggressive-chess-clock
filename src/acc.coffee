getComputedStyle = (el) ->
  window.getComputedStyle el

randomInt = (ceiling) ->
  if typeof ceiling != 'number'
    throw new Error('randomInt: No ceiling argument provided.')
  Math.ceil(Math.random() * ceiling)

capitalize = (string) ->
  string.substr(0, 1).toUpperCase() + string.substr(1)

# Special jQuery like elements

$ = (selector, context) ->
  context = context || document
  instance = new SpecialElement
  instance.el = context.querySelectorAll(selector)
  if !instance.el
    throw new Error "$: No element found for selector '#{ selector }'."
  instance

SpecialElement = ->

SpecialElement.prototype =
  hide: ->
    for el in this.el
      if getComputedStyle(el).display != 'none'
        el._defaultDisplay = getComputedStyle(el).display
        el.style.display = 'none'
    this

  show: ->
    for el in this.el
      if getComputedStyle(el).display == 'none'
        el.style.display = el._defaultDisplay || 'block'
    this

  on: (type, callback) ->
    for el in this.el
      el.addEventListener type, callback, false
    this

  html: (string) ->
    for el in this.el
      el.innerHTML = string
    this

  addClass: (classes) ->
    classes = classes.split /\s/
    for el in this.el
      for newClass in classes
        el.className += ' ' + newClass
    this

  removeClass: (classes) ->
    classes = classes.split /\s/
    for el in this.el
      for classToRemove in classes
        re = new RegExp '(^|\\s+)' + classToRemove + '($|\\s+)', 'g'
        el.className = el.className.replace re, ' '
    this

  focus: ->
    for el in this.el
      el.focus()
    this


# Game

Game = ->

game = null

newGame = (e) ->
  e.preventDefault()
  game = new Game
  game.timeLimit = getTimeLimitFromSetup()
  startClock()


# Info

showInfo = ->
  pauseClock()
  $info.show()

hideInfo = ->
  $info.hide()


# Setup

showSetup = ->
  pauseClock()
  $setup.show()
  $board.hide()
  $setup_start.focus()

getTimeLimitFromSetup = ->
  time = $setup_time.el[0].value
  if time
    time = time.trim().split(':').map (val) ->
      parseInt val
  else
    alert 'Invalid Time limit format. Use MM:SS.'


# Board

showBoard = ->
  $board.show()
  $setup.hide()


# Clock

showClock = ->
  $clock.show()
  $move.hide()
  showBoard()
  $clock_next.focus()

startClock = ->
  clearInterval game.ticker
  game.clock = game.timeLimit.slice()
  renderTime()
  showClock()
  resumeClock()

toggleClockPause = ->
  if game && typeof game.ticker == 'number'
    pauseClock()
  else
    resumeClock()

pauseClock = ->
  $clock_pause.html('Resume')
  if game
    clearInterval game.ticker
    game.ticker = null

resumeClock = ->
  $clock_pause.html('Pause')
  game.ticker = setInterval ticker, 1000

ticker = ->
  game.clock[1] -= 1
  if game.clock[1] <= 0
    if game.clock[0] <= 0
      showMove()
      return
    else
      game.clock[0] -= 1
      game.clock[1] = 59
  renderTime()
  return

renderTime = ->
  $clock_time.html game.clock.map(padTimeNumber).join(':')

padTimeNumber = (number) ->
  ('0' + number).substr -2


# Move

pieces =
  pawn:
    directions: ['1 step forward', '2 steps forward', 'Attack left', 'Attack right']
  rook:
    directions: ['forward', 'backward', 'left', 'right'],
    maxDistance: 7
  knight:
    directions: [
      '2 steps forward, 1 left', '2 steps forward, 1 right',
      '1 step forward, 2 left', '1 step forward, 2 right',
      '2 steps backward, 1 left', '2 steps backward, 1 right',
      '1 step backward, 2 left', '1 step backward, 2 right'
    ]
  bishop:
    directions: ['forward-left', 'forward-right', 'backward-left', 'backward-right'],
    maxDistance: 7
  queen:
    directions: [
      'forward', 'backward', 'left', 'right',
      'forward-left', 'forward-right', 'backward-left', 'backward-right'
    ],
    maxDistance: 7
  king:
    directions: [
      'forward', 'backward', 'left', 'right',
      'forward-left', 'forward-right', 'backward-left', 'backward-right'
    ]
    maxDistance: 1

showMove = ->
  clearInterval game.ticker
  rerollPiece()
  $move.show()
  $clock.hide()
  showBoard()
  $move_next.focus()

rerollPiece = ->
  badLuck = randomInt 16

  if badLuck <= 8
    piece = 'pawn'
  else if badLuck == 9 || badLuck == 10
    piece = 'rook'
  else if badLuck == 11 || badLuck == 12
    piece = 'knight'
  else if badLuck == 13 || badLuck == 14
    piece = 'bishop'
  else if badLuck == 15
    piece = 'queen'
  else if badLuck == 16
    piece = 'king'

  game.movePiece = piece
  $move_piece_icon
    .removeClass('icon-' + ['pawn','rook','knight','bishop','queen','king'].join(' icon-'))
    .addClass('icon-' + piece)
  $move_piece_name.html capitalize piece

  rerollAction()

rerollAction = ->
  piece = pieces[game.movePiece]
  if piece
    direction = piece.directions[randomInt piece.directions.length - 1]
    switch game.movePiece
      when 'pawn', 'knight'
        description = direction
      else
        distance = randomInt piece.maxDistance
        description = '' + distance + (if distance > 1 then ' steps ' else ' step ') + direction
    $move_action_description.html description


# Init

$showInfo = $('.showInfo').on 'click', showInfo
$showSetup = $('.showSetup').on 'click', showSetup

$info = $('.info')
$info_close = $('.info_close button').on 'click', hideInfo

$setup = $('.setup')
$setup_time = $('.setup_time input')
$setup_start = $('.setup_start button').on 'click', newGame

$board = $('.board')
$board_showSetup = $('.board_showSetup').on 'click', showSetup

$clock = $('.clock')
$clock_time = $('.clock_time')
$clock_pause = $('.clock_pause').on 'click', toggleClockPause
$clock_surrender = $('.clock_surrender').on 'click', showMove
$clock_next = $('.clock_next').on 'click', startClock

$move = $('.move')
$move_piece = $('.move_piece').on 'click', rerollPiece
$move_piece_icon = $('.move_piece_icon')
$move_piece_name = $('.move_piece_name')
$move_action = $('.move_action').on 'click', rerollAction
$move_action_description = $('.move_action_description')
$move_next = $('.move_next').on 'click', startClock

showInfo()
showSetup()
