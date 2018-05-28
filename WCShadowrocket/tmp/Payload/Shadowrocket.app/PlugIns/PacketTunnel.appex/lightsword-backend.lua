-- file: lua/lightsword-backend.lua

local http = require 'http'
local crypto = require 'crypto'
local network = require 'network'
local backend = require 'backend'

local char = string.char
local byte = string.byte
local find = string.find
local sub = string.sub
local rep = string.rep
local format = string.format
local print = print
local type = type
local pairs = pairs
local tostring = tostring

local ADDRESS = backend.ADDRESS
local PROXY = backend.PROXY
local SUPPORT = backend.SUPPORT
local ERROR = backend.RESULT.ERROR
local SUCCESS = backend.RESULT.SUCCESS
local IGNORE = backend.RESULT.IGNORE

local ctx_uuid = backend.get_uuid
local ctx_proxy_type = backend.get_proxy_type
local ctx_address_type = backend.get_address_type
local ctx_address_host = backend.get_address_host
local ctx_address_bytes = backend.get_address_bytes
local ctx_address_port = backend.get_address_port
local ctx_write = backend.write
local ctx_free = backend.free
local htons = network.htons

local SOCKS_STAGE_NONE = 0
local SOCKS_STAGE_HANDSHAKE = 1
local SOCKS_STAGE_AUTH = 2
local SOCKS_STAGE_CONNECT = 3
local SOCKS_STAGE_DONE = 4
local SOCKS_STAGE_ERROR = 5

local supported_ciphers = {
    ['aes-128-cfb'] = {key=16, iv=16},
    ['aes-128-ofb'] = {key=16, iv=16},
    ['aes-192-cfb'] = {key=24, iv=16},
    ['aes-192-ofb'] = {key=24, iv=16},
    ['aes-256-cfb'] = {key=32, iv=16},
    ['aes-256-ofb'] = {key=32, iv=16},
    ['bf-cfb'] = {key=16, iv=8},
    ['camellia-128-cfb'] = {key=16, iv=16},
    ['camellia-192-cfb'] = {key=24, iv=16},
    ['camellia-256-cfb'] = {key=32, iv=16},
    ['cast5-cfb'] = {key=16, iv=8},
    ['des-cfb'] = {key=8, iv=8},
    ['idea-cfb'] = {key=16, iv=8},
    ['rc2-cfb'] = {key=16, iv=8},
    ['rc4'] = {key=16, iv=0},
    ['rc4-md5'] = {key=16, iv=16},
    ['seed-cfb'] = {key=16, iv=16},
}

local algorithm = settings.method
local password = settings.password
local key_len = supported_ciphers[algorithm].key
local iv_len = supported_ciphers[algorithm].iv
local key = password

if #password > key_len then
    key = string.sub(password, key_len)
elseif #password < key_len then
    local len = math.floor(key_len / #password) + 1
    key = string.sub(string.rep(password, len), 0, key_len)
end

local encrypts = {}
local decrypts = {}
local buffers = {}
local flags = {}
local rand = crypto.rand

local function tprint (tbl, indent)
    if not indent then
        indent = 0
    end
    for k, v in pairs(tbl) do
        formatting = rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent + 4)
        else
            print(formatting .. tostring(v))
        end
    end
end

function tohex(s)
    return (s:gsub('.', function (c) return format("%02x,", byte(c)) end))
end

local function wa_lua_handshake(ctx)
    local uuid = ctx_uuid(ctx)
    local proxy_type = ctx_proxy_type(ctx)

    local iv = rand.bytes(iv_len)
    encrypt_ctx = crypto.encrypt.new(algorithm, key, iv)
    encrypts[uuid] = encrypt_ctx

    local atyp = ctx_address_type(ctx)
    local port = htons(ctx_address_port(ctx))
    local data = char(5, 0, 5, 1, 0, atyp)
    local encrypt = crypto.encrypt.new(algorithm, key, iv)
    local p1

    if atyp == ADDRESS.DOMAIN then
        local host = ctx_address_host(ctx)
        p1 = encrypt:update(data .. char(#host) .. host .. port)
    else
        local addr = ctx_address_bytes(ctx)
        p1 = encrypt:update(data .. addr .. port)
    end

    local p2 = encrypt:final()
    local res = iv .. p1 .. p2

    return SUCCESS, res
end

function wa_lua_support_flags(settings)
    return 4
end

function wa_lua_on_connect_cb(ctx, buf)
    local uuid = ctx_uuid(ctx)
    local proxy_type = ctx_proxy_type(ctx)

    if proxy_type == PROXY.HTTP_TUNNEL then
        flags[uuid] = SOCKS_STAGE_NONE
        return SUCCESS, buf
    else
        buffers[uuid] = buf
        flags[uuid] = SOCKS_STAGE_CONNECT
        return wa_lua_handshake(ctx)
    end
end

function wa_lua_on_read_cb(ctx, buf)
    local uuid = ctx_uuid(ctx)
    local encrypt_ctx = encrypts[uuid]
    local decrypt_ctx = decrypts[uuid]
    local res = ""

    if not decrypt_ctx then
        local riv = sub(buf, 0, iv_len)
        local text = sub(buf, iv_len + 1)
        decrypt_ctx = crypto.decrypt.new(algorithm, key, riv)
        decrypts[uuid] = decrypt_ctx
    else
        res = decrypt_ctx:update(buf)
    end

    if buffers[uuid] and flags[uuid] == SOCKS_STAGE_CONNECT then
        local data = buffers[uuid]
        local encryptd = encrypt_ctx:update(data)
        flags[uuid] = SOCKS_STAGE_DONE
        ctx_write(ctx, encryptd, function (ctx)
            buffers[uuid] = nil
        end)
        return IGNORE, res
    end

    return SUCCESS, res
end

function wa_lua_on_write_cb(ctx, buf)
    local uuid = ctx_uuid(ctx)

    if flags[uuid] == SOCKS_STAGE_NONE then
        buffers[uuid] = buf
        flags[uuid] = SOCKS_STAGE_CONNECT
        return wa_lua_handshake(ctx)
    else
        local encrypt_ctx = encrypts[uuid]
        return SUCCESS, encrypt_ctx:update(buf)
    end

end

function wa_lua_on_close_cb(ctx)
    local uuid = ctx_uuid(ctx)
    encrypts[uuid] = nil
    decrypts[uuid] = nil
    buffers[uuid] = nil
    flags[uuid] = nil
    ctx_free(ctx)
    return SUCCESS
end

