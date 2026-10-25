-- minimal pico-8 emulation for smoke tests + screenshots
local cart=arg[1]
local mode=arg[2] or "smoke"
local src=io.open(cart):read("a")
local lua_code=src:match("__lua__\n(.-)\n__gfx__")
local gfxs=src:match("__gfx__\n(.-)\n__sfx__")
local gfx={}
local row=0
for l in gfxs:gmatch("[^\n]+") do
 for x=0,127 do gfx[row*128+x]=tonumber(l:sub(x+1,x+1),16) end
 row=row+1
end
local function sget(x,y) return gfx[y*128+x] or 0 end

local fb={} for i=0,128*128-1 do fb[i]=0 end
local camx,camy=0,0
local clx0,cly0,clx1,cly1=0,0,127,127
local dpal={} for i=0,15 do dpal[i]=i end
local function px(x,y,c)
 x=math.floor(x-camx) y=math.floor(y-camy)
 if x<clx0 or x>clx1 or y<cly0 or y>cly1 then return end
 fb[y*128+x]=dpal[math.floor(c)%16]
end
local mapd={}
local calls={sfx={}}

flr=math.floor
function ceil(x) return math.ceil(x) end
function rnd(x) if type(x)=="table" then return x[math.random(#x)] end return math.random()*(x or 1) end
abs=math.abs min=math.min max=math.max sqrt=math.sqrt
function sin(x) return -math.sin(x*2*math.pi) end
function cos(x) return math.cos(x*2*math.pi) end
function add(t,v) t[#t+1]=v return v end
function del(t,v) for i=1,#t do if t[i]==v then table.remove(t,i) return v end end end
function all(t) local c={} for i=1,#t do c[i]=t[i] end local i=0 return function() i=i+1 return c[i] end end
function tostr(n) if math.type(n)=="float" and n==math.floor(n) then return string.format("%d",n) end return tostring(n) end
chr=string.char
local store={}
function cartdata() end
function dget(i) return store[i] or 0 end
function dset(i,v) store[i]=v end
function sfx(n) calls.sfx[n]=(calls.sfx[n] or 0)+1 end
function camera(x,y) camx,camy=x or 0,y or 0 end
function clip(x,y,w,h) if x then clx0,cly0,clx1,cly1=x,y,x+w-1,y+h-1 else clx0,cly0,clx1,cly1=0,0,127,127 end end
function pal(a,b) if a then dpal[a]=b else for i=0,15 do dpal[i]=i end end end
function cls(c) for i=0,128*128-1 do fb[i]=c or 0 end end
function pset(x,y,c) px(x,y,c) end
function rectfill(x0,y0,x1,y1,c) for y=math.floor(math.min(y0,y1)),math.floor(math.max(y0,y1)) do for x=math.floor(math.min(x0,x1)),math.floor(math.max(x0,x1)) do px(x,y,c) end end end
function rect(x0,y0,x1,y1,c) for x=x0,x1 do px(x,y0,c) px(x,y1,c) end for y=y0,y1 do px(x0,y,c) px(x1,y,c) end end
function circfill(cx,cy,r,c) cx,cy=math.floor(cx),math.floor(cy) r=math.floor(r) for y=-r,r do for x=-r,r do if x*x+y*y<=r*r+r*0.8 then px(cx+x,cy+y,c) end end end end
function circ(cx,cy,r,c) cx,cy=math.floor(cx),math.floor(cy) r=math.floor(r) for a=0,63 do px(cx+math.floor(math.cos(a/64*6.283)*r+.5),cy+math.floor(math.sin(a/64*6.283)*r+.5),c) end end
function ovalfill(x0,y0,x1,y1,c) local cx,cy,rx,ry=(x0+x1)/2,(y0+y1)/2,(x1-x0)/2,(y1-y0)/2 for y=y0,y1 do for x=x0,x1 do local dx,dy=(x-cx)/(rx+.5),(y-cy)/(ry+.5) if dx*dx+dy*dy<=1 then px(x,y,c) end end end end
function line(x0,y0,x1,y1,c) local n=math.max(math.abs(x1-x0),math.abs(y1-y0)) if n==0 then px(x0,y0,c) return end for i=0,n do px(x0+(x1-x0)*i/n+.5,y0+(y1-y0)*i/n+.5,c) end end
function sspr(sx,sy,sw,sh,dx,dy,dw,dh,fx)
 dw=dw or sw dh=dh or sh
 for y=0,math.floor(dh)-1 do for x=0,math.floor(dw)-1 do
  local u=math.floor(x*sw/dw) if fx then u=sw-1-u end
  local c=sget(sx+u,sy+math.floor(y*sh/dh))
  if c~=0 then px(dx+x,dy+y,c) end
 end end
end
function spr(n,x,y,w,h,fx) sspr((n%16)*8,math.floor(n/16)*8,8,8,x,y,8,8,fx) end
function mset(x,y,v) mapd[y*128+x]=v end
function mget(x,y) return mapd[y*128+x] or 0 end
function map(cx,cy,sx,sy,w,h) for y=0,h-1 do for x=0,w-1 do local v=mget(cx+x,cy+y) if v~=0 then spr(v,sx+x*8,sy+y*8) end end end end
function print(s,x,y,c)
 s=tostring(s):gsub("\6w\6t","")
 local big=tostring(s)~=s
 -- crude glyph blocks so layout is visible
 for i=1,#s do local ch=s:sub(i,i) if ch~=" " then for yy=0,4 do for xx=0,2 do if (xx+yy+i)%3~=0 then px(x+(i-1)*4+xx,y+yy,c) end end end end end
end
local btns={} local pbtns={}
function btn(i) return btns[i] or false end
function btnp(i) return (btns[i] and not pbtns[i]) or false end

local env=load(lua_code,"cart","t",_ENV)
env()
_init()

local function dump(name)
 local P={"000000","1d2b53","7e2553","008751","ab5236","5f574f","c2c3c7","fff1e8","ff004d","ffa300","ffec27","00e436","29adff","83769c","ff77a8","ffccaa"}
 local f=io.open(name,"wb") f:write("P6\n128 128\n255\n")
 for i=0,128*128-1 do local h=P[fb[i]+1] f:write(string.char(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16))) end
 f:close()
end

local function frame()
 _update60()
 if mode~="smoke" or math.random()<.002 then _draw() end
 for i=0,5 do pbtns[i]=btns[i] end
end

if mode=="shots" then
 for f=1,700 do
  frame()
  if f==60 or f==150 or f==210 or f==290 or f==420 then dump("intro_"..f..".ppm") end
 end
 btns[5]=true frame() btns[5]=false
 for f=1,200 do btns[1]=(f%60<30) frame() if f==200 then dump("game_start.ppm") end end
 -- play a bit with random input, cheat invuln
 for f=1,600 do
  for i=0,3 do btns[i]=math.random()<0.25 end btns[4]=math.random()<.2
  if p then p.inv=10 end
  frame()
 end
 dump("game_mid.ppm")
 return
end

-- smoke: many runs of random play with occasional cheats
math.randomseed(tonumber(arg[3] or 1))
local maxlvl,states,frames=0,{},0
for run=1,4 do
 _init()
 for f=1,15000 do
  local held=math.random()
  for i=0,3 do if math.random()<0.08 then btns[i]=not btns[i] end end
  btns[4]=math.random()<0.15 btns[5]=math.random()<0.02
  if run>=3 and p and st=="play" then p.inv=5 end
  frame()
  frames=frames+1 if frames%5000==0 then io.write(frames," ",st," lvl",tostring(lvl),"\n") io.flush() end
  states[st]=true
  if lvl and lvl>maxlvl then maxlvl=lvl end
  -- sanity checks
  if st=="play" then
   assert(p.x%1==0 and p.y%1==0,"player off-grid")
   assert(not solid(flr(p.x/8),flr(p.y/8)) and not solid(flr((p.x+7)/8),flr((p.y+7)/8)),"player in wall "..p.x..","..p.y)
   for e in all(en) do
    assert(not solid(flr(e.x/8),flr(e.y/8)) and not solid(flr((e.x+7)/8),flr((e.y+7)/8)),"enemy in wall")
   end
  end
 end
end
local s="" for k in pairs(states) do s=s..k.." " end
local sf="" for k,v in pairs(calls.sfx) do sf=sf..k..":"..v.." " end
io.write("ok frames=",frames," maxlvl=",maxlvl," states=",s,"\nsfx ",sf,"\n")
