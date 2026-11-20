--!native
--!optimize 2
-- StreamBuffer: a growable, little-endian write buffer on top of Luau's `buffer`.
--
-- Public fields (read by callers):
--   .buf : the underlying buffer (may be larger than .len; only [0, len) is valid)
--   .len : number of bytes written so far
--
-- Offsets passed to *At / allocRegion results are 0-based byte offsets.

local StreamBuffer = {}
StreamBuffer.__index = StreamBuffer

export type StreamBuffer = typeof(setmetatable(
	{} :: {
		buf: buffer,
		len: number,
		cap: number,
	},
	StreamBuffer
))

function StreamBuffer.new(capacity: number?): StreamBuffer
	local cap = math.max(math.floor(capacity or 64), 16)
	return setmetatable({
		buf = buffer.create(cap),
		len = 0,
		cap = cap,
	}, StreamBuffer)
end

-- Make sure `extra` more bytes can be written without overflowing.
function StreamBuffer.ensure(self: StreamBuffer, extra: number)
	local need = self.len + extra
	if need <= self.cap then
		return
	end
	local newCap = self.cap
	while newCap < need do
		newCap *= 2
	end
	local newBuf = buffer.create(newCap)
	buffer.copy(newBuf, 0, self.buf, 0, self.len)
	self.buf = newBuf
	self.cap = newCap
end

-- Reserve `bytes` zero-filled bytes at the current end and return the offset
-- of the region's start. Fill it later with the *At writers or buffer.write*.
-- (Memory past `len` is never written, so it is always zero.)
function StreamBuffer.allocRegion(self: StreamBuffer, bytes: number): number
	self:ensure(bytes)
	local base = self.len
	self.len = base + bytes
	return base
end

function StreamBuffer.fill(self: StreamBuffer, value: number, count: number)
	if count <= 0 then
		return
	end
	self:ensure(count)
	buffer.fill(self.buf, self.len, value, count)
	self.len += count
end

-- Raw bytes, no length prefix.
function StreamBuffer.writestring(self: StreamBuffer, s: string)
	local n = #s
	if n == 0 then
		return
	end
	self:ensure(n)
	buffer.writestring(self.buf, self.len, s)
	self.len += n
end

-- u32 little-endian length followed by the bytes (Roblox binary "String" type).
function StreamBuffer.writeLenString(self: StreamBuffer, s: string?)
	local str = s or ""
	local n = #str
	self:ensure(4 + n)
	buffer.writeu32(self.buf, self.len, n)
	self.len += 4
	if n > 0 then
		buffer.writestring(self.buf, self.len, str)
		self.len += n
	end
end

function StreamBuffer.writeu8(self: StreamBuffer, v: number)
	self:ensure(1)
	buffer.writeu8(self.buf, self.len, v)
	self.len += 1
end

function StreamBuffer.writei8(self: StreamBuffer, v: number)
	self:ensure(1)
	buffer.writei8(self.buf, self.len, v)
	self.len += 1
end

function StreamBuffer.writeu16(self: StreamBuffer, v: number)
	self:ensure(2)
	buffer.writeu16(self.buf, self.len, v)
	self.len += 2
end

function StreamBuffer.writei16(self: StreamBuffer, v: number)
	self:ensure(2)
	buffer.writei16(self.buf, self.len, v)
	self.len += 2
end

function StreamBuffer.writeu32(self: StreamBuffer, v: number)
	self:ensure(4)
	buffer.writeu32(self.buf, self.len, v)
	self.len += 4
end

function StreamBuffer.writei32(self: StreamBuffer, v: number)
	self:ensure(4)
	buffer.writei32(self.buf, self.len, v)
	self.len += 4
end

function StreamBuffer.writef32(self: StreamBuffer, v: number)
	self:ensure(4)
	buffer.writef32(self.buf, self.len, v)
	self.len += 4
end

function StreamBuffer.writef64(self: StreamBuffer, v: number)
	self:ensure(8)
	buffer.writef64(self.buf, self.len, v)
	self.len += 8
end

-- Positional writers for filling regions returned by allocRegion.
-- They never change `len`.
function StreamBuffer.writeu8At(self: StreamBuffer, offset: number, v: number)
	buffer.writeu8(self.buf, offset, v)
end

function StreamBuffer.writeu32At(self: StreamBuffer, offset: number, v: number)
	buffer.writeu32(self.buf, offset, v)
end

function StreamBuffer.writei32At(self: StreamBuffer, offset: number, v: number)
	buffer.writei32(self.buf, offset, v)
end

function StreamBuffer.writef32At(self: StreamBuffer, offset: number, v: number)
	buffer.writef32(self.buf, offset, v)
end

-- Append another buffer's bytes [srcOffset, srcOffset + count).
function StreamBuffer.writebuffer(self: StreamBuffer, src: buffer, srcOffset: number?, count: number?)
	local off = srcOffset or 0
	local n = count or (buffer.len(src) - off)
	if n <= 0 then
		return
	end
	self:ensure(n)
	buffer.copy(self.buf, self.len, src, off, n)
	self.len += n
end

-- Exact-size copy of the written bytes.
function StreamBuffer.tobuffer(self: StreamBuffer): buffer
	local out = buffer.create(self.len)
	buffer.copy(out, 0, self.buf, 0, self.len)
	return out
end

function StreamBuffer.tostring(self: StreamBuffer): string
	return buffer.readstring(self.buf, 0, self.len)
end

return StreamBuffer
