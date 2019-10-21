on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  pFacadeRef = void()
  return(1)
  exit
end

on setID(me, tID, tFacadeId)
  pID = tID
  pFacadeId = tFacadeId
  pFacadeRef = getObject(pFacadeId)
  return(1)
  exit
end

on handleUpdate(me, tTopic, tdata)
  return(me.Refresh(tTopic, tdata))
  exit
end

on Refresh(me, tTopic, tdata)
  return(1)
  exit
end

on getGameSystem(me)
  return(pFacadeRef)
  exit
end

on sendGameSystemEvent(me, tTopic, tdata)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  return(tGameSystem.sendGameSystemEvent(tTopic, tdata))
  exit
end