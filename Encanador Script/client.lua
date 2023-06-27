local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
enCS = Tunnel.getInterface("encanador")

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------

local destino = 0
local emServico = false

local coordsInicio = { ['x'] = -683.3, ['y'] = -876.19, ['z'] = 24.5 }   --  -683.3, -876.19,  24.5

local coordsRota = {
	[1] = { ['x'] = 329.88, ['y'] = -994.98, ['z'] = 29.3 },
	[2] = { ['x'] = 65.11, ['y'] = -267.58, ['z'] = 48.19 },
	[3] = { ['x'] = 141.86, ['y'] = -240.03, ['z'] = 51.52 },
	[4] = { ['x'] = 0.92, ['y'] = -200.44, ['z'] = 52.75 },
	[5] = { ['x'] = 855.68, ['y'] = -579.74, ['z'] = 58.08 },
	[6] = { ['x'] = 1381.47, ['y'] = -2100.16, ['z'] = 54.44 },
	[7] = { ['x'] = 1024.1, ['y'] = -1742.55, ['z'] = 35.48 },
	[8] = { ['x'] = -207.89, ['y'] = 178.13, ['z'] = 77.33 },
	[9] = { ['x'] = -807.68, ['y'] = 45.12, ['z'] = 48.81 },
	[10] = { ['x'] = -27.99, ['y'] = -232.69, ['z'] = 46.3 },
	[11] = { ['x'] = 93.8, ['y'] = -274.92, ['z'] = 47.44 },
	[12] = { ['x'] = 352.43, ['y'] = 344.74, ['z'] = 105.16 },
	[13] = { ['x'] = 182.6, ['y'] = 294.18, ['z'] = 105.34 },
	[14] = { ['x'] = -268.51, ['y'] = 203.65, ['z'] = 85.73 },
	[15] = { ['x'] = -135.34, ['y'] = 147.89, ['z'] = 77.51 },
	[16] = { ['x'] = -1071.97, ['y'] = -501.94, ['z'] = 36.56 },
	[17] = { ['x'] = -1189.4, ['y'] = -554.02, ['z'] = 27.87 },
	[18] = { ['x'] = -675.34, ['y'] = -432.85, ['z'] = 35.12 }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ENCANADOR
-----------------------------------------------------------------------------------------------------------------------------------------
local msgMostrada = false
local vehicle = nil
Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		local ped = PlayerPedId()
		if not emServico then		
			local distancia = GetDistanceBetweenCoords(GetEntityCoords(ped), coordsInicio.x,coordsInicio.y,coordsInicio.z)
			if distancia < 10 then
				sleep = 1	
				DrawMarker(1,coordsInicio.x,coordsInicio.y,coordsInicio.z-1.0,0,0,0,0,0,130.0,0.7,0.7,1.0,50,150,50,120,0,1,0,0)
				if distancia < 1.2 then
					DrawText3D(coordsInicio.x,coordsInicio.y,coordsInicio.z, "~g~E ~w~PARA INICIAR O EXPEDIENTE.")
					if IsControlJustPressed(0,38) then
						if enCS.CheckItem() then
							emServico = true
							destino = parseInt(math.random(#coordsRota))
							CriandoBlip(coordsRota, destino)
							TriggerEvent("Notify","sucesso","Você entrou em serviço.")
						else
							TriggerEvent("Notify","negado","Você precisa de uma chave grifo.", 5000)
						end
					end
				else
					msgMostrada = false
				end
			end
		else -- ESTOU EM SERVICO
			sleep = 1
			if IsPedInAnyVehicle(ped) then
				local veiculoAtual = GetVehiclePedIsIn(ped)
				if GetEntityModel(veiculoAtual) ~= GetHashKey("utillitruck3") then
					emServico = false
					RemoveBlip(blip)
					DeleteEntity(vehicle)
				else
					vehicle = GetVehiclePedIsIn(ped)
				end
			end

			local distancia = GetDistanceBetweenCoords(GetEntityCoords(ped), coordsRota[destino].x,coordsRota[destino].y,coordsRota[destino].z)
			if distancia < 10 then
				DrawMarker(1,coordsRota[destino].x,coordsRota[destino].y,coordsRota[destino].z-1.0,0,0,0,0,0,130.0,0.7,0.7,1.0,50,150,50,120,0,1,0,0)
				if distancia < 1.2 then
					DrawText3D(coordsRota[destino].x,coordsRota[destino].y,coordsRota[destino].z, "~g~E ~w~PARA CONSERTAR.")
					if IsControlJustPressed(0,38) then
						if GetEntityModel(vehicle) == GetHashKey("utillitruck3") then
							RemoveBlip(blip)							
							TriggerEvent('cancelando',true)	
							vRP._playAnim(false,{{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"}},true)
							TriggerEvent("progress",5000,"Consertando...")
							SetTimeout(5000,function()
								TriggerEvent('cancelando',false)
								vRP._stopAnim(false)						
								enCS.CheckPayment()								
								local destinoAtual = destino								
								destino = parseInt(math.random(#coordsRota))
								while destino == destinoAtual do 
									destino = parseInt(math.random(#coordsRota))
								end
								if destino ~= destinoAtual then
									CriandoBlip(coordsRota, destino)
								end
							end)
						else
							TriggerEvent("Notify","negado","Você precisa usar o veículo do serviço.", 5000)
						end
					end
				end
			end

			drawTxt("~r~F7 ~w~PARA FINALIZAR O EXPEDIENTE",4,0.260,0.905,0.5,255,255,255,200)
			if IsControlJustPressed(0,168) then
				emServico = false
				RemoveBlip(blip)
				DeleteEntity(vehicle)
			end

		end
		Citizen.Wait(sleep)
	end
end)




function CriandoBlip(coordParadas,destino)
	blip = AddBlipForCoord(coordParadas[destino].x,coordParadas[destino].y,coordParadas[destino].z)
	SetBlipSprite(blip,162)
	SetBlipColour(blip,5)
	SetBlipScale(blip,0.4)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Rota da viagem")
	EndTextCommandSetBlipName(blip)
end


function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end


function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
	local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 50)
end
	