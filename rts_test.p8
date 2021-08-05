pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--init
actors={}
tile_col=false

--sets up variables at start
function _init()
	
	--cursor coordinates
	point_x=64
	point_y=64
	
	--flag coordinates
	flag_x=0
	flag_y=0
	
	draw_flag=false
	
	--create a villager
	player=create_actor(5,1,1)
	villager=create_actor(5,20,20)

	
end




-->8
--loop
--this updates 60 times each second
function _update60()
	player_input()
	foreach(actors,move_actor)
	

end

--this draws on the screen after each update
function _draw()
	--clear the screen each time
	cls()
	map()
	
	--draw the cursor
	spr(4, point_x, point_y)
	
	if (draw_flag) then
		spr(20, flag_x, flag_y)
	end
	
	foreach(actors,draw_actor)
	foreach(checked,draw_checked)
	foreach(player.path,draw_path)
	for i=1,#player.path do
		local vector=player.path[i]
		local x=vector[1]
		local y=vector[2]
		
		flag=fget(mget(x,y))
		print(flag,1,i*8)
	end
end
-->8
--player input

function player_input()
	if btn(⬅️) then
		point_x-=1
	end
	if btn(➡️) then
		point_x+=1
	end
	if btn(⬆️) then
		point_y-=1
	end
	if btn(⬇️) then
		point_y+=1
	end
	
	if btn(❎) then
		flag_x=point_x
		flag_y=point_y-8
		
		local start={player.x,player.y}
		local goal={flag_x,flag_y}
		
		draw_flag=true
		
		player.path=find_path(start,goal)
		player.path_node=1
		
	end
	
	if btn(🅾️) then
		draw_flag=false
	end
end
-->8
--actors
function create_actor(k,x,y)
	
	a={
		x=x,
		y=y,
		k=k,
		path={},
		path_node=0
		}
	
	add(actors,a)
	return a

end

function draw_actor(a)
	spr(a.k,a.x,a.y)
end

function move_actor(a)
		if (draw_flag) then
			
			
				local upscaled=grid_to_pix(player.path[player.path_node])
				local path_x=upscaled[1]
				local path_y=upscaled[2]
				
				local xs=path_x-a.x
				local ys=path_y-a.y
				
				if (xs==0) and (ys==0) then
					if player.path_node!=#player.path then
						player.path_node+=1
					else
						draw_flag=false
					end
			end
			
			
			dx=0
			dy=0
			
			
			if xs!=0 then
				dx=0.5*sgn(xs)	
			end
			if xy!=0 then
				dy=0.5*sgn(ys)
			end
		
		--if (tile_collision(a.x+dx,a.y)) dx=0
		--if (tile_collision(a.x,a.y+dy)) dy=0
		
		a.x+=dx
		a.y+=dy
	end
end

-->8
--collision
function tile_collision(x,y)
	collision=false
	tile_col=false
	if fget(mget(x/8,y/8))>0 then
		collision=true
		tile_col=true
	end
	
	return collision
end
-->8
--a* pathfinding
function find_path(start_vec,goal_vec)
	start=pix_to_grid(start_vec)
	goal=pix_to_grid(goal_vec)
	frontier={}
	wallid=1
	insert(frontier,start)
	came_from={}
	came_from[vectoindex(start)]=nil
	cost_so_far={}
	cost_so_far[vectoindex(start)]=0
	checked={}
	

	
	while #frontier>0 do
		current=popend(frontier)
		
		if vectoindex(current)==vectoindex(goal) then
			break
		end
		
		
		
		local neighbours=getneighbours(current)
		for next in all (neighbours) do
			local nextindex=vectoindex(next)
			local new_cost=cost_so_far[vectoindex(current)]+1
			
			if (cost_so_far[nextindex]==nil) or 
				(new_cost<cost_so_far[nextindex]) then
				
				cost_so_far[nextindex]=new_cost
				local priority=new_cost+heuristic(goal,next)
				insert(frontier,next,priority)
				
				came_from[nextindex]=current
				
				
			end
			
			add(checked,next)
			
		
		end
		
				
	end
	
	current=came_from[vectoindex(goal)]
	path={}
	
	local cindex=vectoindex(current)
	local sindex=vectoindex(start)
	
	while cindex!=sindex do
		add(path,current)
		current=came_from[cindex]
		cindex=vectoindex(current)
	end
	reverse(path)
	
	return path
	
