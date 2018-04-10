-- file: lua/backend-http.lua

local http = require 'http'
local backend = require 'backend'

local char = string.char
local byte = string.byte
local find = string.find
local sub = string.sub

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
local is_http_request = http.is_http_request

local buffers = {}
local flags = {}

function wa_lua_support_flags(settings)
    return 14
end

function wa_lua_socks_to_http(ctx, buf)
    local host = ctx_address_host(ctx)
    local port = ctx_address_port(ctx)
    local uuid = ctx_uuid(ctx)

    if is_http_request(buf) == 1 then
        flags[uuid] = 1
        local index = find(buf, '/')
        local method = sub(buf, 0, index - 1)
        local res = method .. 'http://' .. host .. ':' .. port .. sub(buf, index)
        return res
    else
        local uuid = ctx_uuid(ctx)
        buffers[uuid] = buf
        flags[uuid] = 0
        local res = 'CONNECT ' .. host .. ':' .. port ..
                    ' HTTP/1.1\r\nHost: ' .. host ..
                    '\r\nProxy-Connection: Keep-Alive\r\n\r\n'
        return res
    end
end

function wa_lua_on_connect_cb(ctx, buf)
    local uuid = ctx_uuid(ctx)
    if ctx_proxy_type(ctx) == PROXY.SOCKS_TUNNEL then
        return SUCCESS, wa_lua_socks_to_http(ctx, buf)
    else
        flags[uuid] = 1
        return SUCCESS, buf
    end
end

function wa_lua_on_read_cb(ctx, buf)
    local uuid = ctx_uuid(ctx)
    if flags[uuid] == 0 then
        local uuid = ctx_uuid(ctx)
        local data = buffers[uuid]

        flags[uuid] = 1
        ctx_write(ctx, data, function (ctx)
            buffers[uuid] = nil
        end)

        return IGNORE, nil
    end
    return SUCCESS, buf
end

function wa_lua_on_write_cb(ctx, buf)
    return SUCCESS, buf
end

function wa_lua_on_close_cb(ctx)
    local uuid = ctx_uuid(ctx)
    buffers[uuid] = nil
    flags[uuid] = nil
    ctx_free(ctx)
    return SUCCESS
end

