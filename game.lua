-- wizards of snort
-- a nasal maze shooter
-- arrows: move  x/z: saline spray

ox,oy=4,16
-- tuning: overall pace and health
pspd=.75   -- player pixels per frame
espd=.7    -- monster speed multiplier
maxhp=6    -- health bar segments
pdur=480   -- power-up duration (frames)
-- power-ups: menthol (speed), tissue (shield), saline (rapid fire)
put={
 {s=13,c=11,nm="menthol rush!"},
 {s=14,c=12,nm="tissue shield!"},
 {s=15,c=9,nm="rapid spray!"}
}
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
maxlvl=9
lvn={"left nostril","right nostril","nasal cavity","the turbinates",
 "sinus junction","deep sinus","adenoid caves","near the brain","mucus core"}
big=chr(6).."w"..chr(6).."t"
-- straw mouth (foreground)
sox,soy=36,104

function _init()
 cartdata("wizards_of_snort_1")
 hi=dget(0)
 gt=0 shk=0 parts={} pops={} hp=maxhp hpfl=0
 pw={0,0,0} pbs={} gbs={} fb=nil win=0
 st="intro" it=0 flow={}
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
 elseif st=="story" then upd_story()
 elseif st=="play" then upd_play()
 elseif st=="clear" then upd_clear()
 elseif st=="ending" then upd_ending()
 else upd_over() end
end

function _draw()
 if shk>0 then camera(rnd(4)-2,rnd(4)-2) else camera() end
 if st=="intro" then draw_intro()
 elseif st=="story" then draw_story()
 elseif st=="ending" then draw_ending()
 else draw_game() end
 camera()
end

-->8
-- intro: the nose looms, the straw sucks

function upd_intro()
 it=it+1
 if it==60 or it==130 or it==200 then sfx(3) end
 if it==300 then
  sfx(4) shk=24
  puff(53,57,6,10) puff(75,57,5,10)
 end
 -- suction: dust streams into the straw
 if it>60 and it<300 then
  for i=1,2 do
   local a=rnd()
   add(flow,{x=sox+cos(a)*70,y=soy+sin(a)*40,c=pick({5,6,7})})
  end
 end
 for q in all(flow) do
  local dx,dy=sox-q.x,soy-q.y
  local d=sqrt(dx*dx+dy*dy)
  if d<6 or it>=300 then del(flow,q)
  else
   local v=1+60/d
   q.px,q.py=q.x,q.y
   q.x=q.x+dx/d*v q.y=q.y+dy/d*v
  end
 end
 if btnp(4) or btnp(5) then
  if it<370 then it=370 shk=0 parts={} flow={}
  elseif it>380 then start_story() end
 end
end

function dman(x,y,sz,fl,fr)
 sspr(fr*8,0,8,8,x,y,sz,sz,fl)
end

-- giant face rising over the horizon
function draw_face(wx,wy)
 circfill(64,-30,96,15)
 ovalfill(-24,10,152,110,15)
 -- eyes peeking from the top
 ovalfill(14,4,44,14,7) ovalfill(84,4,114,14,7)
 circfill(30,10,4,12) circfill(98,10,4,12)
 circfill(30,10,2,0) circfill(98,10,2,0)
 rectfill(10,0,48,6,15) rectfill(80,0,118,6,15)
 line(14,6,44,7,4) line(84,7,114,6,4)
 -- cheeks
 circfill(18,46,9,14) circfill(110,46,9,14)
 -- nose bridge (light) and bulb
 -- soft shadow under the nose
 ovalfill(36+wx,52+wy,92+wx,68+wy,14)
 circfill(45+wx,47+wy,11,9) circfill(83+wx,47+wy,11,9)
 circfill(64+wx,42+wy,18,9)
 circfill(45+wx,47+wy,10,15) circfill(83+wx,47+wy,10,15)
 circfill(64+wx,42+wy,17,15)
 rectfill(58+wx,0,70+wx,30+wy,15)
 line(57+wx,16,56+wx,30+wy,14) line(71+wx,16,72+wx,30+wy,14)
 circfill(64+wx,36+wy,5,7)
 -- nostrils
 ovalfill(45+wx,52+wy,61+wx,61+wy,4) ovalfill(67+wx,52+wy,83+wx,61+wy,4)
 ovalfill(47+wx,54+wy,59+wx,61+wy,0) ovalfill(69+wx,54+wy,81+wx,61+wy,0)
 for i=0,3 do
  line(70+i*3+wx,60+wy,71+i*3+wx,63+wy,4)
 end
 -- lips
 ovalfill(40,70,88,80,8)
 line(42,75,86,75,2)
