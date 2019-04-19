on construct(me)
  pWallPatterns = field(0)
  pFloorPatterns = field(0)
  pWallDefined = 0
  pFloorDefined = 0
  pWallModel = string(getVariable("room.default.wall", "201"))
  pFloorModel = string(getVariable("room.default.floor", "203"))
  return(1)
  exit
end

on prepare(me)
  if not pWallDefined then
    me.setWallPaper(pWallModel)
  end if
  if not pFloorDefined then
    me.setFloorPattern(pFloorModel)
  end if
  return(1)
  exit
end

on setProperty(me, tKey, tValue)
  if me = "wallpaper" then
    return(me.setWallPaper(tValue))
  else
    if me = "floor" then
      return(me.setFloorPattern(tValue))
    end if
  end if
  exit
end

on setWallPaper(me, tIndex)
  tField = pWallPatterns.getProp(#line, integer(tIndex.getProp(#char, 1, length(tIndex) - 2)))
  if tField = "" then
    return(error(me, "Invalid wall color index:" && tIndex, #setWallPaper))
  end if
  if not memberExists(tField) then
    error(me, "Invalid wall color index:" && tIndex, #setWallPaper)
    return(me.setWallPaper(string(getVariable("room.default.wall"))))
  end if
  tmodel = field(0)
  tPattern = tmodel.getProp(#line, integer(tIndex.getProp(#char, length(string(tIndex)) - 1, length(string(tIndex)))))
  if tPattern = "" then
    return(error(me, "Invalid wall color index:" && tIndex, #setWallPaper))
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.getProp(#item, 1)
  tPalette = tPattern.getProp(#item, 2)
  tR = integer(tPattern.getProp(#item, 3))
  tG = integer(tPattern.getProp(#item, 4))
  tB = integer(tPattern.getProp(#item, 5))
  tColor = rgb(tR, tG, tB)
  tColors = ["left":tColor - rgb(16, 16, 16), "right":tColor, "a":tColor - rgb(16, 16, 16), "b":tColor]
  the itemDelimiter = "_"
  tPieceList = getThread(#room).getComponent().getPassiveObject(#list)
  if tPieceList.count = 0 then
    pWallModel = tIndex
    pWallDefined = 0
    return(0)
  end if
  repeat while me <= undefined
    tPiece = getAt(undefined, tIndex)
    tSprList = tPiece.getSprites()
    repeat while me <= undefined
      tSpr = getAt(undefined, tIndex)
      tdir = name.getProp(#item, 1)
      tName = name.getProp(#item, 2)
      tdata = tSpr.getProp(length(member.name) - 7, tSpr, length(member.name))
      tColor = tdir
      if tColor = "corner" then
        if tdata.getProp(#char, 2) = "a" then
          tColor = "right"
        else
          tColor = "left"
        end if
      end if
      if memberExists(tdir & "_" & tName & "_" & ttype & tdata) then
        tSpr.member = member(getmemnum(tdir & "_" & tName & "_" & ttype & tdata))
        tSpr.bgColor = tColors.getAt(tColor)
        member.paletteRef = member(getmemnum(tPalette))
        if pWallDefined = 0 then
          tSpr.locZ = tSpr.locZ - 975
        end if
        if tSpr.blend = 100 then
          tSpr.ink = 41
        end if
      else
        error(me, "Wall member not found:" && tdir & "_" & tName & "_" & ttype & tdata, #setWallPaper)
      end if
    end repeat
  end repeat
  the itemDelimiter = tDelim
  pWallDefined = 1
  return(1)
  exit
end

on setFloorPattern(me, tIndex)
  tField = pFloorPatterns.getProp(#line, integer(tIndex.getProp(#char, 1, length(tIndex) - 2)))
  if tField = "" then
    return(error(me, "Invalid floor color index:" && tIndex, #setFloorPattern))
  end if
  if not memberExists(tField) then
    error(me, "Invalid floor color index:" && tIndex, #setFloorPatterns)
    return(me.setFloorPattern(string(getVariable("room.default.floor"))))
  end if
  tmodel = field(0)
  tPattern = tmodel.getProp(#line, integer(tIndex.getProp(#char, length(string(tIndex)) - 1, length(string(tIndex)))))
  if tPattern = "" then
    return(error(me, "Invalid floor color index:" && tIndex, #setFloorPattern))
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  ttype = tPattern.getProp(#item, 1)
  tPalette = tPattern.getProp(#item, 2)
  tR = integer(tPattern.getProp(#item, 3))
  tG = integer(tPattern.getProp(#item, 4))
  tB = integer(tPattern.getProp(#item, 5))
  tColor = rgb(tR, tG, tB)
  if not getThread(#room).getInterface().getRoomVisualizer() then
    pFloorModel = tIndex
    pFloorDefined = 0
    return(0)
  end if
  tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
  tPieceId = 1
  tSpr = tVisualizer.getSprById("floor" & tPieceId)
  repeat while not tSpr = 0
    tMemNum = getmemnum(#char & 7.getProp(tSpr, member, name.length))
    if tMemNum > 0 then
      tSpr.member = member(tMemNum)
    end if
    tSpr.bgColor = tColor
    member.paletteRef = member(getmemnum(tPalette))
    tSpr.ink = 41
    -- UNK_40 6
    ERROR.locZ = ERROR
    tPieceId = tPieceId + 1
    tSpr = tVisualizer.getSprById("floor" & tPieceId)
  end repeat
  the itemDelimiter = tDelim
  pFloorDefined = 1
  return(1)
  exit
end