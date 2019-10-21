on construct(me)
  pSelectedLevelId = -1
  pInviteMaxCount = 5
  pInviteSentData = []
  me.pTimeoutUpdates = 0
  return(1)
  exit
end

on deconstruct(me)
  return(me.deconstruct())
  exit
end

on Initialize(me)
  me.pListItemContainerClass = ["IG ItemContainer Base Class", "IG LevelInstanceData Class"]
  me.pollContentUpdate()
  exit
end

on storeLevelListInfo(me, tLevelData)
  me.storeNewList(tLevelData, 0)
  if me.getSelectedLevelId() = -1 then
    me.selectLevel(me.getListIdByIndex(1), 1)
  end if
  return(1)
  exit
end

on getMainListIds(me, tPageSize)
  tFirst = 1
  tLast = tFirst + tPageSize - 1
  tList = []
  i = tFirst
  repeat while i <= tLast
    if i <= me.count(#pListIndex) then
      tList.append(me.getAt(i))
    end if
    i = 1 + i
  end repeat
  return(tList)
  exit
end

on createGame(me)
  tLevelItem = me.getSelectedLevel()
  if tLevelItem = 0 then
    return(0)
  end if
  tTypeService = me.getIGComponent("GameTypes")
  tGameParams = tTypeService.convertGamePropsForCreate(tLevelItem.getProperty(#game_type), tLevelItem.dump())
  if tGameParams = 0 then
    return(0)
  end if
  executeMessage(#sendTrackingPoint, "/game/created")
  put(pSelectedLevelId && tGameParams)
  return(me.getHandler().send_CREATE_GAME(string(pSelectedLevelId), tGameParams))
  exit
end

on selectLevel(me, tLevelId, tRenderFlag)
  if voidp(tLevelId) then
    tLevelId = -1
  end if
  pSelectedLevelId = tLevelId
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  tRenderObj.resetSubComponent("Details")
  tRenderObj.setViewMode(#info)
  return(1)
  exit
end

on getSelectedLevelId(me)
  return(pSelectedLevelId)
  exit
end

on getSelectedLevel(me)
  tItemRef = me.getListEntry(pSelectedLevelId)
  if tItemRef = 0 then
    return(error(me, "No selected level item!" && pSelectedLevelId, #getSelectedLevel))
  end if
  return(tItemRef)
  exit
end

on getRemInviteCount(me)
  return(pInviteMaxCount - pInviteSentData.count)
  exit
end

on setProperty(me, tKey, tValue)
  tLevelRef = me.getSelectedLevel()
  if tLevelRef = 0 then
    return(0)
  end if
  tLevelRef.setProperty(tKey, tValue)
  tRenderObj = me.getRenderer()
  if tRenderObj = 0 then
    return(0)
  end if
  tRenderObj.renderProperty(tKey, tLevelRef.getProperty(tKey))
  return(1)
  exit
end

on handleUpdate(me, tUpdateId, tSenderId)
  if me = "LevelList" then
    tItemRef = me.getSelectedLevel()
    if tItemRef <> 0 then
      if tUpdateId = tItemRef.getProperty(#id) then
        return(me.renderUI())
      end if
    end if
  end if
  return(1)
  exit
end

on pollContentUpdate(me, tForced)
  if not tForced and not me.isUpdateTimestampExpired() then
    return(0)
  end if
  me.setUpdateTimestamp()
  return(me.getHandler().send_GET_CREATE_GAME_INFO())
  exit
end