end

function draw_floor()
 rectfill(0,84,127,127,4)
 line(0,84,127,84,9)
 for i=-6,6 do line(64+i*4,84,64+i*30,127,2) end
 for y in all({88,94,103,116}) do line(0,y,127,y,2) end
end

-- straw in perspective: thin at the nostril, wide at the mouth
function tpos(f,wx,wy)
 local nx,ny=53+wx,57+wy
 return nx+(sox-nx)*f,ny+(soy-ny)*f,1.5+f*10.5
end

function draw_straw(wx,wy)
 local sc=0
 if it>60 and it<300 then sc=it/10 end
 for i=0,60 do
  local f=i/60
  local x,y,r=tpos(f,wx,wy)
  local c=8
  if flr(sqrt(f)*14+sc)%2==0 then c=7 end
  circfill(x,y,r,c)
 end
 -- the explorer as a bulge travelling up the tube
 if it>=230 and it<300 then
  local f=1-(it-230)/70
  f=f*f
  local x,y,r=tpos(f,wx,wy)
  circfill(x,y,r+1,7) circ(x,y,r+1,8)
  local s=2+f*5
  dman(x-s/2,y-s/2,s,gt%8<4,1)
 end
 -- open mouth of the straw
 ovalfill(sox-13,soy-10,sox+13,soy+10,8)
 ovalfill(sox-11,soy-8,sox+11,soy+8,7)
 ovalfill(sox-9,soy-6,sox+9,soy+7,0)
 if it>60 and it<300 then
  circ(sox,soy,3+(gt%12)/2,1)
 end
end

function draw_intro()
 cls(1)
 local wx,wy=0,0
 if it>=300 and it<360 then wx=sin(it/6)*2 wy=cos(it/9) end
 draw_face(wx,wy)
 draw_floor()
 for q in all(flow) do
  line(q.px or q.x,q.py or q.y,q.x,q.y,q.c)
 end
 draw_straw(wx,wy)
 -- the tiny explorer
 local mx,my=46,104
 if it<60 then
  dman(mx,my,8,it>30,1)
 elseif it<200 then
  if it<130 then
   local f=1-(it-60)/70
   mx=66-20*f*f
  else
   mx=66-10*(it-130)/70+rnd(2)-1
  end
  dman(mx,my,8,false,gt%6<3 and 1 or 2)
  -- sweat flying off
  if gt%8<4 then pset(mx-1,my+1,12) pset(mx-3,my-1,12) end
  if it<85 then print("!",mx+3,my-8,7) end
  if it>140 then print("help!",mx-2,my-9,7) end
 elseif it<230 then
  local f=(it-200)/30
  local e=f*f
  local s=8-4*e
  mx=56+(sox-56)*e my=104+(soy-104)*e-sin(f*.5)*12
  dman(mx-s/2+4,my-s/2+4,s,gt%4<2,1)
  print("help!",mx-2,my-12,7)
 end
 for q in all(parts) do circfill(q.x,q.y,q.l>15 and 1 or 0,q.c) end
 -- captions
 if it<60 then cprint("a tiny explorer wanders...",119,7,0)
 elseif it<130 then cprint("uh oh... suction!",119,10,0)
 elseif it<200 then cprint("run!! run!!",119,8,0)
 elseif it<300 then cprint("ssshhluuuuurp!",119,12,1)
 elseif it<370 then cprint("*snnnorrrrrt*",119,9,4)
 else draw_title() end
end

