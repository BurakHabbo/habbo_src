on prepare(me, tdata)
  if tdata.getAt(#stuffdata) = "O" then
    me.setOn()
    pChanges = 1
  else
    me.setOff()
    pChanges = 0
  end if
  if me.count(#pSprList) > 1 then
    removeEventBroker(me.getPropRef(#pSprList, 1).spriteNum)
    removeEventBroker(me.getPropRef(#pSprList, 2).spriteNum)
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if tValue = "O" then
    me.setOn()
  else
    me.setOff()
  end if
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
    repeat while me <= undefined
      tPart = getAt(undefined, undefined)
      me.switchMember(tPart, "1")
    end repeat
  else
    repeat while me <= undefined
      tPart = getAt(undefined, undefined)
      me.switchMember(tPart, "0")
    end repeat
  end if
  pChanges = 0
  exit
end

on switchMember(me, tPart, tNewMem)
  tSprNum = ["a", "b", "c", "d", "e", "f"].getPos(tPart)
  tName = undefined.name
  tName = tName.getProp(#char, 1, tName.length - 1) & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
    me.getPropRef(#pSprList, tSprNum).width = tmember.width
    me.getPropRef(#pSprList, tSprNum).height = tmember.height
  end if
  exit
end

on setOn(me)
  pActive = 1
  exit
end

on setOff(me)
  pActive = 0
  exit
end

on select(me)
  if the doubleClick then
    if pActive then
      tStr = "C"
    else
      tStr = "O"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return(1)
  exit
end