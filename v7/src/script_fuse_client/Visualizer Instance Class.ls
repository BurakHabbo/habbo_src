on construct(me)
  pTitle = me.getID()
  pLayout = []
  pLocX = 0
  pLocY = 0
  pLocZ = 0
  pwidth = 0
  pheight = 0
  pVisible = 1
  pSpriteList = []
  pSpriteData = []
  pActSprList = []
  pDragFlag = 0
  pDragOffset = [0, 0]
  pBoundary = rect(0, 0, undefined.width, undefined.height) + [-1000, -1000, 1000, 1000]
  return(1)
  exit
end

on deconstruct(me)
  removeUpdate(me.getID())
  i = 1
  repeat while i <= pSpriteList.count
    releaseSprite(pSpriteList.getAt(i).spriteNum)
    i = 1 + i
  end repeat
  pSpriteList = []
  pSpriteData = []
  pActSprList = []
  pBoundary = []
  return(1)
  exit
end

on define(me, tProps)
  if voidp(tProps) then
    return(0)
  end if
  if not voidp(tProps.getAt(#locX)) then
    pLocX = tProps.getAt(#locX)
  end if
  if not voidp(tProps.getAt(#locY)) then
    pLocY = tProps.getAt(#locY)
  end if
  if not voidp(tProps.getAt(#locZ)) then
    pLocZ = tProps.getAt(#locZ)
  end if
  if not voidp(tProps.getAt(#layout)) then
    pLayout = tProps.getAt(#layout)
  end if
  if not voidp(tProps.getAt(#boundary)) then
    pBoundary = tProps.getAt(#boundary)
  end if
  return(me.open(pLayout))
  exit
end

on open(me, tLayout)
  if voidp(tLayout) then
    tLayout = pLayout
  end if
  pLayout = tLayout
  if pSpriteList.count > 0 then
    i = 1
    repeat while i <= pSpriteList.count
      releaseSprite(pSpriteList.getAt(i).spriteNum)
      i = 1 + i
    end repeat
    pSpriteList = []
  end if
  return(me.buildVisual(pLayout))
  exit
end

on close(me)
  return(me.remove(me.getID))
  exit
end

on moveTo(me, tX, tY)
  me.moveBy(tX - pLocX, tY - pLocY)
  exit
end

on moveBy(me, tOffX, tOffY)
  if pLocX + tOffX < pBoundary.getAt(1) then
    tOffX = pBoundary.getAt(1) - pLocX
  end if
  if pLocY + tOffY < pBoundary.getAt(2) then
    tOffY = pBoundary.getAt(2) - pLocY
  end if
  if pLocX + pwidth + tOffX > pBoundary.getAt(3) then
    tOffX = pBoundary.getAt(3) - pLocX - pwidth
  end if
  if pLocY + pheight + tOffY > pBoundary.getAt(4) then
    tOffY = pBoundary.getAt(4) - pLocY - pheight
  end if
  pLocX = pLocX + tOffX
  pLocY = pLocY + tOffY
  me.moveXY(tOffX, tOffY)
  exit
end

on moveZ(me, tZ)
  if not integerp(tZ) then
    return(error(me, "Integer expected:" && tZ, #moveZ))
  end if
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).locZ = tZ + i - 1
    i = 1 + i
  end repeat
  pLocZ = tZ
  exit
end

on getSprite(me, tid)
  return(pActSprList.getAt(tid))
  exit
end

on getSprById(me, tid)
  return(pActSprList.getAt(tid))
  exit
end

on getSpriteByID(me, tid)
  return(pActSprList.getAt(tid))
  exit
end

on spriteExists(me, tid)
  return(not voidp(pActSprList.getAt(tid)))
  exit
end

on moveSprBy(me, tid, tX, tY)
  tSprite = pActSprList.getAt(tid)
  if voidp(tSprite) then
    return(error(me, "Sprite not found:" && tid, #moveSprBy))
  end if
  tSprite.loc = tSprite.loc + [tX, tY]
  return(me.refresh())
  exit
end

on moveSprTo(me, tid, tX, tY)
  tSprite = pActSprList.getAt(tid)
  if voidp(tSprite) then
    return(error(me, "Sprite not found:" && tid, #moveSprTo))
  end if
  tSprite.loc = point(tX, tY)
  return(me.refresh())
  exit
end

on setActive(me)
  return(1)
  exit
end

on setDeactive(me)
  return(1)
  exit
end

on hide(me)
  if pVisible = 1 then
    pVisible = 0
    me.moveX(10000)
    return(1)
  end if
  return(0)
  exit
end

on show(me)
  if pVisible = 0 then
    pVisible = 1
    me.moveX(-10000)
    return(1)
  end if
  return(0)
  exit
end

on drag(me, tBoolean)
  if tBoolean = 1 and pDragFlag = 0 then
    pDragOffset = the mouseLoc - [pLocX, pLocY]
    receiveUpdate(me.getID())
    pDragFlag = 1
  else
    if tBoolean = 0 and pDragFlag = 1 then
      removeUpdate(me.getID())
      pDragFlag = 0
    end if
  end if
  return(1)
  exit
end

on getProperty(me, tProp)
  if me = #layout then
    return(pLayout)
  else
    if me = #locX then
      return(pLocX)
    else
      if me = #locY then
        return(pLocY)
      else
        if me = #locZ then
          return(pLocZ)
        else
          if me = #boundary then
            return(pBoundary)
          else
            if me = #width then
              return(pwidth)
            else
              if me = #height then
                return(pheight)
              else
                if me = #sprCount then
                  return(pSpriteList.count)
                else
                  if me = #spriteList then
                    return(pSpriteList)
                  else
                    if me = #spriteData then
                      return(pSpriteData)
                    else
                      if me = #visible then
                        return(pVisible)
                      else
                        if me = #title then
                          return(pTitle)
                        else
                          if me = #id then
                            return(me.getID())
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
  return(0)
  exit
end

on setProperty(me, tProp, tValue)
  if me = #layout then
    return(me.open(tValue))
  else
    if me = #locX then
      return(me.moveX(tValue))
    else
      if me = #locY then
        return(me.moveY(tValue))
      else
        if me = #locZ then
          return(me.moveZ(tValue))
        else
          if me = #boundary then
            pBoundary = tValue
            return(1)
          else
            if me = #visible then
              if tValue then
                return(me.show())
              else
                return(me.hide())
              end if
            else
              if me = #title then
                pTitle = tValue
                return(1)
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(0)
  exit
end

on moveX(me, tOffX)
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).locH = pSpriteList.getAt(i).locH + tOffX
    i = 1 + i
  end repeat
  exit
end

on moveY(me, tOffY)
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).locV = pSpriteList.getAt(i).locV + tOffY
    i = 1 + i
  end repeat
  exit
end

on moveXY(me, tOffX, tOffY)
  i = 1
  repeat while i <= pSpriteList.count
    pSpriteList.getAt(i).loc = pSpriteList.getAt(i).loc + [tOffX, tOffY]
    i = 1 + i
  end repeat
  exit
end

on update(me)
  me.moveTo(the mouseH - pDragOffset.getAt(1), the mouseV - pDragOffset.getAt(2))
  exit
end

on refresh(me)
  the undefined = ERROR.deconstructSpecialServices
  exit
  exit
  the undefined = undefined.deconstructSpecialServices
  rect
  tRect = ERROR
  repeat while me <= undefined
    tSpr = getAt(undefined, undefined)
    if tSpr.locH < tRect.getAt(1) then
      tRect.setAt(1, tSpr.locH)
    end if
    if tSpr.locV < tRect.getAt(2) then
      tRect.setAt(2, tSpr.locV)
    end if
    if tSpr.locH + tSpr.width > tRect.getAt(3) then
      tRect.setAt(3, tSpr.locH + tSpr.width)
    end if
    if tSpr.locV + tSpr.height > tRect.getAt(4) then
      tRect.setAt(4, tSpr.locV + tSpr.height)
    end if
  end repeat
  pLocX = tRect.getAt(1)
  pLocY = tRect.getAt(2)
  pwidth = tRect.width
  pheight = tRect.height
  if pSpriteData.count > 0 then
    i = 1
    repeat while i <= pSpriteList.count
      pSpriteData.getAt(i).setAt(#loc, pSpriteList.getAt(i).loc - [tRect.getAt(1), tRect.getAt(2)])
      i = 1 + i
    end repeat
  end if
  return(1)
  exit
end

on buildVisual(me, tLayout)
  tLayout = getObjectManager().get(#layout_parser).parse(tLayout)
  if not listp(tLayout) then
    return(error(me, "Invalid visualizer definition:" && tLayout, #buildVisual))
  end if
  if not voidp(tLayout.getAt(#rect)) then
    if tLayout.getAt(#rect).count > 0 then
      pLocX = pLocX + tLayout.getAt(#rect).getAt(1).getAt(1)
      pLocY = pLocY + tLayout.getAt(#rect).getAt(1).getAt(2)
    end if
  end if
  tLayout = tLayout.getAt(#elements)
  tSpriteList = []
  i = 1
  repeat while i <= tLayout.count
    tMemNum = getResourceManager().getmemnum(tLayout.getAt(i).getAt(#member))
    if tMemNum < 1 then
      error(me, "Member" && tLayout.getAt(i).getAt(#member) && "required by visualizer:" && me.getID() && "not found!", #buildVisual)
    else
      tElem = tLayout.getAt(i)
      tSpr = sprite(getSpriteManager().reserveSprite(me.getID()))
      if tSpr.spriteNum < 1 then
        repeat while me <= undefined
          t_rSpr = getAt(undefined, tLayout)
          releaseSprite(t_rSpr.spriteNum, me.getID())
        end repeat
        tSpriteList = []
        return(error(me, "Failed to build visual. System out of sprites!", #buildVisual))
      end if
      tSpr.castNum = tMemNum
      tSpr.ink = tElem.getAt(#ink)
      tSpr.locH = tElem.getAt(#locH) + pLocX
      tSpr.locV = tElem.getAt(#locV) + pLocY
      tSpr.width = tElem.getAt(#width)
      tSpr.height = tElem.getAt(#height)
      tSpr.blend = tElem.getAt(#blend)
      tSpr.rotation = tElem.getAt(#rotation)
      tSpr.skew = tElem.getAt(#skew)
      tSpr.flipH = tElem.getAt(#flipH)
      tSpr.flipV = tElem.getAt(#flipV)
      tSpr.color = rgb(tElem.getAt(#color))
      tSpr.bgColor = rgb(tElem.getAt(#bgColor))
      if tElem.getAt(#media) = #text or tElem.getAt(#media) = #field then
        tTxtMem = member(tMemNum)
        if not voidp(tElem.getAt(#txtColor)) then
          tTxtMem.color = rgb(tElem.getAt(#txtColor))
        end if
        if not voidp(tElem.getAt(#txtBgColor)) then
          tTxtMem.bgColor = rgb(tElem.getAt(#txtBgColor))
        end if
        if tTxtMem.font <> tElem.getAt(#font) then
          tTxtMem.font = tElem.getAt(#font)
        end if
        if tTxtMem.fontSize <> tElem.getAt(#fontSize) then
          tTxtMem.fontSize = tElem.getAt(#fontSize)
        end if
        if tTxtMem.fontStyle <> tElem.getAt(#fontStyle) then
          tTxtMem.fontStyle = tElem.getAt(#fontStyle)
        end if
        if tElem.getAt(#media) = #text then
          if tTxtMem.fixedLineSpace <> tElem.getAt(#fixedLineSpace) then
            tTxtMem.fixedLineSpace = tElem.getAt(#fixedLineSpace)
          end if
        else
          if tElem.getAt(#media) = #field then
            if tTxtMem.lineHeight <> tElem.getAt(#lineHeight) then
              tTxtMem.lineHeight = tElem.getAt(#lineHeight)
            end if
          end if
        end if
      end if
      if voidp(tElem.getAt(#locZ)) then
        tSpr.locZ = pLocZ + i - 1
      else
        tSpr.locZ = integer(tElem.getAt(#locZ)) + pLocZ
      end if
      if not voidp(tElem.getAt(#id)) then
        if tElem.getAt(#Active) = 1 or voidp(tElem.getAt(#Active)) and voidp(tElem.getAt(#type)) then
          getSpriteManager().setEventBroker(tSpr.spriteNum, tElem.getAt(#id))
          if not voidp(tElem.getAt(#cursor)) then
            tSpr.setcursor(tElem.getAt(#cursor))
          end if
          if not voidp(tElem.getAt(#link)) then
            tSpr.setLink(tElem.getAt(#link))
          end if
        end if
        pActSprList.setAt(tLayout.getAt(i).getAt(#id), tSpr)
      end if
      pSpriteData.setAt(i, [])
      tSpriteList.append(tSpr)
    end if
    i = 1 + i
  end repeat
  repeat while me <= undefined
    tSpr = getAt(undefined, tLayout)
    pSpriteList.append(tSpr)
  end repeat
  return(me.refresh())
  exit
end