on construct(me)
  pRoomInvitationClass = "Invitation Class"
  pFriendRequestClass = "Instant Friend Request Class"
  pVisibleItemID = "Visible Room Bar Extension Item"
  pInvitationData = []
  pFriendRequestData = []
  pVisibleItem = void()
  pShowInstantFriendRequests = 1
  registerMessage(#showInvitation, me.getID(), #registerInvitation)
  registerMessage(#hideInvitation, me.getID(), #hideInvitation)
  registerMessage(#acceptInvitation, me.getID(), #acceptInvitation)
  registerMessage(#rejectInvitation, me.getID(), #rejectInvitation)
  registerMessage(#FriendRequestListOpened, me.getID(), #clearFriendRequestsFromStack)
  registerMessage(#updateFriendRequestCount, me.getID(), #viewNextItemInStack)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#acceptInvitation, me.getID())
  unregisterMessage(#rejectInvitation, me.getID())
  unregisterMessage(#showInvitation, me.getID())
  unregisterMessage(#hideInvitation, me.getID())
  unregisterMessage(#FriendRequestListOpened, me.getID())
  unregisterMessage(#updateFriendRequestCount, me.getID())
  return(1)
  exit
end

on define(me, tBottomBarID)
  pBottomBarId = tBottomBarID
  exit
end

on hideExtensions(me)
  me.hideInvitation()
  me.hideFriendRequest()
  exit
end

on registerInvitation(me, tInvitationData)
  pInvitationData = tInvitationData
  me.showPendingInvitation()
  exit
end

on clearFriendRequestsFromStack(me)
  me.hideFriendRequest()
  me.showPendingInvitation()
  exit
end

on showPendingInvitation(me)
  if pVisibleItem <> void() then
    return(0)
  end if
  if pInvitationData.count < 1 then
    return(0)
  end if
  if objectExists(pVisibleItemID) then
    return(1)
  end if
  tInvitationObj = createObject(pVisibleItemID, pRoomInvitationClass)
  if not tInvitationObj then
    return(0)
  end if
  if not tInvitationObj.show(pInvitationData, pBottomBarId, "friend_list_icon") then
    if objectExists(pVisibleItemID) then
      removeObject(pVisibleItemID)
    end if
    return(0)
  end if
  pVisibleItem = #invitation
  return(1)
  exit
end

on showPendingInstantFriendRequest(me)
  if not pShowInstantFriendRequests then
    return(0)
  end if
  if not voidp(pVisibleItem) and not pVisibleItem = #friendrequest then
    return(0)
  end if
  if objectExists(pVisibleItemID) then
    return(1)
  end if
  if not threadExists(#friend_list) then
    return(0)
  end if
  tRoomComponent = getThread(#room).getComponent()
  tRoomData = tRoomComponent.getRoomData()
  if not ilk(tRoomData) = #propList then
    return(0)
  end if
  if not tRoomData.getAt(#type) = #private or tRoomData.getAt(#type) = #public then
    return(0)
  end if
  if not threadExists(#friend_list) then
    return(0)
  end if
  tFriendListComponent = getThread(#friend_list).getComponent()
  tFriendListInterface = getThread(#friend_list).getInterface()
  if tFriendListInterface.isFriendRequestViewOpen() then
    return(0)
  end if
  tPendingRequests = tFriendListComponent.getPendingFriendRequests()
  if tPendingRequests.count = 0 then
    me.hideFriendRequest()
    return(0)
  end if
  repeat while me <= undefined
    tPendingRequest = getAt(undefined, undefined)
    tRoomID = tRoomComponent.getUsersRoomId(tPendingRequest.getAt(#name))
    tUserObj = tRoomComponent.getUserObject(tRoomID)
    if not tUserObj = 0 then
      createObject(pVisibleItemID, pFriendRequestClass)
      tObj = getObject(pVisibleItemID)
      tObj.define(pBottomBarId, "friend_list_icon", tPendingRequest, me.getID())
      tObj.show()
      pFriendRequestData = tPendingRequest
      pVisibleItem = #friendrequest
      return(1)
    end if
  end repeat
  return(0)
  exit
end

on ignoreInstantFriendRequests(me)
  pShowInstantFriendRequests = 0
  me.hideFriendRequest()
  me.showPendingInvitation()
  exit
end

on viewNextItemInStack(me)
  tFrShown = me.showPendingInstantFriendRequest()
  if not tFrShown then
    me.showPendingInvitation()
  end if
  exit
end

on confirmFriendRequest(me, tAccept)
  if not threadExists(#friend_list) then
    return(0)
  end if
  tFriendListComponent = getThread(#friend_list).getComponent()
  tFriendListInterface = getThread(#friend_list).getInterface()
  tRequestId = pFriendRequestData.getAt(#id)
  if tAccept then
    if tFriendListComponent.isFriendListFull() then
      executeMessage(#alert, "console_fr_limit_exceeded_error")
      me.hideFriendRequest()
      return(0)
    end if
    tFriendListComponent.updateFriendRequest(pFriendRequestData, #accepted)
  else
    tFriendListComponent.updateFriendRequest(pFriendRequestData, #rejected)
  end if
  me.hideFriendRequest()
  exit
end

on acceptInvitation(me)
  if ilk(pInvitationData) <> #propList then
    return(0)
  end if
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return(0)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_ACCEPT_TUTOR_INVITATION", [#string:tSenderId])
  end if
  me.hideInvitation()
  exit
end

on rejectInvitation(me)
  tSenderId = pInvitationData.getaProp(#userID)
  if voidp(tSenderId) then
    return(0)
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("MSG_REJECT_TUTOR_INVITATION", [#string:tSenderId])
  end if
  me.hideInvitation()
  createTimeout(#room_bar_extension_next_update, 1000, #viewNextItemInStack, me.getID(), void(), 1)
  exit
end

on hideInvitation(me)
  if pVisibleItem = #invitation then
    removeObject(pVisibleItemID)
    pVisibleItem = void()
  end if
  pInvitationData = []
  exit
end

on hideFriendRequest(me)
  if pVisibleItem = #friendrequest then
    removeObject(pVisibleItemID)
    pVisibleItem = void()
  end if
  pFriendRequestData = []
  exit
end

on invitationFollowFailed(me)
  executeMessage(#alert, "invitation_follow_failed")
  exit
end