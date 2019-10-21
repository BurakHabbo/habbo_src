on construct(me)
  pOwnPlayerId = -1
  pUserTeamsIndex = []
  return(me.construct())
  exit
end

on deconstruct(me)
  pOwnPlayerId = -1
  pUserTeamsIndex = []
  return(me.deconstruct())
  exit
end

on Refresh(me, tdata)
  tAllTeamData = tdata.getaProp(#teams)
  if listp(tAllTeamData) then
    i = 1
    repeat while i <= tAllTeamData.count
      tTeam = tAllTeamData.getAt(i)
      tPlayers = tTeam.getaProp(#players)
      repeat while me <= undefined
        tPlayer = getAt(undefined, tdata)
        me.addUserToGame(tPlayer, 1)
      end repeat
      i = 1 + i
    end repeat
  end if
  me.Refresh(tdata)
  return(1)
  exit
end

on addUserToGame(me, tdata, tHoldAnnounce)
  if not listp(tdata) then
    return(0)
  end if
  tUserID = tdata.getaProp(#id)
  if tdata.findPos(#players_required) then
    me.setaProp(#players_required, tdata.getaProp(#players_required))
  end if
  tTeamId = tdata.getaProp(#team_id)
  if voidp(tTeamId) then
    return(0)
  end if
  tOldTeamId = me.getTeamIdFromIndex(tUserID)
  if tOldTeamId <> 0 then
    if tOldTeamId <> tTeamId then
      me.removeUserFromGame(tdata)
    end if
  end if
  me.storeToIndex(tUserID, tTeamId)
  me.setaProp(#player_count, pUserTeamsIndex.count)
  if me.findPos(#teams) = 0 then
    me.setaProp(#teams, [])
  end if
  tAllTeamData = me.getaProp(#teams)
  if tAllTeamData.findPos(tTeamId) = 0 then
    tAllTeamData.setaProp(tTeamId, [#players:[]])
  end if
  tPlayers = tAllTeamData.getaProp(tTeamId).getaProp(#players)
  tPlayerData = []
  repeat while me <= tHoldAnnounce
    tKey = getAt(tHoldAnnounce, tdata)
    if tdata.findPos(tKey) then
      tPlayerData.setaProp(tKey, tdata.getaProp(tKey))
    end if
  end repeat
  if tdata.getaProp(#name) = me.getOwnPlayerName() then
    pOwnPlayerId = tUserID
  end if
  tPlayers.setaProp(tUserID, tPlayerData)
  if not tHoldAnnounce then
    towner = me.getOwnerIGComponent()
    if towner <> 0 then
      towner.announceUpdate(me.getProperty(#id))
    end if
  end if
  return(1)
  exit
end

on removeUserFromGame(me, tdata)
  tUserID = tdata.getaProp(#id)
  tAllTeamData = me.getaProp(#teams)
  if tAllTeamData = 0 then
    return(0)
  end if
  tTeamId = me.getTeamIdFromIndex(tUserID)
  if tTeamId = 0 then
    return(1)
  end if
  me.storeToIndex(tUserID, -1)
  if pOwnPlayerId = tUserID then
    pOwnPlayerId = -1
  end if
  tTeam = tAllTeamData.getaProp(tTeamId)
  tPlayers = tTeam.getaProp(#players)
  if not tPlayers.findPos(tUserID) then
    return(0)
  end if
  tPlayers.deleteProp(tUserID)
  me.setaProp(#player_count, pUserTeamsIndex.count)
  if tdata.findPos(#players_required) then
    me.setaProp(#players_required, tdata.getaProp(#players_required))
  end if
  towner = me.getOwnerIGComponent()
  if towner <> 0 then
    towner.announceUpdate(me.getProperty(#id))
  end if
  return(1)
  exit
end

on getLevelHighscore(me)
  tLevelRef = me.getLevelRef()
  if tLevelRef = 0 then
    return(0)
  end if
  return(tLevelRef.getLevelHighscore())
  exit
end

on getLevelTeamHighscore(me)
  tLevelRef = me.getLevelRef()
  if tLevelRef = 0 then
    return(0)
  end if
  return(tLevelRef.getLevelTeamHighscore())
  exit
end

on getPlayerById(me, tID)
  tAllTeamData = me.getaProp(#teams)
  if tAllTeamData = 0 then
    return(0)
  end if
  repeat while me <= undefined
    tTeam = getAt(undefined, tID)
    tPlayers = tTeam.getaProp(#players)
    repeat while me <= undefined
      tPlayer = getAt(undefined, tID)
      if listp(tPlayer) then
        if tPlayer.getaProp(#id) = tID then
          return(tPlayer)
        end if
      end if
    end repeat
  end repeat
  return(0)
  exit
end

on getAllTeamData(me)
  return(me.getaProp(#teams))
  exit
end

on getTeam(me, tTeamId)
  tTeamData = me.getaProp(#teams)
  if tTeamData = void() then
    return(0)
  end if
  return(tTeamData.getaProp(tTeamId))
  exit
end

on getTeamPlayers(me, tTeamIndex)
  tAllTeamData = me.getAllTeamData()
  if not listp(tAllTeamData) then
    return(0)
  end if
  tTeamData = tAllTeamData.getaProp(tTeamIndex)
  if not listp(tTeamData) then
    return(0)
  end if
  return(tTeamData.getaProp(#players))
  exit
end

on getPlayerCount(me)
  if me.findPos(#player_count) = 0 then
    return(0)
  end if
  return(me.getaProp(#player_count))
  exit
end

on getMaxPlayerCount(me)
  if me.findPos(#player_max_count) = 0 then
    return(0)
  end if
  return(me.getaProp(#player_max_count))
  exit
end

on getTeamSize(me, tTeamIndex)
  tdata = me.getTeamPlayers(tTeamIndex)
  if listp(tdata) then
    return(tdata.count)
  else
    return(0)
  end if
  exit
end

on getTeamCount(me)
  if me.findPos(#number_of_teams) = 0 then
    return(0)
  end if
  return(me.getaProp(#number_of_teams))
  exit
end

on getTeamMaxSize(me)
  tTeamCount = me.getTeamCount()
  if me = 1 then
    tCount = 12
  else
    if me = 2 then
      if me <> 0 then
        if me = 1 then
          tCount = 6
        else
          tCount = 4
        end if
        if me = 3 then
          tCount = 4
        else
          if me = 4 then
            tCount = 3
          end if
        end if
        return(tCount)
        exit
      end if
    end if
  end if
end

on checkPlayerRequiredForSlot(me, tTeamIndex, tPlayerIndex)
  tPlayersRequired = me.getProperty(#players_required)
  if not listp(tPlayersRequired) then
    return(0)
  end if
  tRequiredCount = tPlayersRequired.getaProp(tTeamIndex)
  if voidp(tRequiredCount) then
    return(0)
  end if
  tTeamSize = me.getTeamSize(tTeamIndex)
  return(tTeamSize + tRequiredCount = tPlayerIndex)
  exit
end

on getGameState(me)
  return(me.getaProp(#state))
  exit
end

on getGameStateTimer(me)
  return(me.getaProp(#state_timer))
  exit
end

on getBiggestTeamPlayerCount(me)
  tResult = 0
  tTeamCount = me.getTeamCount()
  tTeamIndex = 1
  repeat while tTeamIndex <= tTeamCount
    tTeam = me.getTeamPlayers(tTeamIndex)
    tPlayerCount = tTeam.count
    if tPlayerCount > tResult then
      tResult = tPlayerCount
    end if
    tTeamIndex = 1 + tTeamIndex
  end repeat
  return(tResult)
  exit
end

on canStart(me)
  tList = me.getaProp(#players_required)
  if not listp(tList) then
    return(1)
  end if
  if tList.count = 0 then
    return(1)
  end if
  return(0)
  exit
end

on getOwnPlayerTeam(me)
  return(me.getTeamIdFromIndex(me.getOwnPlayerId()))
  exit
end

on getOwnPlayerName(me)
  tSession = getObject(#session)
  if tSession = 0 then
    return(0)
  end if
  return(tSession.GET(#user_name))
  exit
end

on getOwnPlayerId(me)
  return(pOwnPlayerId)
  exit
end

on checkIfOwnerOfGame(me)
  tSession = getObject(#session)
  if tSession = 0 then
    return(0)
  end if
  return(tSession.GET(#user_name) = me.getaProp(#owner_name))
  exit
end

on hasCompleteData(me)
  return(listp(me.getAllTeamData()))
  exit
end

on hasTeamScores(me)
  return(me.findPos(#level_team_scores) > 0)
  exit
end

on getTeamIdFromIndex(me, tID)
  return(pUserTeamsIndex.getaProp(tID))
  exit
end

on storeToIndex(me, tID, tTeamId)
  if voidp(tID) or voidp(tTeamId) then
    return(0)
  end if
  if tTeamId = -1 then
    pUserTeamsIndex.deleteProp(tID)
  else
    pUserTeamsIndex.setaProp(tID, tTeamId)
  end if
  return(1)
  exit
end

on getLevelRef(me)
  tLevelId = me.getProperty(#level_id)
  if voidp(tLevelId) then
    return(0)
  end if
  tService = me.getIGComponent("LevelList")
  if tService = 0 then
    return(0)
  end if
  return(tService.getListEntry(tLevelId))
  exit
end