-- wizards of snort
-- a nasal maze shooter
-- arrows: move  x/z: saline spray

ox,oy=4,16
tun=5
dxs={-1,1,0,0}
dys={0,0,-1,1}
rev={1,0,3,2}
-- dust bunny, pollen puff, dust mite, booger king
kt={
 {s=3,sc=10,spd=.45,ch=.25,c=6,c2=5},
 {s=5,sc=20,spd=.6,ch=.4,c=10,c2=9},
 {s=7,sc=50,spd=.8,ch=.55,c=8,c2=2,inv=true},
 {s=9,sc=250,spd=1.1,ch=.2,c=11,c2=3}
}
lvn={"left nostril","right nostril","nasal cavity","the sinuses","deep sinus","near the brain"}
big=chr(6).."w"..chr(6).."t"
-- straw: bottom end, top end (nostril)
s0x,s0y,s1x,s1y=34,112,76,72

function _init()
 cartdata("wizards_of_snort_1")
 hi=dget(0)
 gt=0 shk=0 parts={} pops={}
 st="intro" it=0
end

function pick(t) return t[flr(rnd(#t))+1] end

function pad(n,l)
 local s=tostr(n)
 while #s<l do s="0"..s end
 return s
end

function cprint(s,y,c,b)
 local x=64-#s*2
 for i=-1,1 do for j=-1,1 do print(s,x+i,y+j,b or 0) end end
 print(s,x,y,c)
end

function bcprint(s,y,c,b)
 local x=64-#s*4
 print(big..s,x+1,y+1,b)
 print(big..s,x,y,c)
end

function puff(x,y,c,n)
 for i=1,n do
  local a,v=rnd(),.4+rnd(1.6)
  add(parts,{x=x,y=y,dx=cos(a)*v,dy=sin(a)*v,c=c,l=15+rnd(20)})
 end
end

function upd_parts()
 for q in all(parts) do
  q.x=q.x+q.dx q.y=q.y+q.dy
  q.dx=q.dx*.92 q.dy=q.dy*.92
  q.l=q.l-1
  if q.l<=0 then del(parts,q) end
 end
 for q in all(pops) do
  q.y=q.y-.3 q.l=q.l-1
  if q.l<=0 then del(pops,q) end
 end
end

function _update60()
 gt=gt+1
 if shk>0 then shk=shk-1 end
 upd_parts()
 if st=="intro" then upd_intro()
 elseif st=="play" then upd_play()
 elseif st=="clear" then upd_clear()
 else upd_over() end
end

function _draw()
 if shk>0 then camera(rnd(4)-2,rnd(4)-2) else camera() end
 if st=="intro" then draw_intro() else draw_game() end
 camera()
end

-->8
-- intro: up the straw we go

function upd_intro()
 it=it+1
 if it==170 then sfx(3) end
 if it==262 then sfx(4) shk=24 end
 if it>=262 and it<300 and it%5==0 then
  puff(77,74,pick({6,5,15}),5)
 end
 if btnp(4) or btnp(5) then
  if it<340 then it=340 shk=0 parts={}
  elseif it>350 then start_game() end
 end
end

function dman(x,y,sz,fl,fr)
 sspr(fr*8,0,8,8,x,y,sz,sz,fl)
end

function draw_nose(wx,wy)
 -- head, lip area, chin, neck
 circfill(152,44+wy,64,15)
 circfill(100+wx,80+wy,12,15)
 circfill(112,100,14,15)
 rectfill(116,104,127,117,15)
 -- cheek blush
 circfill(120,66,7,14)
 -- nose bridge
 for i=0,10 do
  local f=i/10
  circfill(104-f*24+wx,4+f*58+wy,3+f*11,15)
 end
 -- bulb
 circfill(80+wx,62+wy,14,15)
 circfill(82+wx,62+wy,7,14)
 circfill(80+wx,60+wy,7,15)
 circfill(76+wx,55+wy,2,7)
 -- nostril
 ovalfill(68+wx,69+wy,84+wx,78+wy,4)
 ovalfill(70+wx,71+wy,82+wx,77+wy,0)
 -- nostril hairs
 for i=0,4 do
  line(70+i*3+wx,77+wy,69+i*3+wx,80+wy,4)
 end
 -- blissful closed eye + brow
 line(108,18,124,15,4)
 line(110,28,121,28,0)
 line(110,28,108,26,0)
 for i=0,3 do pset(111+i*3,29,0) end
 -- lips
 ovalfill(98,92,112,98,8)
 line(99,95,111,95,2)
end

function draw_straw(wx,wy)
 local x1,y1=s1x+wx,s1y+wy
 local dx,dy=x1-s0x,y1-s0y
 local l=sqrt(dx*dx+dy*dy)
 local sc=0
 if it>170 and it<262 then sc=it*.8 end
 for i=0,l do
  local f=i/l
  local c=8
  if flr((i+sc)/4)%2==0 then c=7 end
  circfill(s0x+dx*f,s0y+dy*f,1,c)
 end
end

function draw_intro()
 cls(1)
 -- wallpaper
 for x=0,127,12 do line(x,0,x,117,0) end
 rectfill(0,118,127,127,4)
 line(0,118,127,118,9)
 local wx,wy=0,0
 if it>=262 and it<330 then
  wx=sin(it/6)*2 wy=cos(it/9)
 end
 draw_nose(wx,wy)
 draw_straw(wx,wy)
 -- the tiny man
 if it<120 then
  dman(-8+it*.3,110,8,false,it%16<8 and 1 or 2)
 elseif it<170 then
  dman(28,110,8,false,1)
  if it>135 then print("?",30,102,7) end
 elseif it<262 then
  local f=(it-170)/92
  local e=f*f
  local sz=8-6*e
  local cx=32+(s1x-32)*e
  local cy=114+(s1y-114)*e
  dman(cx-sz/2,cy-sz/2,sz,gt%8<4,1)
  if it>200 then
   print("help!",cx-24,cy-10,7)
  end
 end
 for q in all(parts) do circfill(q.x,q.y,q.l>15 and 1 or 0,q.c) end
 -- captions
 if it<170 then
  cprint("one day, a tiny explorer",3,7,0)
  cprint("found a very long straw...",11,7,0)
 elseif it<262 then
  cprint("ssshhluuuuurp!",6,12,1)
 elseif it<340 then
  cprint("*snnnorrrrrt*",6,9,4)
 else
  draw_title()
 end
end

function draw_title()
 rectfill(0,0,127,31,0)
 line(0,31,127,31,14)
 bcprint("wizards",3,11,3)
 bcprint("of snort",17,10,4)
 -- monster roster
 rectfill(2,36,46,88,0)
 rect(2,36,46,88,13)
 print("dust foes",7,39,7)
 for i=1,4 do
  local k=kt[i]
  local y=36+i*11
  spr(k.s+flr(gt/12)%2,6,y)
  print(i<4 and tostr(k.sc*10) or "???",18,y+2,k.c)
 end
 if gt%40<26 then cprint("press x to start",104,7,0) end
 cprint("hi "..pad(hi,5).."0",121,6,0)
end

-->8
-- maze of nose hairs

function gen_maze()
 wl={}
 for x=0,14 do
  wl[x]={}
  for y=0,12 do wl[x][y]=true end
 end
 -- carve left half (cells at odd coords)
 local vis={}
 local stk={{1,11}}
 wl[1][11]=false vis[1+11*16]=true
 while #stk>0 do
  local c=stk[#stk]
  local opts={}
  for d=1,4 do
   local nx,ny=c[1]+dxs[d]*2,c[2]+dys[d]*2
   if nx>=1 and nx<=7 and ny>=1 and ny<=11 and not vis[nx+ny*16] then
    add(opts,{nx,ny,d})
   end
  end
  if #opts>0 then
   local o=pick(opts)
   wl[c[1]+dxs[o[3]]][c[2]+dys[o[3]]]=false
   wl[o[1]][o[2]]=false
   vis[o[1]+o[2]*16]=true
   add(stk,{o[1],o[2]})
  else
   stk[#stk]=nil
  end
 end
 -- open up loops
 for x=1,7 do
  for y=1,11 do
   if (x+y)%2==1 and wl[x][y] and rnd()<.22 then wl[x][y]=false end
  end
 end
 -- mirror
 for x=0,6 do
  for y=0,12 do wl[14-x][y]=wl[x][y] end
 end
 -- no dead ends
 for x=1,7,2 do
  for y=1,11,2 do
   local n,ws=0,{}
   for d=1,4 do
    local wx,wy=x+dxs[d],y+dys[d]
    if wl[wx][wy] then
     if wx>0 and wx<14 and wy>0 and wy<12 then add(ws,{wx,wy}) end
    else n=n+1 end
   end
   if n<=1 and #ws>0 then
    local w=pick(ws)
    wl[w[1]][w[2]]=false
    wl[14-w[1]][w[2]]=false
   end
  end
 end
 -- side tunnel
 wl[0][tun]=false wl[14][tun]=false
 -- tiles
 specks={}
 for x=0,14 do
  for y=0,12 do
   local s=0
   if wl[x][y] then
    if x==0 or x==14 or y==0 or y==12 then s=19
    elseif x%2==0 and y%2==0 then s=18
    elseif y%2==1 then s=pick({16,20})
    else s=pick({17,21}) end
   elseif rnd()<.5 then
    add(specks,{x*8+flr(rnd(8)),y*8+flr(rnd(8)),pick({1,2,3})})
   end
   mset(x,y,s)
  end
 end
end

function solid(tx,ty)
 if ty==tun and (tx<0 or tx>14) then return false end
 if tx<0 or tx>14 or ty<0 or ty>12 then return true end
 return wl[tx][ty]
end

function aligned(e) return e.x%8==0 and e.y%8==0 end

function canmv(e,d)
 return not solid(flr(e.x/8)+dxs[d+1],flr(e.y/8)+dys[d+1])
end

function step(e)
 e.x=(e.x+dxs[e.d+1])%120
 e.y=e.y+dys[e.d+1]
end

-->8
-- game

function start_game()
 score=0 lives=2 lvl=1 nxl=1000
 start_level()
end

function start_level()
 gen_maze()
 p={x=8,y=88,d=1,an=0,fl=false,inv=0}
 en={} ebs={} pb=nil parts={} pops={}
 queue={}
 for i=1,3+lvl do add(queue,1) end
 for i=1,min(lvl-1,6) do add(queue,2) end
 for i=1,min(max(lvl-2,0),6) do add(queue,3) end
 for i=#queue,2,-1 do
  local j=flr(rnd(i))+1
  queue[i],queue[j]=queue[j],queue[i]
 end
 maxon=min(6,3+flr(lvl/2))
 ebmax=min(4,1+flr(lvl/2))
 bossin=false dying=0 sptm=0 ready=90
 msg="lv"..lvl..": "..lvn[(lvl-1)%#lvn+1] msgt=90
 st="play"
end

function spawn(t)
 local cx,cy
 for i=1,60 do
  cx=1+flr(rnd(7))*2 cy=1+flr(rnd(6))*2
  if abs(cx*8-p.x)+abs(cy*8-p.y)>=48 then break end
 end
 add(en,{x=cx*8,y=cy*8,d=flr(rnd(4)),t=t,acc=0,sp=30,an=0,cd=60,life=600})
 sfx(6)
end

function hurt()
 dying=60 pb=nil shk=10
 sfx(2)
 puff(p.x+4,p.y+4,15,12) puff(p.x+4,p.y+4,12,8)
end

function kill(e)
 local k=kt[e.t]
 score=min(score+k.sc,32000)
 add(pops,{x=e.x,y=e.y,s=tostr(k.sc*10),l=40})
 puff(e.x+4,e.y+4,k.c,10) puff(e.x+4,e.y+4,k.c2,6)
 del(en,e)
 sfx(1)
 if e.t==4 then msg="booger king blown away!" msgt=90 shk=6 end
 if score>=nxl then
  nxl=nxl+1000 lives=lives+1
  sfx(9) msg="extra life!" msgt=60
 end
end

function upd_play()
 if msgt>0 then msgt=msgt-1 end
 if ready>0 then ready=ready-1 return end
 upd_player()
 upd_pb()
 upd_enemies()
 upd_ebs()
 if dying>0 then
  dying=dying-1
  if dying==0 then
   lives=lives-1
   if lives<0 then
    st="over" ot=0 newhi=false
    if score>hi then hi=score newhi=true dset(0,hi) end
   else
    p.x,p.y,p.d,p.fl,p.inv=8,88,1,false,120
    ebs={}
   end
  end
 end
end

function upd_player()
 if dying>0 then return end
 if p.inv>0 then p.inv=p.inv-1 end
 local w=-1
 for i=0,3 do
  if btn(i) and (w<0 or i~=p.d) then w=i end
 end
 local mv=false
 if aligned(p) then
  if w>=0 and canmv(p,w) then p.d=w mv=true
  elseif w>=0 and canmv(p,p.d) then mv=true
  elseif w>=0 then p.d=w end
 else
  if w>=0 and w==rev[p.d+1] then p.d=w end
  mv=true
 end
 if mv then step(p) p.an=p.an+1 end
 if p.d<2 then p.fl=p.d==0 end
 if (btnp(4) or btnp(5)) and not pb then
  pb={x=p.x+4,y=p.y+4,d=p.d}
  sfx(0)
 end
end

function upd_pb()
 if not pb then return end
 for i=1,3 do
  pb.x=pb.x+dxs[pb.d+1] pb.y=pb.y+dys[pb.d+1]
  if pb.x<0 or pb.x>=120 or solid(flr(pb.x/8),flr(pb.y/8)) then
   puff(pb.x,pb.y,12,3) pb=nil return
  end
  for e in all(en) do
   if e.sp==0 and abs(e.x+4-pb.x)<5 and abs(e.y+4-pb.y)<5 then
    kill(e) pb=nil return
   end
  end
 end
end

function edir(e,k)
 local opts={}
 for d=0,3 do
  if d~=rev[e.d+1] and canmv(e,d) then add(opts,d) end
 end
 if #opts==0 then
  if canmv(e,rev[e.d+1]) then e.d=rev[e.d+1] end
  return
 end
 if rnd()<k.ch and dying==0 then
  local best,bd=opts[1],9999
  for d in all(opts) do
   local dd=abs(e.x+dxs[d+1]*8-p.x)+abs(e.y+dys[d+1]*8-p.y)
   if dd<bd then best,bd=d,dd end
  end
  e.d=best
 else
  e.d=pick(opts)
 end
end

function upd_enemies()
 sptm=sptm-1
 if #en<maxon and #queue>0 and sptm<=0 then
  spawn(queue[#queue]) queue[#queue]=nil sptm=45
 end
 local angry=#queue==0 and #en<=2
 for e in all(en) do
  local k=kt[e.t]
  if e.sp>0 then e.sp=e.sp-1
  else
   local v=min(k.spd*(1+(lvl-1)*.07)*(angry and 1.35 or 1),2)
   e.acc=e.acc+v
   while e.acc>=1 do
    e.acc=e.acc-1
    if aligned(e) then edir(e,k) end
    if not aligned(e) or canmv(e,e.d) then step(e) end
   end
   e.an=e.an+1
   e.cd=e.cd-1
   if e.t<4 and e.cd<=0 and #ebs<ebmax and dying==0 and rnd()<.05 then
    local d=-1
    if abs(e.y-p.y)<3 then d=p.x<e.x and 0 or 1
    elseif abs(e.x-p.x)<3 then d=p.y<e.y and 2 or 3 end
    if d>=0 then
     add(ebs,{x=e.x+4,y=e.y+4,d=d}) e.cd=90 sfx(8)
    end
   end
   if dying==0 and p.inv<=0 and abs(e.x-p.x)<6 and abs(e.y-p.y)<6 then hurt() end
   if e.t==4 then
    e.life=e.life-1
    if e.life<=0 then
     puff(e.x+4,e.y+4,11,12) del(en,e)
     msg="it escaped up the sinus!" msgt=90
    end
   end
  end
 end
 if #queue==0 and #en==0 and dying==0 then
  if not bossin then
   bossin=true spawn(4) sfx(7)
   msg="the booger king appears!" msgt=90
  else
   st="clear" ct=0 pb=nil ebs={}
  end
 end
end

function upd_ebs()
 for b in all(ebs) do
  local dead=false
  for i=1,2 do
   b.x=b.x+dxs[b.d+1] b.y=b.y+dys[b.d+1]
   if b.x<0 or b.x>=120 or solid(flr(b.x/8),flr(b.y/8)) then dead=true break end
   if dying==0 and p.inv<=0 and abs(p.x+4-b.x)<4 and abs(p.y+4-b.y)<4 then
    dead=true hurt() break
   end
  end
  if dead then del(ebs,b) end
 end
end

function upd_clear()
 ct=ct+1
 if ct==70 then
  sfx(5) shk=14
  for i=1,70 do
   add(parts,{x=rnd(40)-20,y=rnd(104),dx=2+rnd(3),dy=rnd(1)-.5,c=pick({6,7,15,5}),l=40+rnd(40)})
  end
 end
 if ct>=180 then lvl=lvl+1 start_level() end
end

function upd_over()
 ot=ot+1
 if ot>90 and (btnp(4) or btnp(5)) then
  st="intro" it=340 parts={}
 end
end

-->8
-- drawing the game

function dspr(s,x,y,f)
 spr(s,ox+x,oy+y,1,1,f)
 if x>112 then spr(s,ox+x-120,oy+y,1,1,f) end
end

function draw_en(e)
 local k=kt[e.t]
 if e.sp>0 then
  local r=(30-e.sp)/4
  circ(ox+e.x+4,oy+e.y+4,r,k.c)
  if e.sp%4<2 then circ(ox+e.x+4,oy+e.y+4,r/2,k.c2) end
  return
 end
 -- mites hide unless you're close
 if k.inv and dying==0 then
  if abs(e.x-p.x)+abs(e.y-p.y)>40 and gt%60>8 then return end
 end
 if e.t==4 and e.life<180 and gt%8<4 then pal(11,8) pal(3,2) end
 dspr(k.s+flr(e.an/10)%2,e.x,e.y,e.d==0)
 pal()
end

function draw_pl()
 if dying>0 then
  if dying>30 then
   pal(12,8) pal(15,7)
   dspr(1,p.x,p.y,gt%8<4)
   pal()
  end
  return
 end
 if p.inv>0 and gt%6<3 then return end
 dspr(1+flr(p.an/6)%2,p.x,p.y,p.fl)
end

function draw_game()
 cls(0)
 for s in all(specks) do pset(ox+s[1],oy+s[2],s[3]) end
 map(0,0,ox,oy,15,13)
 clip(ox,oy,120,104)
 for e in all(en) do draw_en(e) end
 draw_pl()
 if pb then
  circfill(ox+pb.x,oy+pb.y,1,12)
  pset(ox+pb.x,oy+pb.y-1,7)
 end
 for b in all(ebs) do
  circfill(ox+b.x,oy+b.y,1,5)
  pset(ox+b.x,oy+b.y-1,6)
 end
 for q in all(parts) do
  circfill(ox+q.x,oy+q.y,q.l>25 and 1 or 0,q.c)
 end
 for q in all(pops) do print(q.s,ox+q.x,oy+q.y,7) end
 clip()
 -- hud
 print("score "..pad(score,5).."0",2,1,7)
 print("hi "..pad(max(hi,score),5).."0",90,1,6)
 for i=1,min(lives,6) do spr(1,2+(i-1)*7,7) end
 local nm="lv"..lvl.." "..lvn[(lvl-1)%#lvn+1]
 print(nm,126-#nm*4,9,14)
 print("dust left "..(#queue+#en),4,122,5)
 for e in all(en) do
  if e.t==4 and e.sp==0 then
   print("booger king "..(flr(e.life/60)+1),70,122,11)
  end
 end
 if st=="play" then
  if msgt>0 then cprint(msg,58,7,2) end
  if ready>0 then cprint("get ready!",70,10,0) end
 elseif st=="clear" then
  if ct<35 then cprint("ah...",60,7,2)
  elseif ct<70 then cprint("ah... ah...",60,7,2)
  else bcprint("achoo!!",50,7,8) end
  if ct>100 then cprint("passage cleared!",72,11,3) end
 else
  bcprint("game over",48,8,2)
  if newhi then cprint("new high score!",66,10,0) end
  if ot>90 then cprint("press x",80,7,0) end
 end
end
