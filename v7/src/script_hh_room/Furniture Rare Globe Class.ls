on prepare(me, tdata)
  if tdata.getAt("CHANNEL") = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  pTimer = 0
  pNextChange = 6
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
  if me.count(#pSprList) < 2 then
    return()
  end if
  if not pChanges then
    return()
  end if
  if pActive then
    pTimer = pTimer + 1
    if pTimer < pNextChange then
      return()
    end if
    pTimer = 0
    pNextChange = 6
    tNewName = "rare_globe_b_0_1_1_0_" & random(4)
    if memberExists(tNewName) then
      me.getPropRef(#pSprList, 2).castNum = getmemnum(tNewName)
      me.getPropRef(#pSprList, 2).width = member.width
      me.getPropRef(#pSprList, 2).height = member.height
      me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 2
    end if
  else
    me.getPropRef(#pSprList, 2).castNum = 0
    pChanges = 0
  end if
  exit
end

on setOn(me)
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "FIREON" & "/" & "ON")
  exit
end

on setOff(me)
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "FIREON" & "/" & "OFF")
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