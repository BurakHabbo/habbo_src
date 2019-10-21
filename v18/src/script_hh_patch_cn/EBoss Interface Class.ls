on construct(me)
  pWindowTitle = getText("win_partner_registration", "win_partner_registration")
  return(1)
  exit
end

on deconstruct(me)
  me.hideDialog()
  return(1)
  exit
end

on showDialog(me)
  me.hideDialog()
  if not createWindow(pWindowTitle, "habbo_basic.window", 0, 0, #modal) then
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  if not objectp(tWndObj) then
    return(0)
  end if
  if not tWndObj.merge("cn_partner_registration.window") then
    tWndObj.close()
  end if
  tWndObj.center()
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseDown)
  exit
end

on hideDialog(me)
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  exit
end

on openEBossPopup(me)
  tUserID = me.getComponent().userID()
  tPartnerURL = getVariable("partner.registration.url")
  tPartnerURL = tPartnerURL & string(tUserID)
  openNetPage(tPartnerURL)
  exit
end

on eventProc(me, tEvent, tElemID, tParm)
  if tEvent = #mouseDown then
    if me = "close" then
      me.getComponent().login()
      me.hideDialog()
    end if
  end if
  if tEvent = #mouseUp then
    if me = "cn_partner_enter" then
      me.getComponent().login()
      me.hideDialog()
    else
      if me = "cn_partner_link" then
        me.openEBossPopup()
      end if
    end if
  end if
  exit
end