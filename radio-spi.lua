--[[
  Load a Radio Service Information (SI) files (as specified in ETSI TS 102 818)
  into VLC as a playlist

  Copyright © 2023 Nicholas Humfrey

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
--]]


-- Probe function.
function probe()
    head = vlc.peek(512)
    return string.match(vlc.path, '/SI.xml$') or
           string.match(head, 'www.worlddab.org/schemas/spi')
end

-- FIXME: there must be a better way of doing this?
function playlist_stream()
    local str = ''
    while true do
        local line = vlc.readline()
        if line == nil then
            break
        end
        str = str .. line
    end

    return vlc.memory_stream(str)
end

function read_attributes(reader)
    local a = {}
    local attr, value = reader:next_attr()
    while attr ~= nil do
        a[attr] = value
        attr, value = reader:next_attr()
    end
    return a
end

mime_map = {
    ['audio/mpeg'] = 'ICY MPA',
    ['audio/aacp'] = 'ICY AAC',
    ['audio/aac'] = 'ICY AAC',
    ['audio/x-scpls'] = 'PLS',
    ['application/vnd.apple.mpegurl'] = 'HLS',
    ['audio/mpegurl'] = 'HLS',
    ['application/dash+xml'] = 'DASH'
}

function bearer_label(proto, attr)
    local str = string.upper(proto)

    if attr.mimeValue then
        name = mime_map[attr.mimeValue]
        if name then
            str = str .. ' '.. name
        end
    end

    if attr.bitrate then
        str = str .. ' ' .. tostring(attr.bitrate) .. 'kbps'
    end

    return str
end


-- Parse function.
function parse()
    local xml = vlc.xml()

    local playlist = {}
    local stream = playlist_stream()
    local reader = xml:create_reader(stream)

    local service = {}
    local provider_name = nil

    local path = nil
    local parents = {}
    local nodetype, nodename = reader:next_node()
    while nodetype > 0 do
        empty = reader:node_empty()

        if nodetype == 1 then
            -- XML Element Start
            table.insert(parents, nodename)
            path = table.concat(parents, '/')
            attr = read_attributes(reader)

            -- FIXME: choose the best size logo
            if path == 'serviceInformation/services/service/mediaDescription/multimedia' and
               attr.width == '600' and attr.height == '600'
            then
                service.logo = attr.url
            end

            if nodename == 'bearer' then
                url = vlc.strings.url_parse(attr.id)
                if url.protocol == 'http' or url.protocol == 'https' then
                    local item = {}
                    item.path = attr.id
                    item.name = service.name .. ' [' .. bearer_label(url.protocol, attr) .. ']'
                    item.description = service.description
                    item.publisher = provider_name
                    item.arturl = service.logo
                    table.insert(playlist, item)
                end
            end
        end

        if nodetype == 2 or empty == 1 then
            -- XML Element End
            if nodename == 'service' then
                service = {}
            end
            table.remove(parents)
 
        elseif nodetype == 3 then
            -- Text Node
            if path == 'serviceInformation/services/service/shortName' or
               path == 'serviceInformation/services/service/mediumName' or
               path == 'serviceInformation/services/service/longName'
            then
                service.name = nodename
            end

            if path == 'serviceInformation/services/serviceProvider/shortName' or
               path == 'serviceInformation/services/serviceProvider/mediumName' or
               path == 'serviceInformation/services/serviceProvider/longName'
            then
                provider_name = nodename
            end

            if path == 'serviceInformation/services/service/mediaDescription/shortDescription' or
               path == 'serviceInformation/services/service/mediaDescription/longDescription'
            then
                service.description = nodename
            end
        end

        path = table.concat(parents, '/')
        nodetype, nodename = reader:next_node()
    end

    return playlist
end
