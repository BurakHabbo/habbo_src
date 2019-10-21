on construct(me)
  pWindowList = []
  the error = ERROR.setIgnoreStatus
  pCreatorID = "room.object.displayer.window.creator"
  createObject(pCreatorID, "Room Object Window Creator Class")
  pBadgeObjID = "room.obj.disp.badge.mngr"
  createObject(pBadgeObjID, "Badge Manager Class")
  pShowActions = 1
  pShowUserTags = 1
  pLastSelectedObjType = void()
  pTagListObjID = "room.obj.disp.tags"
  createObject(pTagListObjID, "Tag List Class")
  pBadgeDetailsWindowID = #badgeDetailsWindowID
  pBaseLocZ = 0
  pBaseWindowIds = getVariableValue("object.displayer.window.ids")
  me.createBaseWindows()
  registerMessage(#groupLogoDownloaded, me.getID(), #groupLogoDownloaded)
  registerMessage(#hideInfoStand, me.getID(), #clearWindowDisplayList)
  registerMessage(#updateInfostandAvatar, me.getID(), #refreshView)
  registerMessage(#showObjectInfo, me.getID(), #showObjectInfo)
  registerMessage(#hideObjectInfo, me.getID(), #clearWindowDisplayList)
  registerMessage(#removeObjectInfo, me.getID(), #clearWindowDisplayList)
  registerMessage(#updateInfoStandBadge, me.getID(), #updateBadge)
  registerMessage(#leaveRoom, me.getID(), #clearWindowDisplayList)
  registerMessage(#updateUserTags, me.getID(), #updateTagList)
  registerMessage(#changeRoom, me.getID(), #clearWindowDisplayList)
  registerMessage(#itemObjectsUpdated, me.getID(), #refreshView)
  registerMessage(#activeObjectsUpdated, me.getID(), #refreshView)
  registerMessage(#updateClubStatus, me.getID(), #refreshView)
  registerMessage(#remove_user, me.getID(), #refreshView)
  registerMessage(#activeObjectRemoved, me.getID(), #refreshView)
  registerMessage(#itemObjectRemoved, me.getID(), #refreshView)
  pWindowCreator = getObject(pCreatorID)
  pTagListObj = getObject(pTagListObjID)
  pTagLists = []
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#hideInfoStand, me.getID())
  unregisterMessage(#groupLogoDownloaded, me.getID())
  removeObject(pBadgeObjID)
  removeObject(pCreatorID)
  return(1)
  exit
end

on updateBadge(me, tBadgeName)
  me.refreshView()
  exit
end

on createBaseWindows(me)
  tIndex = 1
  repeat while tIndex <= pBaseWindowIds.count
    tID = pBaseWindowIds.getAt(tIndex)
    if not windowExists(tID) then
      createWindow(tID, "obj_disp_base.window", 999, 999)
      tWndObj = getWindow(tID)
      if tIndex = 1 then
        pBaseLocZ = tWndObj.getProperty(#locZ) - 1000
      end if
    end if
    tWndObj.hide()
    tIndex = 1 + tIndex
  end repeat
  exit
end

on showObjectInfo(me, tObjType, tRefresh)
  if pClosed and tRefresh then
    return(1)
  end if
  if voidp(tObjType) then
    return(0)
  end if
  if pWindowCreator = 0 then
    return(0)
  end if
  me.clearWindowDisplayList()
  pLastSelectedObjType = tObjType
  tRoomComponent = getThread(#room).getComponent()
  tRoomInterface = getThread(#room).getInterface()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tWindowTypes = []
  if me = "user" then
    tObj = tRoomComponent.getUserObject(tSelectedObj)
    tWindowTypes = getVariableValue("object.display.windows.human")
    if tObj <> 0 and pShowUserTags then
      tUserID = integer(tObj.getWebID())
      me.updateUserTags(tUserID)
    end if
  else
    if me = "bot" then
      tObj = tRoomComponent.getUserObject(tSelectedObj)
      tWindowTypes = getVariableValue("object.display.windows.bot")
    else
      if me = "active" then
        tObj = tRoomComponent.getActiveObject(tSelectedObj)
        tWindowTypes = getVariableValue("object.display.windows.furni")
      else
        if me = "item" then
          tObj = tRoomComponent.getItemObject(tSelectedObj)
          tWindowTypes = getVariableValue("object.display.windows.furni")
        else
          if me = "pet" then
            tObj = tRoomComponent.getUserObject(tSelectedObj)
            tWindowTypes = getVariableValue("object.display.windows.pet")
          else
            error(me, "Unsupported object type:" && tObjType, #showObjectInfo, #minor)
            tObj = 0
          end if
        end if
      end if
    end if
  end if
  if tObj = 0 then
    return(0)
  else
    tProps = tObj.getInfo()
  end if
  tPos = 1
  repeat while tPos <= tWindowTypes.count
    tWindowType = tWindowTypes.getAt(tPos)
    if me = "motto" then
      tID = pBaseWindowIds.getAt(#motto)
      pWindowCreator.createMottoWindow(tID, tProps, tSelectedObj, pBadgeObjID, pShowUserTags)
      me.pushWindowToDisplayList(tID)
    else
      if me = "avatar" then
        tID = pBaseWindowIds.getAt(#avatar)
        pWindowCreator.createHumanWindow(tID, tProps, tSelectedObj, pBadgeObjID, pShowUserTags)
        me.updateInfoStandGroup(tProps.getAt(#groupID))
        me.pushWindowToDisplayList(tID)
      else
        if me = "bot" then
          tID = pBaseWindowIds.getAt(#avatar)
          pWindowCreator.createBotWindow(tID, tProps)
          me.pushWindowToDisplayList(tID)
        else
          if me = "furni" then
            tID = pBaseWindowIds.getAt(#avatar)
            pWindowCreator.createFurnitureWindow(tID, tProps)
            me.pushWindowToDisplayList(tID)
          else
            if me = "pet" then
              tID = pBaseWindowIds.getAt(#avatar)
              pWindowCreator.createPetWindow(tID, tProps)
              me.pushWindowToDisplayList(tID)
            else
              if me = "tags_user" then
                if pShowUserTags then
                  tUserTagData = pTagLists.getaProp(tObj.getWebID())
                  if not listp(tUserTagData) then
                    tTagList = []
                  else
                    tTagList = tUserTagData.getAt(#tags)
                  end if
                  if tTagList.count > 0 then
                    tID = pBaseWindowIds.getAt(#tags)
                    pWindowCreator.createUserTagsWindow(tID)
                    me.pushWindowToDisplayList(tID)
                    tTagsWindow = getWindow(tID)
                    tTagsElem = tTagsWindow.getElement("room_obj_disp_tags")
                    pTagListObj.setWidth(tTagsElem.getProperty(#width))
                    pTagListObj.setHeight(tTagsElem.getProperty(#height))
                    tTagListImage = pTagListObj.createTagList(tTagList)
                    tTagsElem.feedImage(tTagListImage)
                    tOffset = tTagListImage.height - tTagsWindow.getProperty(#height)
                    tTagsWindow.resizeBy(0, tOffset)
                  end if
                end if
              else
                if me = "xp_user" then
                  tXP = tProps.getaProp(#xp)
                  if not voidp(tXP) or tXP = 0 then
                    tID = pBaseWindowIds.getAt(#xp)
                    pWindowCreator.createUserXpWindow(tID, tXP)
                    me.pushWindowToDisplayList(tID)
                  end if
                else
                  if me = "links_human" then
                    tID = pBaseWindowIds.getAt(#links)
                    if tProps.getAt(#name) = getObject(#session).GET("user_name") then
                      pWindowCreator.createLinksWindow(tID, #own)
                    else
                      pWindowCreator.createLinksWindow(tID, #peer)
                    end if
                    me.pushWindowToDisplayList(tID)
                  else
                    if me = "actions_human" then
                      tID = pBaseWindowIds.getAt(#actions)
                      pWindowCreator.createActionsHumanWindow(tID, tProps.getAt(#name), pShowActions)
                      me.pushWindowToDisplayList(tID)
                    else
                      if me = "actions_furni" then
                        if tRoomComponent.itemObjectExists(tSelectedObj) then
                          tselectedobject = tRoomComponent.getItemObject(tSelectedObj)
                          tClass = tselectedobject.getClass()
                          if tClass contains "post.it" then
                          else
                            tID = pBaseWindowIds.getAt(#actions)
                            pWindowCreator.createActionsFurniWindow(tID, tObjType, pShowActions)
                            me.pushWindowToDisplayList(tID)
                            if me = "bottom" then
                              tID = pBaseWindowIds.getAt(#bottom)
                              pWindowCreator.createBottomWindow(tID)
                              me.pushWindowToDisplayList(tID)
                            end if
                            if windowExists(tID) then
                              tWndObj = getWindow(tID)
                              tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
                              tWndObj.registerProcedure(#eventProc, me.getID(), #mouseEnter)
                              tWndObj.registerProcedure(#eventProc, me.getID(), #mouseWithin)
                              tWndObj.registerProcedure(#eventProc, me.getID(), #mouseLeave)
                            end if
                          end if
                          tPos = 1 + tPos
                          me.alignWindows()
                          pClosed = 0
                          exit
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end repeat
end

on clearWindowDisplayList(me)
  if pWindowCreator = 0 then
    return(0)
  end if
  repeat while me <= undefined
    tWindowID = getAt(undefined, undefined)
    pWindowCreator.clearWindow(tWindowID)
  end repeat
  pWindowList = []
  if objectExists(pBadgeObjID) then
    getObject(pBadgeObjID).removeBadgeEffect()
  end if
  exit
end

on pushWindowToDisplayList(me, tWindowID)
  pWindowList.add(tWindowID)
  exit
end

on refreshView(me)
  me.clearWindowDisplayList()
  me.showObjectInfo(pLastSelectedObjType, 1)
  exit
end

on showHideActions(me)
  pShowActions = not pShowActions
  me.refreshView()
  exit
end

on showHideTags(me)
  pShowUserTags = not pShowUserTags
  me.refreshView()
  exit
end

on updateUserTags(me, tUserID)
  tLastUpdateTime = 0
  tTimeNow = the milliSeconds
  tUserData = pTagLists.getaProp(tUserID)
  if listp(tUserData) then
    tLastUpdateTime = tUserData.getAt(#lastUpdate)
  else
    pTagLists.setAt(string(tUserID), [#tags:[], #lastUpdate:0])
  end if
  if tTimeNow - tLastUpdateTime > pTagRequestTimeout then
    pTagLists.getAt(string(tUserID)).setAt(#lastUpdate, tTimeNow)
    getConnection(#info).send("GET_USER_TAGS", [#integer:tUserID])
  end if
  exit
end

on alignWindows(me)
  if pWindowList.count = 0 then
    return(0)
  end if
  tDefLeftPos = getVariable("object.display.pos.left")
  tDefBottomPos = getVariable("object.display.pos.bottom")
  tAlignments = getVariableValue("object.displayer.window.align", [])
  tStageWidth = the stageRight - the stageLeft
  tDefLeftPos = tDefLeftPos + tStageWidth - 720
  tIndex = pWindowList.count
  repeat while tIndex >= 1
    tWindowID = pWindowList.getAt(tIndex)
    tWindowObj = getWindow(tWindowID)
    tWindowObj.moveZ(pBaseLocZ + tIndex - 1 * 100)
    tWindowType = pBaseWindowIds.getOne(tWindowID)
    tAlignment = tAlignments.getaProp(tWindowType)
    if voidp(tAlignment) then
      tAlignment = #left
    end if
    tLeft = tDefLeftPos
    if tIndex = pWindowList.count then
      tNextWindowID = pWindowList.getAt(tIndex - 1)
      tNextWindow = getWindow(tNextWindowID)
      if tAlignment = #right then
        tLeft = tDefLeftPos + tNextWindow.getProperty(#width) - tWindowObj.getProperty(#width)
      end if
      tTop = tDefBottomPos - tWindowObj.getProperty(#height)
    else
      tPrevWindowID = pWindowList.getAt(tIndex + 1)
      tPrevWindow = getWindow(tPrevWindowID)
      if tAlignment = #right then
        tLeft = tDefLeftPos + tPrevWindow.getProperty(#width) - tWindowObj.getProperty(#width)
      end if
      tTop = tPrevWindow.getProperty(#locY) - tWindowObj.getProperty(#height)
    end if
    tWindowObj.moveTo(tLeft, tTop)
    tIndex = 255 + tIndex
  end repeat
  exit
end

on updateInfoStandGroup(me, tGroupId)
  tHumanWindowID = pBaseWindowIds.getAt(#avatar)
  if windowExists(tHumanWindowID) then
    tWindowObj = getWindow(tHumanWindowID)
    if tWindowObj.elementExists("info_group_badge") then
      tElem = tWindowObj.getElement("info_group_badge")
    else
      return(0)
    end if
  else
    return(0)
  end if
  if voidp(tGroupId) or tGroupId < 0 then
    tElem.clearImage()
    tElem.setProperty(#cursor, "cursor.arrow")
    return(0)
  end if
  tRoomComponent = getThread(#room).getComponent()
  tGroupInfoObject = tRoomComponent.getGroupInfoObject()
  tLogoMemNum = tGroupInfoObject.getGroupLogoMemberNum(tGroupId)
  if not voidp(tGroupId) then
    tElem.clearImage()
    tElem.setProperty(#image, member(tLogoMemNum).image)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.clearImage()
    tElem.setProperty(#cursor, "cursor.arrow")
  end if
  exit
end

on groupLogoDownloaded(me, tGroupId)
  tRoomInterface = getThread(#room).getInterface()
  tRoomComponent = getThread(#room).getComponent()
  tSelectedObj = tRoomInterface.getSelectedObject()
  tObj = tRoomComponent.getUserObject(tSelectedObj)
  if tObj = 0 then
    return(0)
  end if
  tUsersGroup = tObj.getProperty(#groupID)
  if tUsersGroup = tGroupId then
    me.updateInfoStandGroup(tGroupId)
  end if
  exit
end

on updateTagList(me, tUserID, tTagList)
  tUserTagData = pTagLists.getaProp(tUserID)
  if voidp(tUserTagData) then
    tUserTagData = [#tags:[], #lastUpdate:0]
  end if
  tOldList = tUserTagData.getAt(#tags)
  if tOldList <> tTagList then
    pTagLists.setaProp(tUserID, [#tags:tTagList, #lastUpdate:the milliSeconds])
    me.refreshView()
  end if
  exit
end

on updateBadgeDetailsBubble(me, tElemID)
  if not objectExists(#session) then
    return(0)
  end if
  tRoomThread = getThread(#room)
  tSelectedObjID = tRoomThread.getInterface().getSelectedObject()
  tSelectedObj = tRoomThread.getComponent().getUserObject(tSelectedObjID)
  if not tSelectedObj then
    return(0)
  end if
  tBadges = tSelectedObj.getProperty(#badges)
  if tBadges.ilk <> #propList then
    tBadges = []
  end if
  tBadgeIndex = value(tElemID.getProp(#char, tElemID.length))
  if not integerp(tBadgeIndex) then
    return(0)
  end if
  tBadgeID = tBadges.getaProp(tBadgeIndex)
  if voidp(tBadgeID) then
    return(0)
  end if
  tWindowID = pBaseWindowIds.getaProp(#avatar)
  if not windowExists(tWindowID) then
    return(0)
  end if
  tWindow = getWindow(tWindowID)
  if not tWindow.elementExists(tElemID) then
    return(0)
  end if
  if objectExists(pBadgeDetailsWindowID) then
    removeObject(pBadgeDetailsWindowID)
  end if
  tElem = tWindow.getElement(tElemID)
  tTargetRect = tElem.getProperty(#rect)
  tBubble = createObject(pBadgeDetailsWindowID, "Details Bubble Class")
  tBubble.createWithContent("badge_info.window", tTargetRect, #left)
  tBubbleWindow = tBubble.getWindowObj()
  tBubbleWindow.getElement("badge.info.name").setText(getText("badge_name_" & tBadgeID))
  tBubbleWindow.getElement("badge.info.desc").setText(getText("badge_desc_" & tBadgeID))
  return(1)
  exit
end

on removeBadgeDetailsBubble(me)
  if objectExists(pBadgeDetailsWindowID) then
    removeObject(pBadgeDetailsWindowID)
  end if
  exit
end

on eventProc(me, tEvent, tSprID, tParam)
  tComponent = getThread(#room).getComponent()
  tOwnUser = tComponent.getOwnUser()
  tInterface = getThread(#room).getInterface()
  tSelectedObj = tInterface.pSelectedObj
  tSelectedType = tInterface.pSelectedType
  tSession = getObject(#session)
  if tSprID contains "info_badge" then
    if me = #mouseEnter then
      if not me.updateBadgeDetailsBubble(tSprID) then
        me.removeBadgeDetailsBubble()
      end if
    else
      if me = #mouseLeave then
        me.removeBadgeDetailsBubble()
      else
        if me = #mouseUp then
          tSelectedObj = tInterface.getSelectedObject()
          if tSelectedObj = tSession.GET("user_index") then
            if objectExists(pBadgeObjID) then
              getObject(pBadgeObjID).openBadgeWindow()
            end if
          end if
        end if
      end if
    end if
  end if
  if tEvent = #mouseUp then
    if me = "badges.button" then
      if objectExists(pBadgeObjID) then
        getObject(pBadgeObjID).openBadgeWindow()
      end if
    else
      if me = "dance.button" then
        tCurrentDance = tOwnUser.getProperty(#dancing)
        if tCurrentDance > 0 then
          tComponent.getRoomConnection().send("STOP", "Dance")
        else
          tComponent.getRoomConnection().send("DANCE")
        end if
        return(1)
      else
        if me = "hcdance.button" then
          tCurrentDance = tOwnUser.getProperty(#dancing)
          if tParam.count(#char) = 6 then
            tInteger = integer(tParam.getProp(#char, 6))
            tComponent.getRoomConnection().send("DANCE", [#integer:tInteger])
          else
            if tCurrentDance > 0 then
              tComponent.getRoomConnection().send("STOP", "Dance")
            end if
          end if
          return(1)
        else
          if me = "wave.button" then
            if tOwnUser.getProperty(#dancing) then
              tComponent.getRoomConnection().send("STOP", "Dance")
              tInterface.dancingStoppedExternally()
            end if
            return(tComponent.getRoomConnection().send("WAVE"))
          else
            if me = "move.button" then
              return(tInterface.startObjectMover(tSelectedObj))
            else
              if me = "rotate.button" then
                return(tComponent.getActiveObject(tSelectedObj).rotate())
              else
                if me = "pick.button" then
                  if me = "active" then
                    ttype = "stuff"
                  else
                    if me = "item" then
                      ttype = "item"
                    else
                      return(me.clearWindowDisplayList())
                    end if
                  end if
                  me.clearWindowDisplayList()
                  return(tComponent.getRoomConnection().send("ADDSTRIPITEM", "new" && ttype && tSelectedObj))
                else
                  if me = "delete.button" then
                    pDeleteObjID = tSelectedObj
                    pDeleteType = tSelectedType
                    return(tInterface.showConfirmDelete())
                  else
                    if me = "kick.button" then
                      if tComponent.userObjectExists(tSelectedObj) then
                        tUserName = tComponent.getUserObject(tSelectedObj).getName()
                      else
                        tUserName = ""
                      end if
                      tComponent.getRoomConnection().send("KICKUSER", tUserName)
                      return(me.clearWindowDisplayList())
                    else
                      if me = "ban.button" then
                        if tComponent.userObjectExists(tSelectedObj) then
                          tUserName = tComponent.getUserObject(tSelectedObj).getName()
                        else
                          tUserName = ""
                        end if
                        tComponent.getRoomConnection().send("BANUSER", tUserName)
                        return(me.clearWindowDisplayList())
                      else
                        if me = "give_rights.button" then
                          if tComponent.userObjectExists(tSelectedObj) then
                            tUserName = tComponent.getUserObject(tSelectedObj).getName()
                          else
                            tUserName = ""
                          end if
                          tComponent.getRoomConnection().send("ASSIGNRIGHTS", tUserName)
                          tSelectedObj = ""
                          me.clearWindowDisplayList()
                          tInterface.hideArrowHiliter()
                          return(1)
                        else
                          if me = "take_rights.button" then
                            if tComponent.userObjectExists(tSelectedObj) then
                              tUserName = tComponent.getUserObject(tSelectedObj).getName()
                            else
                              tUserName = ""
                            end if
                            tComponent.getRoomConnection().send("REMOVERIGHTS", tUserName)
                            tSelectedObj = ""
                            me.clearWindowDisplayList()
                            tInterface.hideArrowHiliter()
                            return(1)
                          else
                            if me = "friend.button" then
                              if tComponent.userObjectExists(tSelectedObj) then
                                tUserName = tComponent.getUserObject(tSelectedObj).getName()
                                executeMessage(#externalFriendRequest, tUserName)
                              end if
                              return(1)
                            else
                              if me = "trade.button" then
                                tList = []
                                tList.setAt("showDialog", 1)
                                executeMessage(#getHotelClosingStatus, tList)
                                if tList.getAt("retval") = 1 then
                                  return(1)
                                end if
                                if tComponent.userObjectExists(tSelectedObj) then
                                  tUserName = tComponent.getUserObject(tSelectedObj).getName()
                                else
                                  tUserName = ""
                                end if
                                tInterface.startTrading(tSelectedObj)
                                tInterface.getContainer().open()
                                return(1)
                              else
                                if me = "ignore.button" then
                                  tIgnoreListObj = tInterface.getIgnoreListObject()
                                  if tComponent.userObjectExists(tSelectedObj) then
                                    tUserName = tComponent.getUserObject(tSelectedObj).getName()
                                    tIgnoreListObj.setIgnoreStatus(tUserName, 1)
                                  else
                                    tUserName = ""
                                  end if
                                  me.clearWindowDisplayList()
                                  tSelectedObj = ""
                                else
                                  if me = "unignore.button" then
                                    tIgnoreListObj = tInterface.getIgnoreListObject()
                                    if tComponent.userObjectExists(tSelectedObj) then
                                      tUserName = tComponent.getUserObject(tSelectedObj).getName()
                                      tIgnoreListObj.setIgnoreStatus(tUserName, 0)
                                    end if
                                    me.clearWindowDisplayList()
                                    tSelectedObj = ""
                                  else
                                    if me <> "room_obj_disp_badge_sel" then
                                      if me = "room_obj_disp_icon_badge" then
                                        if objectExists(pBadgeObjID) then
                                          getObject(pBadgeObjID).openBadgeWindow()
                                        end if
                                      else
                                        if me <> "room_obj_disp_home" then
                                          if me <> "room_obj_disp_icon_home" then
                                            if me = "room_obj_disp_name" then
                                              if variableExists("link.format.userpage") then
                                                tWebID = tComponent.getUserObject(tSelectedObj).getWebID()
                                                if not voidp(tWebID) then
                                                  tDestURL = replaceChunks(getVariable("link.format.userpage"), "%ID%", string(tWebID))
                                                  executeMessage(#externalLinkClick, the mouseLoc)
                                                  openNetPage(tDestURL)
                                                end if
                                              end if
                                            else
                                              if me = "info_group_badge" then
                                                tSelectedObj = tInterface.getSelectedObject()
                                                if not voidp(tSelectedObj) and tSelectedObj <> "" then
                                                  tUserObj = tComponent.getUserObject(tSelectedObj)
                                                  tInfoObj = tComponent.getGroupInfoObject()
                                                  if tUserObj <> 0 and tUserObj <> void() then
                                                    tUserInfo = tUserObj.getInfo()
                                                    tInfoObj.showUsersInfoByName(tUserInfo.getAt(#name))
                                                  end if
                                                end if
                                              else
                                                if me = "object_displayer_toggle_actions" then
                                                  me.showHideActions()
                                                else
                                                  if me = "object_displayer_toggle_actions_icon" then
                                                    me.showHideActions()
                                                  else
                                                    if me = "object_displayer_toggle_tags" then
                                                      me.showHideTags()
                                                    else
                                                      if me = "object_displayer_toggle_tags_icon" then
                                                        me.showHideTags()
                                                      else
                                                        if me = "room_obj_disp_close" then
                                                          pClosed = 1
                                                          me.clearWindowDisplayList()
                                                        else
                                                          if me <> "room_obj_disp_looks" then
                                                            if me <> "room_obj_disp_icon_avatar" then
                                                              if me <> "room_obj_disp_avatar" then
                                                                if me = "outlook.button" then
                                                                  if tSelectedObj = tSession.GET("user_index") then
                                                                    tAllowModify = 1
                                                                    if getObject(#session).exists("allow_profile_editing") then
                                                                      tAllowModify = getObject(#session).GET("allow_profile_editing")
                                                                    end if
                                                                    if tAllowModify then
                                                                      if threadExists(#registration) then
                                                                        getThread(#registration).getComponent().openFigureUpdate()
                                                                      end if
                                                                    else
                                                                      executeMessage(#externalLinkClick, the mouseLoc)
                                                                      openNetPage(getText("url_figure_editor"))
                                                                    end if
                                                                  end if
                                                                else
                                                                  if me = "room_obj_disp_tags" then
                                                                    tTag = pTagListObj.getTagAt(tParam)
                                                                    if stringp(tTag) then
                                                                      tDestURL = replaceChunks(getVariable("link.format.tag.search"), "%tag%", tTag)
                                                                      executeMessage(#externalLinkClick, the mouseLoc)
                                                                      openNetPage(tDestURL)
                                                                    end if
                                                                  else
                                                                    if me = "room_obj_disp_bg" then
                                                                      return(0)
                                                                    end if
                                                                  end if
                                                                end if
                                                                if tEvent = #mouseWithin then
                                                                  if me = "room_obj_disp_tags" then
                                                                    tTagsWindow = getWindow(pBaseWindowIds.getAt(#tags))
                                                                    tElem = tTagsWindow.getElement(tSprID)
                                                                    if stringp(pTagListObj.getTagAt(tParam)) then
                                                                      tElem.setProperty(#cursor, "cursor.finger")
                                                                    else
                                                                      tElem.setProperty(#cursor, 0)
                                                                    end if
                                                                  else
                                                                    nothing()
                                                                  end if
                                                                else
                                                                  if tEvent = #mouseLeave then
                                                                    if me = "room_obj_disp_tags" then
                                                                      tTagsWindow = getWindow(pBaseWindowIds.getAt(#tags))
                                                                      tElem = tTagsWindow.getElement(tSprID)
                                                                      tElem.setProperty(#cursor, 0)
                                                                    else
                                                                      nothing()
                                                                    end if
                                                                  end if
                                                                end if
                                                                exit
                                                              end if
                                                            end if
                                                          end if
                                                        end if
                                                      end if
                                                    end if
                                                  end if
                                                end if
                                              end if
                                            end if
                                          end if
                                        end if
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end