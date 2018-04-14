
module.exports = (robot) ->
  if(!robot.brain.get('dailyQueue'))
    robot.brain.set('dailyQueue', [])

  if(!robot.brain.get('roomnames'))
    robot.brain.set('roomNames', {})

  robot.respond /roomname for (.*) is (.*)$/i, (res) ->
    id = res.match[1]
    name = res.match[2]
    roomNames = robot.brain.get('roomNames')
    roomNames[name] = id
    robot.brain.set('roomNames', roomNames)
    res.reply 'Roomname saved'

  robot.respond /roomnames$/i, (res) ->
    roomNames = robot.brain.get('roomNames')
    if(Object.keys(roomNames).length is 0)
      res.reply 'No roomnames'
    else
      replyRoomName res, id, name for id, name of roomNames

  robot.hear /^daily for (.*)/i, (res) ->
    nomes = res.match[1].split(' ')
    pushDaily robot, res, nome for nome in nomes

  robot.hear /^cancel daily$/i, (res) ->
    currentDaily = robot.brain.get('currentDaily')
    if(finishCurrentDaily(robot))
      res.send 'Cancelada a daily está'
    else
      res.send 'Nenhuma daily fazendo estou'

  robot.listen(
    (message) ->
      currentDaily = robot.brain.get('currentDaily')
      currentDaily and message.room in currentDaily.roomNames and message.user.name is currentDaily.user.substr(1)
    (res) ->
      currentDaily = robot.brain.get('currentDaily')
      nextQuestion = currentDaily.nextQuestion()
      if(nextQuestion)
        res.send "#{currentDaily.user}: #{nextQuestion}"
      else
        farewellMessage(robot, res, currentDaily)
        finishCurrentDaily(robot)
  )

replyRoomName = (res, id, name) ->
  res.reply "#{id}: #{name}"

pushDaily = (robot, res, user) ->
  daily = new Daily(res, user)
  currentDaily = robot.brain.get('currentDaily')
  if(currentDaily)
    dailyQueue = robot.brain.get('dailyQueue')
    dailyQueue.push(daily)
    robot.brain.set('dailyQueue', dailyQueue)
  else
    startDaily(robot, daily)

startDaily = (robot, daily) ->
  setTimeout () ->
    robot.brain.set('currentDaily', daily)
    daily.res.send "#{daily.user}: nossa daily começar devemos:"
    setTimeout () ->
        daily.res.send "#{daily.user}: #{daily.nextQuestion()}"
    , 500
  , 500

finishCurrentDaily = (robot) ->
  currentDaily = robot.brain.get('currentDaily')
  if(!currentDaily)
    return false
  dailyQueue = robot.brain.get('dailyQueue')
  nextDaily = dailyQueue.shift()
  robot.brain.set('dailyQueue', dailyQueue)
  if(nextDaily)
    startDaily(robot, nextDaily)
  else
    robot.brain.set('currentDaily', null)
  true

farewellMessage = (robot, res, daily) ->
  res.send "#{daily.user}: obrigado pequeno padawan"

class Daily
  @questions: ["ontem o que fez você?", "alguma dificuldade você teve?", "hoje o que fazer vai?"]
  constructor: (@res, @user) ->
    @questionIndex = 0
    @roomNames = []
    knownRoomNames = @res.robot.brain.get('roomNames')
    room = @res.message.room
    @roomNames.push(room)
    room = knownRoomNames[room]
    if room
      @roomNames.push(room)

  nextQuestion: ->
    Daily.questions[@questionIndex++]
