# Description
#   Write like an idiot
#
# Configuration:
#   None
#
# Commands:
#   .dau <mytext> - Write like an idiot
#
# Notes:
#   None
#
# Author:
#   sandres

repeat = (x, y) ->
  # Repeat x -> y times
  return Array(y+1).join x


do_random = (x) ->
  return (Math.floor(Math.random() * x) % x)


switchchars = (word) ->
  # Switch neighbour Characters
  # e.g. "hello" becomes "ehllo"

  chars = word.split ''
  first = do_random(chars.length)
  # We want to add +1, so it cannot be the last element
  if (first == (chars.length - 1))
    first = first - 1
  second = first + 1
  # Swap characters
  tmp = chars[first]
  chars[first] = chars[second]
  chars[second] = tmp

  return chars.join ''


misspell = (text) ->
  # Misspell words 1/4 of the time
  ret = ''
  for word in text.split " "
    if (do_random(4) == 0)
      ret = ret + ' ' + switchchars(word)
    else
      ret = ret + ' ' + word

  return ret


eol = (text) ->
  # Add end-of-line exclamations

  base = ' !?!?!?!1'
  chars = base.split ''
  for x in [1..5]
    chars = repeat_single_char(chars, rand=3)

  ret = chars.join ''
  return text + ret


get_fillword = ->
  fillwords = ['EH', 'EEH', 'EHH', 'AEH', 'AEEH', 'AEEHHH' ]
  ret = fillwords[do_random(fillwords.length)]
  return ret


stutter = (text) ->
  # Insert get_fillword() every 50% of time to the text
  ret = ''
  for word in text.split " "
    if (do_random(2) == 0)
      ret = ret + ' ' + get_fillword() + ' , '

    ret = ret + ' ' + word
      
  return ret


repeat_single_char = (chars, rand = 1) ->
  # Reateat a single character in a word $rand-times
  random_index = do_random(chars.length)
  random_char = chars[random_index]
  new_char = repeat(random_char, 1+do_random(rand))
  chars.splice(random_index, 0, new_char)
  return chars


moron = (text) ->
  ret = ''
  for word in text.split ' '
    if (do_random(2) == 0)
      chars = word.split ''
      if (do_random(4) == 0)
        ret = ret + ' ' + repeat_single_char(chars).join ''
      ret = ret + ' ' +  word
    else
      ret = ret + ' ' +  word

  return ret

dau = (text) ->
  # Add all idiot styles together
  text = text.toUpperCase()
  text = misspell(text)
  text = moron(text)
  text = stutter(text)
  text = eol(text)
  return text

updatetext = (robot, res, roomid, msgid, text) ->
  data = JSON.stringify({
    user: process.env.ROCKETCHAT_USER,
    password: process.env.ROCKETCHAT_PASSWORD,
  })

  # Get Auth token
  robot.http("#{process.env.ROCKETCHAT_URL}/api/v1/login")
    .header('Content-Type', 'application/json')
    .post(data) (err, response, body) ->
      if err
        res.send "Encountered an error :( #{err}"
        return

      ret = JSON.parse body
      authtoken = ret['data']['authToken']
      userid = ret['data']['userId']

      # Rewrite original message with updated text
      data = JSON.stringify({
        'roomId': roomid,
        'msgId': msgid,
        'text': text,
      })
      robot.http("#{process.env.ROCKETCHAT_URL}/api/v1/chat.update")
        .headers('Content-Type': 'application/json', 'X-Auth-Token': authtoken, 'X-User-Id': userid)
        .post(data) (err, response, body) ->
          if err
            res.send "Encountered an error :( #{err}"
            return
          console.log("got: #{body}")


module.exports = (robot) ->
  robot.hear /^[\.!]dau\s(.*)/i, (res) ->
    text = dau(res.match[1])

    console.log("dau: #{text}")

    msgid=res.envelope.message['id']
    roomid=res.envelope.user['roomID']

    updatetext(robot, res, roomid, msgid, text)