end

--find all existing neighbours that aren't walls
function getneighbours(pos)
	local neighbours={}
	local x=pos[1]
	local y=pos[2]
	
	if x>0 and (fget(mget(x-1,y))!=wallid) then
		add(neighbours,{x-1,y})
	end
	if x<15 and (fget(mget(x+1,y))!=wallid) then
		add(neighbours,{x+1,y})
	end
	if y>0 and (fget(mget(x,y-1))!=wallid) then
		add(neighbours,{x,y-1})
	end
	if y<15 and (fget(mget(x,y+1))!=wallid) then
		add(neighbours,{x,y+1})
	end
	
	--diagonals
	if x>0 and (fget(mget(x-1,y-1))!=wallid) then
		add(neighbours,{x-1,y-1})
	end
	if x>0 and (fget(mget(x+1,y+1))!=wallid) then
		add(neighbours,{x+1,y+1})
	end
	if x>0 and (fget(mget(x-1,y+1))!=wallid) then
		add(neighbours,{x-1,y+1})
	end
	if x>0 and (fget(mget(x+1,y-1))!=wallid) then
		add(neighbours,{x+1,y-1})
	end
	
	if (x+y)%2==0 then
		reverse(neighbours)
	end
	
	return neighbours
		
end

--find the first locatin of a specific type of tile
function getspecialtile(tileid)
	for x=0,15 do
		for y=0,15 do
			local tile=mget(x,y)
				if tile==tileid then
					return {x,y}
				end
		end
	end
	printh("did not find tile:"..tileid)
	
end

