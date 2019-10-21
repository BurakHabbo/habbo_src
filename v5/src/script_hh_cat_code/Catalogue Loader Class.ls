on construct(me)
  pState = 0
  pFrameCounter = 0
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on showLoadingScreen(me)
  pState = 1
  tWinObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWinObj then
    return()
  end if
  if not tWinObj.elementExists("ctlg_loading_box") then
    tWinObj.merge("ctlg_loading.window")
    tid = "ctlg_loading_bg"
    if tWinObj.elementExists(tid) then
      tWinObj.getElement(tid).setProperty(#visible, 1)
      tWinObj.getElement(tid).setProperty(#blend, 70)
    end if
    repeat while me <= undefined
      tid = getAt(undefined, undefined)
      if tWinObj.elementExists(tid) then
        tWinObj.getElement(tid).setProperty(#visible, 1)
        tWinObj.getElement(tid).setProperty(#blend, 100)
      end if
    end repeat
  end if
  if pAnimImage.ilk <> #image then
    if memberExists("ctlg_loading_icon2") then
      pAnimImage = member(getmemnum("ctlg_loading_icon2")).image
      pQuad = [point(0, 0), point(pAnimImage.width, 0), point(pAnimImage.width, pAnimImage.height), point(0, pAnimImage.height)]
    end if
  end if
  pFrameCounter = 100
  update(me)
  receiveUpdate(me.getID())
  exit
end

on hideLoadingScreen(me)
  pState = 0
  removeUpdate(me.getID())
  tWinObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWinObj then
    return()
  end if
  if tWinObj.elementExists("ctlg_loading_box") then
    tWinObj.unmerge()
  end if
  exit
end

on update(me)
  if not pState then
    return()
  end if
  if pAnimImage.ilk <> #image then
    return()
  end if
  if pFrameCounter > 2 then
    tWinObj = getThread(#catalogue).getInterface().getCatalogWindow()
    if not tWinObj then
      removeUpdate(me.getID())
    end if
    tid = "ctlg_loading_anim"
    if tWinObj.elementExists(tid) then
      t1 = pQuad.getAt(1)
      t2 = pQuad.getAt(2)
      t3 = pQuad.getAt(3)
      t4 = pQuad.getAt(4)
      pQuad = [t2, t3, t4, t1]
      tImage = tWinObj.getElement(tid).getProperty(#image)
      tImage.copyPixels(pAnimImage, pQuad, pAnimImage.rect)
      tWinObj.getElement(tid).feedImage(tImage)
    end if
    pFrameCounter = 0
  end if
  pFrameCounter = pFrameCounter + 1
  exit
end