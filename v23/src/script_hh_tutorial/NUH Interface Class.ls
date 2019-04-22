on construct(me)
  pBubbles = []
  pUpdateOwnUserHelp = 0
  pInvitationWindowID = #NUH_invite_window_ID
  return(1)
  exit
end

on deconstruct(me)
  me.removeAll()
  return(1)
  exit
end

on removeAll(me)
  tItemNo = 1
  repeat while tItemNo <= pBubbles.count
    tBubble = pBubbles.getAt(tItemNo)
    tBubble.deconstruct()
    tItemNo = 1 + tItemNo
  end repeat
  pBubbles = []
  me.hideInvitationWindow()
  exit
end

on showOwnUserHelp(me)
  tRoomComponent = getThread("room").getComponent()
  tOwnRoomId = tRoomComponent.getUsersRoomId(getObject(#session).GET("user_name"))
  tHumanObj = tRoomComponent.getUserObject(tOwnRoomId)
  if tHumanObj = 0 then
    return(0)
  end if
  tRoomComponent = getThread("room").getComponent()
  if tRoomComponent = 0 then
    return(0)
  end if
  tBubble = createObject(#random, getVariableValue("update.bubble.class"))
  if tBubble = 0 then
    return(0)
  end if
  tHelpId = "own_user"
  tPointer = 7
  tText = getText("NUH_" & tHelpId)
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles.getAt(tHelpId)
    tPreviousBubble.deconstruct()
  end if
  pBubbles.setAt(tHelpId, tBubble)
  exit
end

on showGenericHelp(me, tHelpId, tTargetLoc, tPointerIndex)
  tLocX = 0
  tLocY = 0
  tText = ""
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  if voidp(tTargetLoc) or not listp(tTargetLoc) then
    tLocX = getVariable("NUH." & tHelpId & ".bubble.loc").getProp(#item, 1)
    tLocY = getVariable("NUH." & tHelpId & ".bubble.loc").getProp(#item, 2)
  else
    tLocX = tTargetLoc.getAt(1)
    tLocY = tTargetLoc.getAt(2)
  end if
  the itemDelimiter = tDelim
  if voidp(tPointerIndex) then
    tPointer = getVariable("NUH." & tHelpId & ".pointer")
  else
    tPointer = tPointerIndex
  end if
  tText = getText("NUH_" & tHelpId)
  tBubble = createObject(#random, getVariableValue("static.bubble.class"))
  if tBubble = 0 then
    return(0)
  end if
  tBubble.setProperty(#bubbleId, tHelpId)
  tBubble.setText(tText)
  tBubble.setProperty(#targetX, tLocX)
  tBubble.setProperty(#targetY, tLocY)
  tBubble.selectPointerAndPosition(tPointer)
  tBubble.show()
  if objectp(pBubbles.getaProp(tHelpId)) then
    tPreviousBubble = pBubbles.getAt(tHelpId)
    tPreviousBubble.deconstruct()
  end if
  pBubbles.setAt(tHelpId, tBubble)
  exit
end

on showInviteWindow(me)
  me.hideInvitationWindow()
  createWindow(pInvitationWindowID, "popup_bg_white.window")
  tWindow = getWindow(pInvitationWindowID)
  tWindow.merge("invitation.window")
  tLocX = getVariable("NUH.invitation.loc").getProp(#item, 1)
  tLocY = getVariable("NUH.invitation.loc").getProp(#item, 2)
  tHeader = getText("send_invitation_header")
  tWindow.getElement("invitation_header").setText(tHeader)
  tText = getText("send_invitation_text")
  tWindow.getElement("invitation_text").setText(tText)
  tYes = getText("yes")
  tWindow.getElement("invitation_button_accept_text").setText(tYes)
  tNo = getText("no")
  tWindow.getElement("invitation_button_deny_text").setText(tNo)
  tWindow.moveTo(tLocX, tLocY)
  tWindow.registerProcedure(#eventProcInvitation, me.getID(), #mouseUp)
  exit
end

on hideInvitationWindow(me)
  if windowExists(pInvitationWindowID) then
    removeWindow(pInvitationWindowID)
  end if
  exit
end

on eventProcInvitation(me, tEvent, tSprID)
  if me <> "invitation_button_accept" then
    if me = "invitation_button_accept_text" then
      me.getComponent().sendInvitations()
      me.hideInvitationWindow()
    else
      if me <> "invitation_button_deny" then
        if me = "invitation_button_deny_text" then
          me.hideInvitationWindow()
        else
          if me = "popup_button_close" then
            me.hideInvitationWindow()
            me.getComponent().setHelpItemClosed("invite")
          end if
        end if
        exit
      end if
    end if
  end if
end