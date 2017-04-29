
local ver = "0.11"

if GetObjectName(GetMyHero()) ~= "Cassiopeia" then return end

require('MixLib')
require("DamageLib")
require("OpenPredict")
require("Deftlib")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/Cassiopeia/master/Cassiopeia.lua', SCRIPT_PATH .. 'Cassiopeia.lua', function() PrintChat('<font color = "#00FFFF">Cassiopeia Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No new Cassiopeia updates found!')
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/Cassiopeia/master/Cassiopeia.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0

local CassiopeiaMenu = Menu("Cassiopeia", "Cassiopeia")

CassiopeiaMenu:SubMenu("Combo", "Combo")

CassiopeiaMenu.Combo:Boolean("Q", "Use Q in combo", true)
CassiopeiaMenu.Combo:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
CassiopeiaMenu.Combo:Boolean("W", "Use W in combo", true)
CassiopeiaMenu.Combo:Slider("Wpred", "W Hit Chance", 3,0,10,1)
CassiopeiaMenu.Combo:Boolean("E", "Use E Always", false)
CassiopeiaMenu.Combo:Boolean("EP", "Use E if Poisoned", true)
CassiopeiaMenu.Combo:Boolean("R", "Use R Always", true)
CassiopeiaMenu.Combo:Boolean("RF", "Use R if Facing", false)
CassiopeiaMenu.Combo:Slider("Rpred", "R Hit Chance", 3,0,10,1)
CassiopeiaMenu.Combo:Slider("RX", "X Enemies to Cast R",3,1,5,1)
CassiopeiaMenu.Combo:Boolean("Gunblade", "Use Gunblade", true)
CassiopeiaMenu.Combo:Boolean("Randuins", "Use Randuins", true)


CassiopeiaMenu:SubMenu("AutoMode", "AutoMode")
CassiopeiaMenu.AutoMode:Boolean("Level", "Auto level spells", false)
CassiopeiaMenu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
CassiopeiaMenu.AutoMode:Boolean("Q", "Auto Q", false)
CassiopeiaMenu.AutoMode:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
CassiopeiaMenu.AutoMode:Boolean("W", "Auto W", false)
CassiopeiaMenu.AutoMode:Slider("Wpred", "W Hit Chance", 3,0,10,1)
CassiopeiaMenu.AutoMode:Boolean("E", "Auto E", false)
CassiopeiaMenu.AutoMode:Boolean("R", "Auto R", false)
CassiopeiaMenu.AutoMode:Slider("Rpred", "R Hit Chance", 3,0,10,1)
CassiopeiaMenu.AutoMode:Slider("RX", "X Enemies to Cast R",3,1,5,1)

CassiopeiaMenu:SubMenu("AutoFarm", "AutoFarm")
CassiopeiaMenu.AutoFarm:Boolean("Q", "Auto Q", false)
CassiopeiaMenu.AutoFarm:Boolean("W", "Auto W", false)
CassiopeiaMenu.AutoFarm:Boolean("E", "Auto E", false)



CassiopeiaMenu:SubMenu("LaneClear", "LaneClear")
CassiopeiaMenu.LaneClear:Boolean("Q", "Use Q", true)
CassiopeiaMenu.LaneClear:Boolean("W", "Use W", true)
CassiopeiaMenu.LaneClear:Boolean("E", "Use E", true)


CassiopeiaMenu:SubMenu("Harass", "Harass")
CassiopeiaMenu.Harass:Boolean("Q", "Use Q", true)
CassiopeiaMenu.Harass:Boolean("W", "Use W", true)

