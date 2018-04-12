
module.exports = (robot) ->
  if(!robot.brain.get('dailyQueue'))
    robot.brain.set('dailyQueue', [])

  robot.hear /^daily for (.*)/i, (res) ->
    nomes = res.match[1].split(' ')
    pushDaily robot, res, nome for nome in nomes

  robot.hear /^cancel daily$/i, (res) ->
    res.send 'Cancelada a daily está'

  robot.listen(
    (message) ->
      currentDaily = robot.brain.get('currentDaily')
      currentDaily and message.room is currentDaily.res.message.room and message.user.name is currentDaily.user.substr(1)
    (res) ->
      currentDaily = robot.brain.get('currentDaily')
      nextQuestion = currentDaily.nextQuestion()
      if(nextQuestion)
        res.send "#{currentDaily.user}: #{nextQuestion}"
      else
        farewellMessage(robot, res, currentDaily)
        finishCurrentDaily(robot)
  )

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
  dailyQueue = robot.brain.get('dailyQueue')
  nextDaily = dailyQueue.shift()
  robot.brain.set('dailyQueue', dailyQueue)
  if(nextDaily)
    startDaily(robot, nextDaily)
  else
    robot.brain.set('currentDaily', null)

farewellMessage = (robot, res, daily) ->
  res.send "#{daily.user}: obrigado pequeno padawan"

cancelCurrentDaily = (robot) ->
  finishCurrentDaily(robot)

class Daily
  @questions: ["ontem o que fez você?", "alguma dificuldade você teve?", "hoje o que fazer vai?"]
  constructor: (@res, @user) ->
    @questionIndex = 0

  nextQuestion: ->
    Daily.questions[@questionIndex++]
