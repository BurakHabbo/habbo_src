on construct(me)
  pCatchFlag = 0
  pSavedHook = 0
  pToolTipAct = getIntVariable("tooltip.active", 0)
  pToolTipMem = void()
  pToolTipSpr = void()
  pCurrCursor = 0
  pLastCursor = 0
  pDecoder = createObject(#temp, getClassVariable("connection.decoder.class"))
  pDecoder.setKey("sulake1Unique2Key3Generator")
  return(1)
  exit
end

on deconstruct(me)
  if not voidp(pToolTipSpr) then
    releaseSprite(pToolTipSpr.spriteNum)
  end if
  if not voidp(pToolTipMem) then
    removeMember(pToolTipMem.name)
  end if
  pDecoder = void()
  return(1)
  exit
end

on try(me)
  pCatchFlag = 0
  pSavedHook = the alertHook
  the alertHook = me
  return(1)
  exit
end

on catch(me)
  the alertHook = pSavedHook
  return(pCatchFlag)
  exit
end

on createToolTip(me, tText)
  if pToolTipAct then
    if voidp(pToolTipMem) then
      me.prepareToolTip()
    end if
    if voidp(pToolTipSpr) then
      me.prepareToolTip()
    end if
    if voidp(tText) then
      tText = "..."
    end if
    pToolTipSpr.visible = 0
    pToolTipMem.rect = rect(0, 0, length(tText.getProp(#line, 1)) * 8, 20)
    pToolTipMem.text = tText
    pToolTipID = the milliSeconds
    return(me.delay(pToolTipDel, #renderToolTip, pToolTipID))
  end if
  exit
end

on removeToolTip(me, tNextID)
  if pToolTipAct then
    if voidp(tNextID) or pToolTipID = tNextID then
      pToolTipID = void()
      pToolTipSpr.visible = 0
      return(1)
    end if
  end if
  exit
end

on renderToolTip(me, tNextID)
  if pToolTipAct then
    if tNextID <> pToolTipID or voidp(pToolTipID) then
      return(0)
    end if
    pToolTipSpr.loc = the mouseLoc + [-2, 15]
    pToolTipSpr.visible = 1
    me.delay(pToolTipDel * 2, #removeToolTip, pToolTipID)
  end if
  exit
end

on setcursor(me, ttype)
  if me = void() then
    ttype = 0
  else
    if me = #arrow then
      ttype = 0
    else
      if me = #ibeam then
        ttype = 1
      else
        if me = #crosshair then
          ttype = 2
        else
          if me = #crossbar then
            ttype = 3
          else
            if me = #timer then
              ttype = 4
            else
              if me = #previous then
                ttype = pLastCursor
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  cursor(ttype)
  pLastCursor = pCurrCursor
  pCurrCursor = ttype
  return(1)
  exit
end

on openNetPage(me, tURL_key)
  if not stringp(tURL_key) then
    return(0)
  end if
  if textExists(tURL_key) then
    tURL = getText(tURL_key, tURL_key)
  else
    tURL = tURL_key
  end if
  gotoNetPage(tURL, "_new")
  put("Open page:" && tURL)
  return(1)
  exit
end

on showLoadingBar(me, tLoadID, tProps)
  tObj = createObject(#random, getClassVariable("loading.bar.class"))
  if not tObj.define(tLoadID, tProps) then
    removeObject(tObj.getID())
    return(error(me, "Couldn't initialize loading bar instance!", #showLoadingBar))
  end if
  return(tObj.getID())
  exit
end

on getUniqueID(me)
  return(pDecoder.encipher(string(the milliSeconds)))
  exit
end

on getMachineID(me)
  me.try()
  tMachineID = getPref(getVariable("pref.value.id"))
  if voidp(tMachineID) then
    tMachineID = me.getUniqueID()
    setPref(getVariable("pref.value.id"), tMachineID)
  end if
  if me.catch() then
    getErrorManager().SendMailAlert("Failed #setPref!", tMachineID, #getMachineID)
  end if
  return(tMachineID)
  exit
end

on secretDecode(me, tKey)
  tLength = tKey.length
  if tLength mod 2 = 1 then
    tLength = tLength - 1
  end if
  tTable = tKey.getProp(#char, 1, tKey.length / 2)
  tKey = tKey.getProp(#char, 1 + tKey.length / 2, tLength)
  tCheckSum = 0
  i = 1
  repeat while i <= tKey.length
    c = tKey.getProp(#char, i)
    a = offset(c, tTable) - 1
    if a mod 2 = 0 then
      a = a * 2
    end if
    if i - 1 mod 3 = 0 then
      a = a * 3
    end if
    if a < 0 then
      a = tKey.length mod 2
    end if
    tCheckSum = tCheckSum + a
    tCheckSum = bitXor(tCheckSum, a * power(2, i - 1 mod 3 * 8))
    i = 1 + i
  end repeat
  return(tCheckSum)
  exit
end

on readValueFromField(me, tField, tDelimiter, tSearchedKey)
  tStr = field(0)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = "\r"
  end if
  the itemDelimiter = tDelimiter
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getProp(#item, i)
    if tPair.getPropRef(#word, 1).getProp(#char, 1) <> "#" and tPair <> "" then
      the itemDelimiter = "="
      tProp = tPair.getPropRef(#item, 1).getProp(#word, 1, tPair.getPropRef(#item, 1).count(#word))
      tValue = tPair.getProp(#item, 2, tPair.count(#item))
      tValue = tValue.getProp(#word, 1, tValue.count(#word))
      if tProp = tSearchedKey then
        if not tValue contains space() and integerp(integer(tValue)) then
          if length(string(integer(tValue))) = length(tValue) then
            tValue = integer(tValue)
          end if
        else
          if floatp(float(tValue)) then
            tValue = float(tValue)
          end if
        end if
        if stringp(tValue) then
          j = 1
          repeat while j <= length(tValue)
            if me = 228 then
            else
              if me = 246 then
              end if
            end if
            j = 1 + j
          end repeat
        end if
        the itemDelimiter = tDelim
        return(tValue)
      end if
    end if
    the itemDelimiter = tDelimiter
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  return(0)
  exit
end

on print(me, tObj, tMsg)
  tObj = string(tObj)
  tObj = tObj.getProp(#word, 2, tObj.count(#word) - 2)
  tObj = tObj.getProp(#char, 2, length(tObj))
  put("Print:" & "\r" & "\t" && "Object: " && tObj & "\r" & "\t" && "Message:" && tMsg)
  exit
end

on prepareToolTip(me)
  if pToolTipAct then
    tFontStruct = getStructVariable("struct.font.tooltip")
    pToolTipMem = member(createMember("ToolTip Text", #field))
    pToolTipMem.boxType = #adjust
    pToolTipMem.wordWrap = 0
    pToolTipMem.rect = rect(0, 0, 10, 20)
    pToolTipMem.border = 1
    pToolTipMem.margin = 4
    pToolTipMem.alignment = "center"
    pToolTipMem.font = tFontStruct.getaProp(#font)
    pToolTipMem.fontSize = tFontStruct.getaProp(#fontSize)
    pToolTipMem.color = tFontStruct.getaProp(#color)
    pToolTipSpr = sprite(reserveSprite(me.getID()))
    pToolTipSpr.member = pToolTipMem
    pToolTipSpr.visible = 0
    ERROR.locZ = 0
    pToolTipID = void()
    pToolTipDel = getIntVariable("tooltip.delay", 2000)
  end if
  exit
end

on alertHook(me)
  pCatchFlag = 1
  the alertHook = pSavedHook
  return(1)
  exit
end