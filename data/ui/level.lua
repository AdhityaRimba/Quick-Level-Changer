#include "game.lua"

function init()
	gSandboxScale = 0
	gCreateScale = 0
end

function drawLevel(scale, allowDisplayChanges)
	
	if scale == 0.0 then
		gMenusShown = false
		return true 
	end

	if not gMenusShown then
		UiSound("common/options-on.ogg")
		gMenusShown = true
	end
	local open = true
	UiModalBegin()
		UiFont("font/regular.ttf", 26)
		UiColorFilter(1,1,1,scale)
		UiTranslate(UiCenter(), UiMiddle())
		UiAlign("center middle")
		UiScale(1, scale)
		UiWindow(200, 240)
		UiAlign("top left")



		if UiIsKeyPressed("esc") or (not UiIsMouseInRect(200, 240) and UiIsMousePressed()) and gCreateScale == 0 and gSandboxScale == 0 then
			UiSound("common/options-off.ogg")
			gMenusShown = true
			open = false
		end

		UiColor(.0, .0, .0, 0.6)
		UiImageBox("common/box-solid-shadow-50.png", 200, 240, -50, -50)
		UiColor(1,1,1)		
		UiPush()
			UiFont("font/regular.ttf", 26)
			UiScale(1)
			UiTranslate(UiCenter(), 50)
			UiAlign("center middle")
			UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1, 0.8)
			if UiTextButton("Campaign", 130, 40) then 
				gMenusShown = true
				UiSound("common/click.ogg")
				startHub()
			end
			UiTranslate(0, 70)
			if UiTextButton("Sandbox", 130, 40) then 
				UiSound("common/options-on.ogg")
				SetValue("gSandboxScale", 1, "cosine", 0.25)
			end
			UiTranslate(0, 70)
			if UiTextButton("Create", 130, 40) then 
				UiSound("common/options-on.ogg")
				SetValue("gCreateScale", 1, "cosine", 0.25)
			end
			if gSandboxScale == 1 then
				UiPush()
					UiBlur(gSandboxScale)
					UiColor(0.7,0.7,0.7, 0.25*gSandboxScale)
					UiModalBegin()
					if not drawLevelSandbox(gSandboxScale) then
						SetValue("gSandboxScale", 0, "cosine", 0.25)
					end
					UiModalEnd()
				UiPop()
			end
			if gCreateScale == 1 then
				UiPush()
					UiBlur(gCreateScale)
					UiColor(0.7,0.7,0.7, 0.25*gCreateScale)
					UiModalBegin()
					if not drawLevelCreate(gCreateScale) then
						SetValue("gCreateScale", 0, "cosine", 0.25)
					end
					UiModalEnd()
				UiPop()
			end
		UiPop()
	UiModalEnd()
	return open
end

function drawLevelCreate(scale)
	local open = true
	UiPush()
		local w = 800
		local h = 530
		UiScale(scale)
		UiColorFilter(1, 1, 1, scale)
		UiColor(0,0,0, 0.5)
		UiAlign("center middle")
		UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
		UiWindow(w, h)
		UiAlign("left top")
		UiColor(1,1,1)
		if UiIsKeyPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and UiIsMousePressed()) then
			open = false
			gMenusShown = true
			UiSound("common/options-off.ogg")
		end

		UiPush()
			UiFont("font/bold.ttf", 48)
			UiColor(1,1,1)
			UiAlign("center")
			UiTranslate(UiCenter(), 60)
			UiText("CREATE")
		UiPop()
		
		UiPush()
			UiFont("font/regular.ttf", 22)
			UiTranslate(UiCenter(), 100)
			UiAlign("center")
			UiWordWrap(600)
			UiColor(0.8, 0.8, 0.8)
			UiText("Create your own sandbox level using the free voxel modeling program MagicaVoxel. We have provided example levels that you can modify or replace with your own creation. Find out more on our web page:", true)
			UiTranslate(0, 2)
			UiFont("font/bold.ttf", 22)
			UiColor(1, .8, .5)
			UiButtonImageBox("common/nothing.png", 6, 6, 1, 1, 1, 0.8)
			if UiTextButton("www.teardowngame.com/create") then
				Command("game.openurl", "http://www.teardowngame.com/create")
			end

			UiTranslate(0, 70)
			UiPush()
				UiColor(1,1,1)
				UiFont("font/regular.ttf", 26)
				UiButtonImageBox("common/box-outline-6.png", 6, 6, 1, 1, 1)
				if UiTextButton("Basic level", 240, 40) then
					Command("game.startlevel", "../../create/basic.xml")
				end
				UiTranslate(0, 45)
				if UiTextButton("Island level", 240, 40) then
					Command("game.startlevel", "../../create/island.xml")
				end
				UiTranslate(0, 45)
				if UiTextButton("Castle level", 240, 40) then
					Command("game.startlevel", "../../create/castle.xml")
				end
				UiTranslate(0, 45)
				if UiTextButton("Vehicle level", 240, 40) then
					Command("game.startlevel", "../../create/vehicle.xml")
				end
				UiTranslate(0, 45)
				if UiTextButton("Custom level", 240, 40) then
					Command("game.startlevel", "../../create/custom.xml")
				end
			UiPop()

			UiTranslate(0, 250)
			UiFont("font/regular.ttf", 20)
			UiColor(.6, .6, .6)
			UiText("Files located at: " .. GetString("game.path") .. "/create")
		UiPop()
	UiPop()
	return open
