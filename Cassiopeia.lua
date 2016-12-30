local ver = "0.01"


if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end


if GetObjectName(GetMyHero()) ~= "Cassiopeia" then return end


require("DamageLib")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/Cassiopeia/master/Cassiopeia.lua', SCRIPT_PATH .. 'Cassiopeia.lua', function() PrintChat('<font color = "#00FFFF">Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No updates found!')
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/Jax/master/Cassiopeia.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0

local CassiopeiaMenu = Menu("Cassiopeia", "Cassiopeia")

CassiopeiaMenu:SubMenu("Combo", "Combo")

CassiopeiaMenu.Combo:Boolean("Q", "Use Q in combo", true)
CassiopeiaMenu.Combo:Boolean("W", "Use W in combo", true)
CassiopeiaMenu.Combo:Boolean("E", "Use E in combo", true)
CassiopeiaMenu.Combo:Boolean("R", "Use R in combo", true)
CassiopeiaMenu.Combo:Slider("RX", "X Enemies to Cast R",3,1,5,1)
CassiopeiaMenu.Combo:Boolean("Gunblade", "Use Gunblade", true)
CassiopeiaMenu.Combo:Boolean("Randuins", "Use Randuins", true)


CassiopeiaMenu:SubMenu("AutoMode", "AutoMode")
CassiopeiaMenu.AutoMode:Boolean("Level", "Auto level spells", false)
CassiopeiaMenu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
CassiopeiaMenu.AutoMode:Boolean("Q", "Auto Q", false)
CassiopeiaMenu.AutoMode:Boolean("W", "Auto W", false)
CassiopeiaMenu.AutoMode:Boolean("E", "Auto E", false)
CassiopeiaMenu.AutoMode:Boolean("R", "Auto R", false)

CassiopeiaMenu:SubMenu("LaneClear", "LaneClear")
CassiopeiaMenu.LaneClear:Boolean("Q", "Use Q", true)
CassiopeiaMenu.LaneClear:Boolean("W", "Use W", true)
CassiopeiaMenu.LaneClear:Boolean("E", "Use E", true)


CassiopeiaMenu:SubMenu("Harass", "Harass")
CassiopeiaMenu.Harass:Boolean("Q", "Use Q", true)
CassiopeiaMenu.Harass:Boolean("W", "Use W", true)

CassiopeiaMenu:SubMenu("KillSteal", "KillSteal")
CassiopeiaMenu.KillSteal:Boolean("Q", "KS w Q", true)
CassiopeiaMenu.KillSteal:Boolean("W", "KS w W", true)
CassiopeiaMenu.KillSteal:Boolean("E", "KS w E", true)
CassiopeiaMenu.KillSteal:Boolean("R", "KS w R", true)

CassiopeiaMenu:SubMenu("AutoIgnite", "AutoIgnite")
CassiopeiaMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

CassiopeiaMenu:SubMenu("Drawings", "Drawings")
CassiopeiaMenu.Drawings:Boolean("DQ", "Draw Q Range", true)

CassiopeiaMenu:SubMenu("SkinChanger", "SkinChanger")
CassiopeiaMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
CassiopeiaMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 4, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	      local target = GetCurrentTarget()
        
        local Gunblade = GetItemSlot(myHero, 3146)       
        local Cutlass = GetItemSlot(myHero, 3144)
        local Randuins = GetItemSlot(myHero, 3143)

	--AUTO LEVEL UP
	if CassiopeiaMenu.AutoMode.Level:Value() then

			spellorder = {_E, _W, _Q, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
          if Mix:Mode() == "Harass" then
            if CassiopeiaMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 850) then
				if target ~= nil then 
                                      CastTargetSpell(target, _Q)
                                end
            end

            if CassiopeiaMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 800) then
				CastSpell(_W)
            end     
          end

	--COMBO
	  if Mix:Mode() == "Combo" then
        

            if CassiopeiaMenu.Combo.Randuins:Value() and Randuins > 0 and Ready(Randuins) and ValidTarget(target, 500) then
			CastSpell(Randuins)
            end

           
            

            if CassiopeiaMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 700) then
			 CastSpell(_E)
	    end

            if CassiopeiaMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 850) then
		     if target ~= nil then 
                         CastTargetSpell(target, _Q)
                     end
            end

            

            if CassiopeiaMenu.Combo.Gunblade:Value() and Gunblade > 0 and Ready(Gunblade) and ValidTarget(target, 700) then
			           CastTargetSpell(target, Gunblade)
            end

            

	          if CassiopeiaMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 800) then
			            CastSpell(_W)
	          end
	    
	    
            if CassiopeiaMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 825) and (EnemiesAround(myHeroPos(), 825) >= CassiopeiaMenu.Combo.RX:Value()) then
			CastSpell(_R)
            end

          end

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 850) and CassiopeiaMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
		         if target ~= nil then 
                                      CastTargetSpell(target, _Q)
		         end
                end 

                
		if IsReady(_W) and ValidTarget(enemy, 800) and CassiopeiaMenu.KillSteal.W:Value() and GetHP(enemy) < getdmg("W",enemy) then
		                      CastSpell(_W)
  
                end	
			
			
		if IsReady(_E) and ValidTarget(enemy, 700) and CassiopeiaMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then
		                      CastSpell(_E)
  
                end
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if CassiopeiaMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 850) then
	        	CastTargetSpell(closeminion, _Q)
                end

                if CassiopeiaMenu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 800) then
	        	CastSpell(_W)
	        end

                if CassiopeiaMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 700) then
	        	CastSpell(_E)
	        end

               
          end
      end
        --AutoMode
        if CassiopeiaMenu.AutoMode.Q:Value() then        
          if Ready(_Q) and ValidTarget(target, 850) then
		      CastTargetSpell(target, _Q)
          end
        end 
        if CassiopeiaMenu.AutoMode.W:Value() then        
          if Ready(_W) and ValidTarget(target, 800) then
	  	      CastSpell(_W)
          end
        end
        if CassiopeiaMenu.AutoMode.E:Value() then        
	  if Ready(_E) and ValidTarget(target, 700) then
		      CastSpell(_E)
	  end
        end
        if JaxMenu.AutoMode.R:Value() then        
	  if Ready(_R) and ValidTarget(target, 825) then
		      CastSpell(_R)
	  end
        end
                
	--AUTO GHOST
	if CassiopeiaMenu.AutoMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

OnDraw(function (myHero)
        
         if CassiopeiaMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 850, 0, 150, GoS.Black)
	end

end)



local function SkinChanger()
	if CassiopeiaMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Cassiopeia</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')




