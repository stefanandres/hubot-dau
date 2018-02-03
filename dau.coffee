# Description
#   Write like an idiot
#
# Configuration:
#   None
#
# Commands:
#   .dau mytext - Write like an idiot
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


eol = (text) ->
  ret = text +  ' !!!??!!!!!????!??????????!!!1'
  return ret


get_fillword = ->
  fillwords = ['EH', 'EEH', 'EHH', 'AEH', 'AEEH', 'AEEHHH' ]
  ret = fillwords[do_random(fillwords.length)]
  return ret


stutter = (text) ->
  ret = ""
  for word in text.split " "
    if (do_random(2) == 0)
      ret = ret + ' ' + get_fillword() + ' , '

    ret = ret + ' ' + word
      
  return ret


repeat_single_char = (chars) ->
  if (do_random(4) == 0)
    random_index = do_random(chars.length)
    random_char = chars[random_index]
    new_char = repeat(random_char, 1+do_random(1))
    chars.splice(random_index, 0, new_char)
    return chars
  else
    return chars


moron = (text) ->
  ret = ''
  for word in text.split ' '
    if (do_random(2) == 0)
      chars = word.split ''
      ret = ret + ' ' + repeat_single_char(chars).join ''
    else
      ret = ret + ' ' +  word
  return ret

dau = (text) ->
  text = text.toUpperCase()
  text = moron(text)
  text = eol(text)
  text = stutter(text)
  return text

module.exports = (robot) ->
  robot.hear /^[\.!]dau\s(.*)/i, (res) ->
    text = dau(res.match[1])

    res.send "#{text}"
