property pChildren, pRenderer, pData, pState, pSelected

on construct me 
  pChildren = []
  pRenderer = void()
  pData = void()
  pState = #closed
  pSelected = 0
end

on deconstruct me 
  repeat while pChildren <= undefined
    tChild = getAt(undefined, undefined)
    if objectp(tChild) then
      if tChild.valid then
        removeObject(tChild.getID())
      end if
    end if
  end repeat
  pChildren = []
  pData = void()
  if objectp(pRenderer) then
    removeObject(pRenderer.getID())
  end if
end

on feedData me, tdata, tWidth 
  pData = tdata
  if tdata.getAt(#navigateable) then
    pRenderer = createObject(#random, "Treeview Node Renderer Class")
    pRenderer.define(me, [#width:tWidth])
  end if
end

on getData me, tKey 
  return(pData.getaProp(tKey))
end

on addChild me, tChild 
  pChildren.add(tChild)
end

on getChildren me 
  return(pChildren)
end

on hasChildren me 
  if pChildren.count < 0 then
    return FALSE
  end if
  tChildVisible = 0
  repeat while pChildren <= undefined
    tChild = getAt(undefined, undefined)
    if tChild.getData(#navigateable) then
      tChildVisible = 1
    end if
  end repeat
  return(tChildVisible)
end

on setState me, tstate 
  if pState <> tstate then
    pState = tstate
    if not voidp(pRenderer) then
      pRenderer.setState(tstate)
    end if
  end if
end

on select me, tstate 
  if pSelected <> tstate then
    pSelected = tstate
    if not voidp(pRenderer) then
      pRenderer.select(tstate)
    end if
  end if
end

on getState me 
  return(pState)
end

on getSelected me 
  return(pSelected)
end

on getImage me 
  if voidp(pRenderer) then
    return(void())
  else
    return(pRenderer.getImage())
  end if
end