CassiopeiaMenu:SubMenu("KillSteal", "KillSteal")
CassiopeiaMenu.KillSteal:Boolean("Q", "KS w Q", true)
CassiopeiaMenu.KillSteal:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
CassiopeiaMenu.KillSteal:Boolean("W", "KS w W", true)
CassiopeiaMenu.KillSteal:Slider("Wpred", "W Hit Chance", 3,0,10,1)
CassiopeiaMenu.KillSteal:Boolean("E", "KS w E", true)
CassiopeiaMenu.KillSteal:Boolean("R", "KS w R", true)
CassiopeiaMenu.KillSteal:Slider("Rpred", "R Hit Chance", 3,0,10,1)

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
        local CassiopeiaQ = {delay = 0.6, range = 850, width = 75, speed = math.huge}
        local CassiopeiaW = {delay = 0.5, range = 900, width = 160, speed = 2500}        
        local CassiopeiaR = {delay = 0.6, range = 825, angle = 80, speed = math.huge}

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
                                      CastSkillShot(_Q, target)
                                
            end

            if CassiopeiaMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 800) then
				       CastSkillShot(_W, target)
            end     
          end

	--COMBO
	  if Mix:Mode() == "Combo" then
        

            if CassiopeiaMenu.Combo.Randuins:Value() and Randuins > 0 and Ready(Randuins) and ValidTarget(target, 500) then
			           CastSpell(Randuins)
            end
			
	    if CassiopeiaMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 850) then
                 local QPred = GetPrediction(target,CassiopeiaQ)
                 if QPred.hitChance > (CassiopeiaMenu.Combo.Qpred:Value() * 0.1) then
                           CastSkillShot(_Q, QPred.castPos)
                 end
            end	
                   
            if CassiopeiaMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 700) then
			             CastTargetSpell(target,_E)
	          end
			
	    if CassiopeiaMenu.Combo.EP:Value() and Ready(_E) and ValidTarget(target, 700) and target.isPoisoned then
			             CastTargetSpell(target,_E)
	          end	
           
            if CassiopeiaMenu.Combo.Gunblade:Value() and Gunblade > 0 and Ready(Gunblade) and ValidTarget(target, 700) then
			           CastTargetSpell(target, Gunblade)
            end
          
            if CassiopeiaMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 800) then
                local WPred = GetPrediction(target,CassiopeiaW)
                       if WPred.hitChance > (CassiopeiaMenu.Combo.Wpred:Value() * 0.1) then
                                 CastSkillShot(_W, WPred.castPos)
                       end
            end
	    	    
            if CassiopeiaMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 825) and (EnemiesAround(myHeroPos(), 825) >= CassiopeiaMenu.Combo.RX:Value()) then
            local RPred = GetPrediction(target,CassiopeiaR)
                   if RPred.hitChance > (CassiopeiaMenu.Combo.Rpred:Value() * 0.1) then
                             CastSkillShot(_R,RPred.castPos)
                   end
        
            end
			
	    if IsFacing(target, 825) and CassiopeiaMenu.Combo.RF:Value() and Ready(_R) and ValidTarget(target, 825) and (EnemiesAround(myHeroPos(), 825) >= CassiopeiaMenu.Combo.RX:Value()) then
                   local RPred = GetPrediction(target,CassiopeiaR)
                   if RPred.hitChance > (CassiopeiaMenu.Combo.Rpred:Value() * 0.1) then
                             CastSkillShot(_R,RPred.castPos)
                   end
        
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

    --KillSteal

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 850) and CassiopeiaMenu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
                       local QPred = GetPrediction(target,CassiopeiaQ)
                       if QPred.hitChance > (CassiopeiaMenu.KillSteal.Qpred:Value() * 0.1) then
                                 CastSkillShot(_Q, QPred.castPos)
                       end
            end

                
		         if IsReady(_W) and ValidTarget(enemy, 800) and CassiopeiaMenu.KillSteal.W:Value() and GetHP(enemy) < getdmg("W",enemy) then
                    local WPred = GetPrediction(target,CassiopeiaW)
                    if WPred.hitChance > (CassiopeiaMenu.KillSteal.Wpred:Value() * 0.1) then
                                  CastSkillShot(_W, WPred.castPos)
                    end
             end
			
			
		         if IsReady(_E) and ValidTarget(enemy, 700) and CassiopeiaMenu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then
		                      CastTargetSpell(target,_E)
  
                end

              if CassiopeiaMenu.KillSteal.R:Value() and Ready(_R) and ValidTarget(target, 825) and GetHP(enemy) < getdmg("R",enemy) then
                       local RPred = GetPrediction(target,CassiopeiaR)
                       if RPred.hitChance > (CassiopeiaMenu.KillSteal.Rpred:Value() * 0.1) then
                                 CastSkillShot(_R,RPred.castPos)
                       end
            
                end
            
              end

    
      --Laneclear	
      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if CassiopeiaMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 850) then
	        	CastSkillShot(_Q, closeminion)
                end

                if CassiopeiaMenu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 800) then
	        	CastSkillShot(_W, closeminion)
	        end

                if CassiopeiaMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 700) then
	        	CastTargetSpell(closeminion, _E)
	        end

               
          end
      end

      --Auto on minions
          for _, minion in pairs(minionManager.objects) do
      			
      			   	
              if CassiopeiaMenu.AutoFarm.Q:Value() and Ready(_Q) and ValidTarget(minion, 850) and GetCurrentHP(minion) < CalcDamage(myHero,minion,QDmg,Q) then
                  CastSkillShot(_Q, minion)
              end

              if CassiopeiaMenu.AutoFarm.W:Value() and Ready(_W) and ValidTarget(minion, 800) and GetCurrentHP(minion) < CalcDamage(myHero,minion,WDmg,W) then
                  CastSkillShot(_Q, minion)
              end

              if CassiopeiaMenu.AutoFarm.E:Value() and Ready(_E) and ValidTarget(minion, 700) and GetCurrentHP(minion) < CalcDamage(myHero,minion,EDmg,E) then
                  CastTargetSpell(minion, _E)
              end
          end


      


      
      --AutoMode
      
        if CassiopeiaMenu.AutoMode.Q:Value() and ValidTarget(target, 850) then        
               local QPred = GetPrediction(target,CassiopeiaQ)
               if QPred.hitChance > (CassiopeiaMenu.AutoMode.Qpred:Value() * 0.1) then
                         CastSkillShot(_Q, QPred.castPos)
               end
       end

        
        if CassiopeiaMenu.AutoMode.W:Value() and ValidTarget(target, 800) then        
               local WPred = GetPrediction(target,CassiopeiaW)
               if WPred.hitChance > (CassiopeiaMenu.AutoMode.Wpred:Value() * 0.1) then
                         CastSkillShot(_W, WPred.castPos)
               end
        end
    
        if CassiopeiaMenu.AutoMode.E:Value() then        
	           if Ready(_E) and ValidTarget(target, 700) then
		                CastTargetSpell(target,_E)
	           end
        end
        if CassiopeiaMenu.AutoMode.R:Value() and Ready(_R) and ValidTarget(target, 825) and (EnemiesAround(myHeroPos(), 825) >= CassiopeiaMenu.AutoMode.RX:Value()) then
               local RPred = GetPrediction(target,CassiopeiaR)
               if RPred.hitChance > (CassiopeiaMenu.AutoMode.Rpred:Value() * 0.1) then
                         CastSkillShot(_R,RPred.castPos)
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