end

function isLevelUnlocked(level)
	local missions = ListKeys("savegame.mission")
	local levelMissions = {}
	for i=1,#missions do
		local missionId = missions[i]
		if gMissions[missionId] and GetBool("savegame.mission."..missionId) then
			if gMissions[missionId].level == level then
				return true
			end
		end
	end
	return false
end

function drawLevelSandbox(scale)
	local open = true
	UiPush()
		local w = 800
		local h = 400
		UiScale(scale)
		UiColorFilter(1, 1, 1, scale)
		UiColor(0,0,0, 0.5)
		UiAlign("center middle")
		UiImageBox("common/box-solid-shadow-50.png", w, h, -50, -50)
		UiWindow(w, h)
		UiAlign("left top")
		UiColor(1,1,1)
		if UiIsKeyPressed("esc") or (not UiIsMouseInRect(UiWidth(), UiHeight()) and UiIsMousePressed()) then
			open = false
			gMenusShown = true
			UiSound("common/options-off.ogg")
		end

		UiPush()
			UiFont("font/bold.ttf", 48)
			UiColor(1,1,1)
			UiAlign("center")
			UiTranslate(UiCenter(), 80)
			UiText("SANDBOX")
		UiPop()
		
		UiPush()
			UiFont("font/regular.ttf", 22)
			UiTranslate(200, 90)
			UiWordWrap(420)
			UiColor(0.8, 0.8, 0.8)
			UiText("Free roam sandbox play with unlimited resources and no challenge. Play the campaign to unlock more environments and tools.")
		UiPop()
	
		UiTranslate(10 + UiWidth()/2-(150*#gSandbox)/2, 190)
		UiFont("font/bold.ttf", 22)
		for i=1, #gSandbox do
			UiPush()
				local locked = not isLevelUnlocked(gSandbox[i].level)
				UiPush()
					if locked then
						UiDisableInput()
						UiColorFilter(.5, .5, .5)
					end
					if UiImageButton(gSandbox[i].image) then
						Command("game.startmission", gSandbox[i].id, gSandbox[i].file, gSandbox[i].layers)
					end
				UiPop()
				if locked then
					UiPush()
						UiTranslate(64, 64)
						UiAlign("center middle")
						UiImage("menu/locked.png")
					UiPop()
					if UiIsMouseInRect(128, 128) then
						UiPush()
							UiAlign("center middle")
							UiTranslate(64,  180)
							UiFont("font/regular.ttf", 20)
							UiColor(.8, .8, .8)
							UiText("Unlocked in\ncampaign")
						UiPop()
					end
				end

				UiAlign("center")
				UiTranslate(64, 150)
				UiColor(0.8, 0.8, 0.8)
				UiText(gSandbox[i].name)
			UiPop()
			UiTranslate(150, 0)
		end
	UiPop()
	return open
end