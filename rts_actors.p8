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
