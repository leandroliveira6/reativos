print("r")

-- Variaveis globais da aplicacao
local wifi_usuario = ""
local wifi_senha = ""
local estado_led1 = gpio.LOW
local estado_led2 = gpio.LOW
local led1 = 3
local led2 = 4
local servidor = nil

-- Funcoes gerais do projeto
---- Funcao responsavel por criar callbacks genericas para uso comum
---- Pode receber um callback custom, caso desejar
local callback_simples = function(mensagem, custom_function)
    return function(response)
        print(mensagem)
        if custom_function == nil then
            if type(response) == "table" then
                for key, value in pairs(response) do
                    print(key .. ', ' .. value)
                end
            end
        else
            custom_function(response)
        end
    end
end


-- Funcoes responsaveis pelas conexoes wifi
---- Funcao responsavel por configurar o wifi com o login e senha passados nas variaveis globais
local configurar_wifi = function()
    local config = {
        ssid = wifi_usuario,
        pwd = wifi_senha,
        save = true,
        got_ip_cb = callback_simples("Configuracao bem sucedida! Maiores informacoes abaixo:")
    }
    wifi.setmode(wifi.STATION)
    wifi.sta.config(config)
    wifi.sta.autoconnect(1)
end

---- Funcao responsavel por conectar no wifi configurado
local conectar_wifi = function()
    wifi.sta.connect(callback_simples("Conexao bem sucedida! Maiores informacoes abaixo:"))
end

---- Funcao responsavel por desconectar do wifi conectado
local desconectar_wifi = function()
    wifi.sta.disconnect(callback_simples("Desconexao bem sucedida! Maiores informacoes abaixo:"))
end


-- Funcoes responsaveis por configurar um webserver e executar comandos
---- Funcao de criacao da pagina html do webserver
local configurar_pagina = function()
    local pagina = "<h1>NODE Web Server</h1>"
    local comando = ""
    if (estado_led1 == gpio.LOW) then
        comando = "Ligar"
    else
        comando = "Desligar"
    end
    pagina = pagina.."<p>LED1 <a href=\"?pin=toggle_led1\"><button>" .. comando .. "</button></a></p>"
    if (estado_led2 == gpio.LOW) then
        comando = "Ligar"
    else
        comando = "Desligar"
    end
    pagina = pagina.."<p>LED2 <a href=\"?pin=toggle_led2\"><button>" .. comando .. "</button></a></p>"
    return pagina
end

---- Funcao de troca de estado para LEDs
---- Retorna o estado atribuido ao LED especificado
local toggle_led = function(estado, led)
    local novo_estado = nil
    if (estado == gpio.LOW) then
        novo_estado = gpio.HIGH
    else
        novo_estado = gpio.LOW
    end
    gpio.write(led, novo_estado)
    return novo_estado
end

---- Funcao de criacao e configuracao da pagina do webserver
local criar_webserver = function()
    local listen_callback = function(conn)
        local receive_callback = function(client, request)
            local pagina = ""
            local get = {}
            local _, _, metodo, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
            if (metodo == nil) then
                _, _, metodo, path = string.find(request, "([A-Z]+) (.+) HTTP")
            end
            if (vars ~= nil) then
                for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                    get[k] = v
                end
            end
            if (get.pin == "toggle_led1") then
                estado_led1 = toggle_led(estado_led1, led1)
                print("a")
            elseif (get.pin == "toggle_led2") then
                estado_led2 = toggle_led(estado_led2, led2)
                print("b")
            end
            client:send(configurar_pagina())
            client:close()
            collectgarbage()
        end
        conn:on("receive", receive_callback)
    end
    servidor=net.createServer(net.TCP)
    servidor:listen(80, listen_callback)
end

local setup = function()
    gpio.mode(led1, gpio.OUTPUT)
    gpio.mode(led2, gpio.OUTPUT)
    configurar_wifi()
    criar_webserver()
    print("i")
end

setup()