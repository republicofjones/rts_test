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