on construct(me)
  pSplashs = []
  pBalloonRightMargin = getIntVariable("balloons.rightmargin", 720)
  createVariable("balloons.rightmargin", 597)
  initThread("thread.pelle")
  return(1)
  exit
end

on deconstruct(me)
  closeThread(#pellehyppy)
  createVariable("balloons.rightmargin", pBalloonRightMargin)
  removeUpdate(me.getID())
  if objectExists(#waterripples) then
    removeObject(#waterripples)
  end if
  if objectExists(#poolliftdoor) then
    removeObject(#poolliftdoor)
  end if
  if objectExists(#pool_fuse_screen) then
    removeObject(#pool_fuse_screen)
  end if
  pSplashs = []
  if objectExists(#pool_bigSplash) then
    removeObject(#pool_bigSplash)
  end if
  return(me.removeArrowCursor())
  exit
end

on prepare(me)
  createObject(#pool_fuse_screen, "FUSE screen Class")
  pSplashs = []
  f = 0
  repeat while f <= 2
    tProps = []
    pSplashs.addProp("Splash" & f, createObject(#temp, "AnimSprite Class"))
    tProps.setAt(#visible, 0)
    tProps.setAt(#AnimFrames, 10)
    tProps.setAt(#startFrame, 0)
    tProps.setAt(#MemberName, "splash_")
    tProps.setAt(#id, "Splash" & f)
    tProps.setAt(#loc, point(the stageRight + 1000, 0))
    pSplashs.getAt("Splash" & f).setData(tProps)
    f = 1 + f
  end repeat
  if not objectExists(#waterripples) then
    createObject(#waterripples, "Water Ripple Effects Class")
  end if
  if not objectExists(#poolliftdoor) then
    createObject(#poolliftdoor, "Elevator Door Class")
  end if
  if objectExists(#waterripples) then
    getObject(#waterripples).Init("vesi2")
  end if
  tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("jumpticketautomatic")
  registerProcedure(tSpr, #eventProcJumpTicketAutomatic, me.getID(), #mouseDown)
  repeat while me <= undefined
    tID = getAt(undefined, undefined)
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tID)
    registerProcedure(tSpr, #poolTeleport, me.getID(), #mouseDown)
  end repeat
  pArrowCursor = 0
  if threadExists(#room) then
    getThread(#room).getInterface().hideRoomBar()
  end if
  getThread(#pellehyppy).getInterface().showRoomBar()
  receiveUpdate(me.getID())
  return(1)
  exit
end

on showprogram(me, tMsg)
  if not getThread(#room).getComponent().pActiveFlag then
    return(0)
  end if
  if voidp(tMsg) then
    return(0)
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tPrm = tMsg.getAt(#show_params)
  if tDst contains "cam" then
    if not objectExists(#pool_fuse_screen) then
      return(0)
    end if
    call(symbol("fuseShow_" & tCmd), getObject(#pool_fuse_screen), tPrm)
  else
    if tDst contains "Splash" then
      me.splash(tDst, tCmd)
    else
      if tDst contains "door" then
        me.delay(200, #elvatorDoor, [#dest:tDst, #command:tCmd])
      else
      end if
    end if
  end if
  exit
end

on splash(me, tDest, tCommand)
  if voidp(pSplashs.getAt(tDest)) then
    return(0)
  end if
  call(#Activate, pSplashs.getAt(tDest))
  exit
end

on elvatorDoor(me, tProps)
  tDst = tProps.getAt(#dest)
  tCmd = tProps.getAt(#command)
  if me = "open" then
    tmember = getMember("towerdoor_2")
  else
    if me = "close" then
      tmember = getMember("towerdoor_0")
    end if
  end if
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return(0)
  end if
  tVisObj.getSprById("lift_door").setMember(tmember)
  exit
end

on update(me)
  if pSplashs.count > 0 then
    call(#updateSplashs, pSplashs)
  end if
  if pArrowCursor or the mouseH < 25 then
    me.poolArrows()
  end if
  exit
end

on poolArrows(me)
  tStartPos = [0, 13]
  tloc = getThread(#room).getInterface().getGeometry().getWorldCoordinate(the mouseH, the mouseV)
  if tloc.ilk <> #list then
    return(me.removeArrowCursor())
  end if
  if tStartPos.getAt(1) - tloc.getAt(1) = tStartPos.getAt(2) - tloc.getAt(2) then
    pArrowCursor = 1
    cursor([member(getmemnum("cursor_arrow_l")), member(getmemnum("cursor_arrow_l_mask"))])
  else
    me.removeArrowCursor()
  end if
  exit
end

on removeArrowCursor(me)
  pArrowCursor = 0
  cursor(-1)
  return(1)
  exit
end

on eventProcJumpTicketAutomatic(me)
  if threadExists(#pellehyppy) then
    return(executeMessage(#show_ticketWindow))
  else
    return(0)
  end if
  exit
end

on poolTeleport(me, tEvent, tSprID, tParam)
  tMyIndex = getObject(#session).GET("user_index")
  if not getThread(#room).getComponent().userObjectExists(tMyIndex) then
    return(0)
  end if
  tloc = getThread(#room).getComponent().getUserObject(tMyIndex).getLocation()
  getThread(#room).getInterface().eventProcRoom(tEvent, "floor", tParam)
  if not tSprID contains "pool_clickarea" and tloc.getAt(3) < 7 then
    if tloc.getAt(2) > 11 and tloc.getAt(1) < 20 then
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short:17, #short:22])
    else
      getConnection(getVariable("connection.room.id")).send("MOVE", [#short:31, #short:11])
    end if
  else
    if tSprID contains "pool_clickarea" and tloc.getAt(3) = 7 then
      if tloc.getAt(2) > 11 then
        getConnection(getVariable("connection.room.id")).send("MOVE", [#short:17, #short:21])
      else
        getConnection(getVariable("connection.room.id")).send("MOVE", [#short:31, #short:10])
      end if
    end if
  end if
  exit
end