function draw_title()
 rectfill(0,0,127,39,0)
 line(0,39,127,39,14)
 bcprint("wizards",3,11,3)
 bcprint("of snort",17,10,4)
 if gt%40<26 then cprint("press x to start",31,7,0) end
 -- monster roster
 rectfill(84,82,127,127,0)
 rect(84,82,127,127,13)
 print("dust foes",88,85,7)
 for i=1,4 do
  local k=kt[i]
  local y=84+i*9
  spr(k.s+flr(gt/12)%2,88,y)
  print(i<4 and tostr(k.sc*10) or "???",100,y+2,k.c)
 end
 print("hi "..pad(hi,5).."0",2,121,6)
end

-->8
-- story: why you're up this nose

story={
 {"this nose belongs to a guy",
  "who snorted every random",
  "powder he could get his",
  "hands on."},
 {"now his nasal passages are",
  "clogged solid with dust,",
  "pollen and who-knows-what."},
 {"and thanks to that straw,",
  "you're stuck in there too!"},
 {"the dust has come alive.",
  "clear out every passage",
  "with your saline spray..."},
 {"...and trigger the big",
  "sneeze that blasts you free!",
  "",
  "grab power-ups. good luck!"}
}

function start_story()
 st="story" sp=1 stt=0 parts={}
 -- powder drifting through the passage
 dust={}
 for i=1,40 do
  add(dust,{x=rnd(128),y=rnd(84),v=.2+rnd(.6),c=pick({7,6,14,10,12,15})})
 end
end

function story_len()
 local n=0
 for l in all(story[sp]) do n=n+#l end
 return n
end

function upd_story()
 stt=stt+1
 for d in all(dust) do
  d.x=d.x+d.v d.y=d.y+sin(gt/90+d.x/40)*.3
  if d.x>128 then d.x=-2 d.y=rnd(84) end
 end
 local shown=flr(stt/2)
 if shown<story_len() and stt%4==0 then sfx(13) end
 if btnp(4) then start_game() return end
 if btnp(5) then
  if shown<story_len() then stt=story_len()*2
  elseif sp<#story then sp=sp+1 stt=0
  else start_game() end
 end
end

