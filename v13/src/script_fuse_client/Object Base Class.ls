on construct(me)
  valid = 1
  delays = []
  return(1)
  exit
end

on deconstruct(me)
  if count(delays) > 0 then
    i = 1
    repeat while i <= count(delays)
      timeout(delays.getPropAt(i)).forget()
      i = 1 + i
    end repeat
  end if
  delays = []
  return(1)
  exit
end

on setID(me, tid)
  if voidp(me.id) then
    id = tid
  else
    error(me, "Attempted to redefine object's ID:" & "\r" & me.id && "->" && tid, #setID)
  end if
  exit
end

on getID(me)
  return(id)
  exit
end

on delay(me, tTime, tMethod, tArgument)
  if not integerp(tTime) then
    return(error(me, "Integer expected:" && tTime, #delay))
  end if
  if not symbolp(tMethod) then
    return(error(me, "Symbol expected:" && tMethod, #delay))
  end if
  tUniqueId = "Delay" && me.getID() && the milliSeconds
  timeout(tUniqueId).new(tTime, #executeDelay, me)
  tList = [#method:tMethod, #argument:tArgument]
  me.setProp(#delays, tUniqueId, tList)
  return(tUniqueId)
  exit
end

on cancel(me, tDelayID)
  if voidp(me.getProp(#delays, tDelayID)) then
    return(0)
  end if
  timeout(tDelayID).forget()
  return(me.deleteProp(tDelayID))
  exit
end

on getRefCount(me)
  return(integer(string(param(1)).getProp(#word, string(param(1)).count(#word) - 1)) - 3)
  exit
end

on print(me)
  put(me)
  exit
end

on executeDelay(me, tTimeout)
  tid = tTimeout.name
  tTask = delays.getAt(tid)
  me.cancel(tid)
  call(tTask.getAt(#method), me, tTask.getAt(#argument))
  exit
end