local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
enCS = {}
Tunnel.bindInterface("encanador",enCS)


-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
local webHook_encanadorPag = "https://discord.com/api/webhooks/1081309810030542938/vJeaWo0whD1LspopIr7ArxLkGtviJxRIDIB-9Fn77VJB7ALVDjhlt_ED2C_1DpMqddYV"

function SendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO CHECAGEM ITEM / PAGAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
function enCS.CheckItem()
    local user_id = vRP.getUserId(source)
    if vRP.getInventoryItemAmount(user_id,"wbody|WEAPON_WRENCH") >= 1 then
        return true
    end
end

function enCS.CheckPayment()
    local source = source
    local user_id = vRP.getUserId(source)
    local valor = parseInt(math.random(350 *2, 500 *2))
    local identity = vRP.getUserIdentity(user_id)
    if user_id then
        vRP.giveBankMoney(user_id,valor)
        TriggerClientEvent("Notify",source,"sucesso","Você recebeu R$"..valor.." reais.", 5000)
        SendWebhookMessage(webHook_encanadorPag,"```prolog\n[ID]: "..user_id.."\n[NOME]: "..identity.name.." "..identity.firstname.." \n[RECEBEU]: "..valor.." reais."..os.date("\n[Data]: %d/%m/%Y [Hora]: %H:%M:%S").." \r```")
    end
end