function draw_story()
 cls(2)
 -- the nasal passage, receding into the dark
 for i=0,7 do
  local r=70-i*9+sin(gt/120)*2
  ovalfill(64-r,42-r*.6,64+r,42+r*.6,({2,8,14,8,2,1,0,0})[i+1])
 end
 -- hairs around the rim
 for i=0,15 do
  local a=i/16+gt/2000
  local x0,y0=64+cos(a)*70,42+sin(a)*42
  line(x0,y0,64+cos(a)*58,42+sin(a)*35,4)
 end
 for d in all(dust) do pset(d.x,d.y,d.c) end
 -- dust monsters lurking deeper in, from page 4 on
 if sp>=4 then
  for i=0,2 do
   spr(3+flr(gt/12)%2+i*2,40+i*20,30+sin(gt/60+i/3)*3)
  end
 end
 -- the tiny explorer, looking around
 local fl=flr(gt/40)%2==0
 sspr(88,0,8,8,56,58,16,16,fl)
 -- text box
 rectfill(0,84,127,127,0)
 line(0,84,127,84,14)
 local left=flr(stt/2)
 for i=1,#story[sp] do
  local l=story[sp][i]
  local t=sub(l,1,max(left,0))
  print(t,4,88+(i-1)*8,7)
  left=left-#l
 end
 if left>=0 and gt%30<20 then
  print(sp<#story and "x: next" or "x: start",96,121,10)
 end
 print("z: skip",2,121,5)
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
 score=0 lives=2 lvl=1 nxl=1000 hp=maxhp
 start_level()
end

function start_level()
 gen_maze()
 p={x=8,y=88,d=1,an=0,fl=false,inv=0,acc=0}
 hp=min(hp+3,maxhp)
 en={} ebs={} pbs={} fcd=0 parts={} pops={}
 pw={0,0,0} pu=nil pwt=240+flr(rnd(240))
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
 msg="lv"..lvl..": "..lvn[lvl] msgt=90
 if lvl==maxlvl then msg="final level: "..lvn[lvl] end
 fb=nil win=0 gbs={}
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

function damage(n)
 if pw[2]>0 then return end
 hp=max(hp-n,0)
 if hp==0 then hurt() return end
 p.inv=75 shk=4 hpfl=20
 sfx(10)
 puff(p.x+4,p.y+4,8,5)
end

function hurt()
 hp=0
 dying=60 pbs={} shk=10
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
 if win>0 then
  win=win-1
  if win%6==0 then
   puff(rnd(120),rnd(104),pick({11,3,7}),8) sfx(1)
  end
  if win==0 then start_ending() end
  return
 end
 upd_player()
 upd_pb()
 upd_pw()
 upd_fb()
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
    hp=maxhp pw={0,0,0}
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
 p.acc=p.acc+(pw[1]>0 and pspd*1.7 or pspd)
 while p.acc>=1 do
  p.acc=p.acc-1
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
 end
 if p.d<2 then p.fl=p.d==0 end
 if fcd>0 then fcd=fcd-1 end
 local rap=pw[3]>0
 -- with rapid spray, holding the button auto-fires
 local fire=btnp(4) or btnp(5) or (rap and (btn(4) or btn(5)))
 if fire and fcd<=0 and #pbs<(rap and 3 or 1) then
  add(pbs,{x=p.x+4,y=p.y+4,d=p.d,v=rap and 3 or 2})
  fcd=rap and 8 or 0
  sfx(0)
 end
end

function move_pb(b)
 for i=1,b.v do
  b.x=b.x+dxs[b.d+1] b.y=b.y+dys[b.d+1]
  if b.x<0 or b.x>=120 or solid(flr(b.x/8),flr(b.y/8)) then
   puff(b.x,b.y,12,3) return false
  end
  for e in all(en) do
   if e.sp==0 and abs(e.x+4-b.x)<5 and abs(e.y+4-b.y)<5 then
    kill(e) return false
   end
  end
  if fb and abs(fb.x+8-b.x)<8 and abs(fb.y+8-b.y)<8 then
   hit_fb() return false
  end
 end
 return true
end

function upd_pb()
 for b in all(pbs) do
  if not move_pb(b) then del(pbs,b) end
 end
end

-- power-ups
function spawn_pu()
 local cx,cy
 for i=1,40 do
  cx=1+flr(rnd(7))*2 cy=1+flr(rnd(6))*2
  if abs(cx*8-p.x)+abs(cy*8-p.y)>=40 then break end
 end
 pu={x=cx*8,y=cy*8,t=flr(rnd(3))+1,life=600}
 sfx(6)
end

function upd_pw()
 for i=1,3 do
  if pw[i]>0 then
   pw[i]=pw[i]-1
   if pw[i]==0 then sfx(12) end
  end
 end
 if pu then
  pu.life=pu.life-1
  if pu.life<=0 then
   pu=nil pwt=360+flr(rnd(300))
  elseif dying==0 and abs(pu.x-p.x)<7 and abs(pu.y-p.y)<7 then
   local t=put[pu.t]
   pw[pu.t]=pdur
   msg=t.nm msgt=60
   sfx(11)
   puff(pu.x+4,pu.y+4,t.c,12)
   pu=nil pwt=420+flr(rnd(360))
  end
 else
  pwt=pwt-1
  if pwt<=0 and dying==0 then spawn_pu() end
 end
 -- speed trail
 if pw[1]>0 and dying==0 and gt%3==0 then
  add(parts,{x=p.x+2+rnd(4),y=p.y+5+rnd(2),dx=0,dy=0,c=pick({11,3}),l=12})
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
  spawn(queue[#queue]) queue[#queue]=nil sptm=60
 end
 local angry=#queue==0 and #en<=2
 for e in all(en) do
  local k=kt[e.t]
  if e.sp>0 then e.sp=e.sp-1
  else
   local v=min(k.spd*espd*(1+(lvl-1)*.05)*(angry and 1.3 or 1),1.5)
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
     add(ebs,{x=e.x+4,y=e.y+4,d=d}) e.cd=120 sfx(8)
    end
   end
   if dying==0 and p.inv<=0 and abs(e.x-p.x)<6 and abs(e.y-p.y)<6 then damage(2) end
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
   bossin=true sfx(7)
   if lvl==maxlvl then
    spawn_fb()
    msg="the snot lord awakens!" msgt=120 shk=20
   else
    spawn(4)
    msg="the booger king appears!" msgt=90
   end
  elseif fb or win>0 then
   -- final boss still fighting / dying
  else
   st="clear" ct=0 pbs={} ebs={} pu=nil
  end
 end
end

function upd_ebs()
 for b in all(ebs) do
  local dead=false
  b.acc=(b.acc or 0)+1.25
  while b.acc>=1 do
   b.acc=b.acc-1
   b.x=b.x+dxs[b.d+1] b.y=b.y+dys[b.d+1]
   if b.x<0 or b.x>=120 or solid(flr(b.x/8),flr(b.y/8)) then dead=true break end
   if dying==0 and p.inv<=0 and abs(p.x+4-b.x)<4 and abs(p.y+4-b.y)<4 then
    dead=true damage(1) break
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
  st="intro" it=370 parts={} flow={}
 end
end

-->8
-- final boss: the snot lord

function spawn_fb()
 fb={x=52,y=4,hp=100,mhp=100,fl=0,t=0,cd=150,mc=300,pat=0}
 en={}
end

-- every few seconds the snot lord crusts over and shrugs off shots
function fb_arm()
 local c=fb.hp<=fb.mhp/2 and 240 or 300
 return fb.t%c>=c-100
end

function hit_fb()
 if fb_arm() then
  puff(fb.x+8,fb.y+8,6,3) sfx(8)
  return
 end
 fb.hp=fb.hp-1 fb.fl=6
 sfx(10)
 puff(fb.x+8,fb.y+8,11,4)
 if fb.hp<=0 then
  score=min(score+1000,32000)
  add(pops,{x=fb.x,y=fb.y,s="10000",l=90})
  for i=1,4 do puff(fb.x+8,fb.y+8,pick({11,3,7}),12) end
  for e in all(en) do puff(e.x+4,e.y+4,kt[e.t].c,8) end
  fb=nil en={} ebs={} gbs={} queue={}
  msg="the snot lord is defeated!" msgt=150
  win=150 shk=40 sfx(5)
 elseif fb.hp==flr(fb.mhp/2) then
  msg="the snot lord is furious!" msgt=90 shk=12 sfx(7)
 end
end

function glob(a,v)
 add(gbs,{x=fb.x+8,y=fb.y+8,dx=cos(a)*v,dy=sin(a)*v})
end

function upd_fb()
 -- mucus globs drift straight through the nose hairs
 for g in all(gbs) do
  g.x=g.x+g.dx g.y=g.y+g.dy
  if g.x<-4 or g.x>124 or g.y<-4 or g.y>108 then del(gbs,g)
  elseif dying==0 and p.inv<=0 and abs(p.x+4-g.x)<4 and abs(p.y+4-g.y)<4 then
   del(gbs,g) damage(1)
  end
 end
 if not fb then return end
 local mad=fb.hp<=fb.mhp/2
 fb.t=fb.t+1
 if fb.fl>0 then fb.fl=fb.fl-1 end
 -- ooze toward the player, ignoring walls
 local dx,dy=p.x-4-fb.x,p.y-4-fb.y
 local d=max(sqrt(dx*dx+dy*dy),1)
 local v=mad and .42 or .3
 fb.x=mid(4,fb.x+dx/d*v+sin(fb.t/90)*.4,100)
 fb.y=mid(4,fb.y+dy/d*v+cos(fb.t/70)*.3,84)
 -- attacks: ring of globs, then aimed spread
 fb.cd=fb.cd-1
 if fb.cd<=0 then
  fb.pat=fb.pat+1
  if fb.pat%2==1 then
   local n=mad and 12 or 8
   for i=0,n-1 do glob(i/n+fb.t/300,.7) end
  else
   local a=atan2(p.x+4-fb.x-8,p.y+4-fb.y-8)
   for i=-2,2 do glob(a+i*.04,.9) end
   if mad then for i=-1,1 do glob(a+i*.06,1.2) end end
  end
  sfx(8)
  fb.cd=mad and 90 or 140
 end
 -- calls in dust minions
 fb.mc=fb.mc-1
 if fb.mc<=0 and #en<(mad and 4 or 2) then
  spawn(pick(mad and {1,2,3} or {1,2}))
  fb.mc=mad and 240 or 360
 end
 if dying==0 and p.inv<=0 and abs(fb.x+8-p.x-4)<9 and abs(fb.y+8-p.y-4)<9 then
  damage(2)
 end
end

function draw_fb()
 for g in all(gbs) do
  circfill(ox+g.x,oy+g.y,2,3)
  circfill(ox+g.x-.5,oy+g.y-.5,1,11)
 end
 if not fb then return end
 if fb.fl>0 then for i=1,15 do pal(i,7) end
 elseif fb_arm() then pal(11,6) pal(3,5) end
 local sq=sin(fb.t/30)
 sspr(0,16,16,16,ox+fb.x-sq,oy+fb.y+sq,16+sq*2,16-sq*2,p.x<fb.x)
 pal()
 -- boss health bar on the top border
 print("snot lord",ox+4,oy+2,7)
 rect(ox+42,oy+2,ox+116,oy+6,0)
 rectfill(ox+43,oy+3,ox+43+72*fb.hp/fb.mhp,oy+5,fb.hp<=fb.mhp/2 and 8 or 11)
end

-->8
-- ending: sneezed back out

function start_ending()
 st="ending" et=0 parts={} spray={}
 if score>hi then hi=score dset(0,hi) end
end

function upd_ending()
 et=et+1
 if et==100 then
  sfx(5) shk=30
 end
 if et>=100 and et<150 then
  for i=1,3 do
   local nx=pick({53,75})
   add(spray,{x=nx,y=58,dx=rnd(4)-2,dy=rnd(3)-.5,r=0,v=.08+rnd(.12),c=pick({7,7,6,12,11})})
  end
 end
 for q in all(spray) do
  q.x=q.x+q.dx q.y=q.y+q.dy q.dy=q.dy+.05 q.r=q.r+q.v
  if q.y>140 or q.r>4 then del(spray,q) end
 end
 if et>300 and (btnp(4) or btnp(5)) then
  st="intro" it=370 parts={} flow={}
 end
end

function draw_ending()
 cls(1)
 local wx,wy=0,0
 if et<100 then
  -- ah... ah...: the nose twitches harder and harder
  local k=et/100
  wx=sin(et/(8-k*5))*k*2 wy=-k*3
 elseif et<140 then
  wx=rnd(4)-2 wy=rnd(4)-2
 end
 draw_face(wx,wy)
 draw_floor()
 -- nostrils flare before the sneeze
 if et>50 and et<100 then
  ovalfill(46+wx,53+wy,60+wx,61+wy,0) ovalfill(68+wx,53+wy,82+wx,61+wy,0)
 end
 for q in all(spray) do circfill(q.x,q.y,q.r,q.c) end
 -- the explorer rockets out, tumbling toward you
 if et>=104 then
  local f=min((et-104)/56,1)
  local sz=2+14*f
  local x=53+(56-53)*f
  local y=58+(96-58)*f-sin(f*.5)*30
  if f<1 then
   local spin=flr(et/3)%4
   local sx=({8,96,8,88})[spin+1]
   for i=0,15 do pal(i,1) end
   for o=-1,1,2 do
    sspr(sx,0,8,8,x-sz/2+o,y-sz/2,sz,sz,spin>1)
    sspr(sx,0,8,8,x-sz/2,y-sz/2+o,sz,sz,spin>1)
   end
   pal()
   sspr(sx,0,8,8,x-sz/2,y-sz/2,sz,sz,spin>1)
  else
   -- landed: bounce, then a happy wave
   local b=max(0,8-(et-160))*abs(sin((et-160)/16))
   sspr(88,0,8,8,x-8,y-8-b,16,16,flr(et/20)%2==0)
   if et>190 then print(big.."yay!",x+10,y-20,10) end
  end
 end
 -- captions
 if et<50 then cprint("ah...",119,7,0)
 elseif et<100 then cprint("ah... ah...",119,7,0)
 elseif et<160 then bcprint("achoo!!!",20,7,8)
 end
 if et>200 then
  rectfill(0,0,127,30,0)
  line(0,30,127,30,14)
  bcprint("you're free!",3,11,3)
  cprint("final score "..pad(score,5).."0",19,7,0)
 end
 if et>300 then
  rectfill(16,108,111,126,0)
  rect(16,108,111,126,14)
  cprint("thanks for playing",111,7,0)
  if gt%40<26 then cprint("press x",119,10,0) end
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
 if pw[2]>0 and (pw[2]>90 or gt%8<4) then
  circ(ox+p.x+3.5,oy+p.y+3.5,6,gt%8<4 and 12 or 7)
 end
 if p.inv>0 and gt%6<3 then return end
 local fr=flr(p.an/6)%2
 if p.d==2 then dspr(12,p.x,p.y,fr==1)
 elseif p.d==3 then dspr(11,p.x,p.y,fr==1)
 else dspr(1+fr,p.x,p.y,p.fl) end
end

function draw_hp()
 if hpfl>0 then hpfl=hpfl-1 end
 local hc=hp>3 and 11 or (hp>1 and 10 or 8)
 local hx=54
 print(chr(135),hx,1,(hp<=1 and gt%20<10) and 2 or 8)
 rect(hx+7,0,hx+8+maxhp*4,6,hpfl%4>1 and 7 or 5)
 for i=1,maxhp do
  local x=hx+5+i*4
  rectfill(x,2,x+2,4,i<=hp and hc or 1)
 end
end

function draw_game()
 cls(0)
 for s in all(specks) do pset(ox+s[1],oy+s[2],s[3]) end
 map(0,0,ox,oy,15,13)
 clip(ox,oy,120,104)
 for e in all(en) do draw_en(e) end
 draw_pl()
 for b in all(pbs) do
  circfill(ox+b.x,oy+b.y,1,12)
  pset(ox+b.x,oy+b.y-1,7)
 end
 if pu and (pu.life>120 or gt%8<5) then
  local t=put[pu.t]
  circ(ox+pu.x+3,oy+pu.y+3,5+(gt/8)%3,t.c)
  spr(t.s,ox+pu.x,oy+pu.y-flr(sin(gt/40)+.5))
 end
 for b in all(ebs) do
  circfill(ox+b.x,oy+b.y,1,5)
  pset(ox+b.x,oy+b.y-1,6)
 end
 draw_fb()
 for q in all(parts) do
  circfill(ox+q.x,oy+q.y,q.l>25 and 1 or 0,q.c)
 end
 for q in all(pops) do print(q.s,ox+q.x,oy+q.y,7) end
 clip()
 -- hud
 print("score "..pad(score,5).."0",2,1,7)
 print("hi "..pad(max(hi,score),5).."0",90,1,6)
 draw_hp()
 for i=1,min(lives,6) do spr(1,2+(i-1)*7,7) end
 local nm="lv"..lvl.." "..lvn[lvl]
 print(nm,126-#nm*4,9,14)
 print("dust "..(#queue+#en),2,122,5)
 -- active power-ups with time left
 local x=32
 for i=1,3 do
  if pw[i]>0 then
   if pw[i]>90 or gt%8<5 then spr(put[i].s,x,120) end
   rect(x+9,122,x+19,126,5)
   rectfill(x+10,123,x+10+8*pw[i]/pdur,125,put[i].c)
   x=x+22
  end
 end
 for e in all(en) do
  if e.t==4 and e.sp==0 then
   print("king "..(flr(e.life/60)+1),99,122,11)
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
