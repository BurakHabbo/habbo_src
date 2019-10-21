on prepare(me, tdata)
  if tdata.getAt("CHANNEL") = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  pTimer = 0
  pNextChange = random(36) + 12
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
  end if
  me.getPropRef(#pSprList, 2).castNum = 0
  pChanges = 1
  exit
end

on update(me)
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 2 then
    return()
  end if
  if pActive then
    pTimer = pTimer + 1
    if pTimer < pNextChange then
      return()
    end if
    pTimer = 0
    pNextChange = random(36) + 12
    tNewName = "red_tv_b_0_1_1_2_" & random(8) - 1
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.getPropRef(#pSprList, 2).castNum = tmember.number
      me.getPropRef(#pSprList, 2).width = tmember.width
      me.getPropRef(#pSprList, 2).height = tmember.height
      me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 2
    end if
  else
    me.getPropRef(#pSprList, 2).castNum = 0
    pChanges = 0
  end if
  exit
end

on setOn(me)
  getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "FIREON" & "/" & "ON")
  exit
end

on setOff(me)
  getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "FIREON" & "/" & "OFF")
  exit
end

on select(me)
  if the doubleClick then
    if pActive then
      me.setOff()
    else
      me.setOn()
    end if
  end if
  return(1)
  exit
end