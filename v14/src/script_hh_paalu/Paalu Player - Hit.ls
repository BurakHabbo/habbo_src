on construct(me)
  pSprite = sprite(reserveSprite("Paalu violence dir:" && pDirection))
  pSprite.member = member(getmemnum("paalu hit" && pDirection && random(4)))
  pSprite.visible = 0
  pSprite.ink = 36
  pActive = 0
  pCounter = 0
  return(1)
  exit
end

on deconstruct(me)
  if ilk(pSprite, #sprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  pSprite = void()
  pActive = 0
  pCounter = 0
  return(1)
  exit
end

on define(me, tPart, tProps)
  pDirection = tProps.getAt(#dir)
  if pDirection = 0 then
    pAnimOffset = point(0, 0)
    pLocOffset = point(-24, -8)
  else
    pAnimOffset = point(0, 0)
    pLocOffset = point(24, -8)
  end if
  pSprite.visible = 0
  pActive = 0
  pCounter = 0
  return(1)
  exit
end

on reset(me)
  exit
end

on prepare(me)
  if voidp(pSprite) then
    return()
  end if
  if pActive then
    pSprite.loc = pSprite.loc + pAnimOffset
    pCounter = pCounter + 1
    if pCounter > 4 then
      pActive = 0
      pCounter = 0
      pSprite.visible = 0
    end if
  end if
  exit
end

on render(me)
  exit
end

on status(me, tAction, tBalance, tSprLoc, tSprLocZ, tHit)
  if tHit then
    pActive = 1
    pSprite.member = member(getmemnum("paalu hit" && pDirection && random(4)))
    pSprite.loc = tSprLoc + pLocOffset
    pSprite.locZ = tSprLocZ - 1
    pSprite.visible = 1
    pCounter = 0
  end if
  exit
end