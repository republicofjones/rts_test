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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