--insert into start of table
function insert(t,val)
	for i=(#t+1), 2, -1 do
		t[i]=t[i-1]
	end
	t[1]=val
end

--pop the last element off a table
function popend(t)
	local top=t[#t]
	del(t,t[#t])
	
	return top[1]
end

function reverse(t)
	for i=1, #t/2 do
		local temp=t[i]
		local oppindex=#t-(i-1)
		t[i]=t[oppindex]
		t[oppindex]=temp
		
	end
end

--translate a 2d x,y coord to
--a10 index and back again

function vectoindex(vec)
	return maptoindex(vec[1],vec[2])
end

function maptoindex(x,y)
	return ((x+1)*16)+y
end

function indextomap(index)
	local x=(index-1)/16
	local y=index-(x*w)--???w???
	
	return {x,y}
end

--insert into table and sort by priority
function insert(t,val,p)
	if #t>0 then
		add(t,{})
		
		for i=(#t), 2, -1 do
			local next=t[i-1]
			if p<next[2] then
				t[i]={val,p}
				return
			else
				t[i]=next
			end
		end
		t[1]={val,p}
		
	else
		add(t,{val,p})
	end
end

function heuristic(a,b)
	return abs(a[1]-b[1])^2+abs(a[2]-b[2])^2
end

--additional functions
function pix_to_grid(vector)
	local x=flr(vector[1]/8)
	local y=flr(vector[2]/8)
	
	return {x,y}
	
end

function grid_to_pix(vector)
	local x=vector[1]*8
	local y=vector[2]*8
	
	return {x,y}
end

function draw_path(vector)
	local upscaled=grid_to_pix(vector)
	spr(36,upscaled[1],upscaled[2])
end

function draw_checked(vector)
	local upscaled=grid_to_pix(vector)
	spr(35,upscaled[1],upscaled[2])
end
__gfx__
00000000bbbbbbbbbbbbbbbbbbbbbbbb777000000000000000000000bbbb333bb33bbbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
00000000bbbbbbbbbbbbbbbbbbbbbbbb770000000000000000000000bbb333333333bbb33333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000
00700700b3bbbb3bbbbbbbbbbbbbbbbb707000000000000000000000bbb5333333333333333333bbbb4bbb4bbb4bbb4bb4bb4bbbbbbbbbbb0000000000000000
00077000bbbbbbbbbbbbbbbbbbbbbbbb000700000000000000000000bbbb4333333333535353333bbb4544444544454444454bbbbbbbbbbb0000000000000000
00077000bb3bbbbbbbbbbb3bbbbbbbbb000000000000000000000000bb335533554533335433335bbb4bbb4bb4bbbb4bb4bb4bbbbbbbbbbb0000000000000000
00700700bbbbbbbbb3bbbbbbbbbbbbbb00000000000f0000000f0000b333333335433333333335bbbbb4bbbbbbbbbbbbbbb4bbbbbbbbbbbb0000000000000000
00000000bbbbbbbbbb3bbbbbbbbbbbbb000000000004000000040000b5333335333353533335333bbbb4bbbbbbbbbbbbbbb45bbbbbbbbbbb0000000000000000
00000000bbbbbbbbbbbbbbbbbbbbbbbb000000000005000000050000bb454333333533353453335bbb45bbbbbbbbbbbbbbbb4bbbbbbbbbbb0000000000000000
00000000bbbbbbbbbbbb3bbb00000000000000000000000000000000bb33353335333335333335bbbb4bbbbb00000000bbbb4bbb000000000000000000000000
00000000bbbbbbbbbbbbbb3b00000000000000000000000000000000b333335353333333333333bbbbb4bbbb00000000bbbb5bbb000000000000000000000000
00000000bbbbbbbbbbbbbbbb0000000000000000000000000000000033333333333333333543333bbbb4bbbb00000000bb4bb4bb000000000000000000000000
00000000bb3bbbbbbbb66bbb00000000888000000000000000000000333333333533335333453333bb45bbbb00000000444454bb000000000000000000000000
00000000bbbbbabbbbb56bbb00000000888800000000000000000000533333333345453333333335bb4bbbbb00000000bb4bb4bb000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000888000000000000000000000b5454533333543333333345bbbb4bbbb00000000bbbbbbbb000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000400000000000000000000000bb43333333333533333454bbbbb4bbbb00000000bbbbbbbb000000000000000000000000
00000000bbbbbbbbbbbbbbbb00000000400000000000000000000000bb333333353333533354bbbbbb45bbbb00000000bbbbbbbb000000000000000000000000
00000000b3bbbbbbbbbbbb3b00000000000000000000000000000000bb3535333333333333333bbbbbb4bbbb0000000000000000000000000000000000000000
00000000333bbbbbbb3bb33300000000000000000000000000000000b333533333335333353333bbbbb5bbbb0000000000000000000000000000000000000000
00000000333bbb3bb333b3330000000000000000000000000000000033333333333335333353333bbb4bb4bb0000000000000000000000000000000000000000
00000000333bb333b333b333000d700000028000000000000000000053333333533333333333335bbb4454440000000000000000000000000000000000000000
00000000b4bbb333b333bb4b00077000000880000000000000000000b455333545453334533335bbbb4bb4bb0000000000000000000000000000000000000000
00000000b4bbb333bb4bbb4b00000000000000000000000000000000b4bb455bbb454554b4554bbbbbbbbbbb0000000000000000000000000000000000000000
00000000bbbbbb4bbb4bbbbb00000000000000000000000000000000bbbb4bbbbbbb4bbbb4bb4bbbbbbbbbbb0000000000000000000000000000000000000000
00000000bbbbbb4bbbbbbbbb00000000000000000000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000
__gff__
0000000000000001010101010100000000000000000000010101010001000000000101000000000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1103030303030303030303070903030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103031203110303070903171911030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1103031103010303272903171903030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030307080903120303171903030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303110317181903030303272903030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0312030117181903030303121a03110300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222227282903030303031a03030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303031a03030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303020303030b0b0b1c12030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303110303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303070903030302030311030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303272903030303030203030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030303020a0c03030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03031203032a1c03030303030312030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303031103030203030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000200002c35026250262502435025150213501d3501c120193501515014350102500f3500e1500a2500a25006350023500035018000170001700016000190002000000000000000000000000000000000000000
__music__
00 02424344

