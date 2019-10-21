on construct(me)
  pNodes = void()
  pInterface = createObject(#random, "Treeview Interface Class")
  sendProcessTracking(521)
  exit
end

on deconstruct(me)
  if objectp(pNodes) then
    if pNodes.valid then
      removeObject(pNodes.getID())
    end if
  end if
  pNodes = void()
  if objectExists(pInterface.getID()) then
    removeObject(pInterface.getID())
  end if
  exit
end

on define(me, tdata, tWidth, tHeight)
  sendProcessTracking(522)
  pNodes = me.createNode(tdata, tWidth, 0)
  sendProcessTracking(530)
  pInterface.feedData(me)
  sendProcessTracking(540)
  pInterface.define([#width:tWidth, #height:tHeight])
  sendProcessTracking(550)
  exit
end

on getRootNode(me)
  return(pNodes)
  exit
end

on getInterface(me)
  return(pInterface)
  exit
end

on handlePageRequest(me, tPageID)
  getThread(#catalogue).getComponent().preparePage(tPageID)
  exit
end

on createNode(me, tdata, tWidth, tLevel)
  if ilk(tdata) <> #propList then
    return(error(me, "Data for node was not a list", #createNode, #major))
  end if
  sendProcessTracking(523)
  tNode = createObject(#random, "Treeview Node Class")
  if tNode = 0 then
    return(error(me, "Unable to create node", #createNode, #major))
  end if
  tNodeData = []
  tNodeData.setaProp(#level, tLevel)
  tNodeData.setaProp(#navigateable, tdata.getaProp("navigateable"))
  tNodeData.setaProp(#color, tdata.getaProp("color"))
  tNodeData.setaProp(#icon, tdata.getaProp("icon"))
  tNodeData.setaProp(#pageid, tdata.getaProp("pageid"))
  tNodeData.setaProp(#nodename, tdata.getaProp("nodename"))
  sendProcessTracking(524)
  tNo = 1
  repeat while tNo <= tNodeData.count
    tValue = tNodeData.getAt(tNo)
    if voidp(tValue) then
      tProp = tNodeData.getPropAt(tNo)
      return(error(me, "Malformed node data" && tProp, #createNode, #major))
    end if
    tNo = 1 + tNo
  end repeat
  sendProcessTracking(525)
  tSuccess = tNode.feedData(tNodeData, tWidth)
  sendProcessTracking(526)
  if not tSuccess then
    return(error(me, "Unable to feed node data", #createNode, #major))
  end if
  tSubNodes = tdata.getaProp(#subnodes)
  if ilk(tSubNodes) = #list then
    sendProcessTracking(527)
    repeat while me <= tWidth
      tSubNodeData = getAt(tWidth, tdata)
      tSubNode = me.createNode(tSubNodeData, tWidth, tLevel + 1)
      if tSubNode <> 0 then
        tNode.addChild(tSubNode)
      end if
    end repeat
  end if
  sendProcessTracking(528)
  return(tNode)
  exit
end