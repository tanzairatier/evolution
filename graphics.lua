function love.draw()

   images = {};
   images["title"] = love.graphics.newImage("images/title.png");

   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Graphic Constants
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --window dimensions
   local iWINDOW_WIDTH = 1024;
   local iWINDOW_HEIGHT = 768;

   --cell dimensions  --<< change these in accordance with iWORLD_WIDTH and iWORLD_HEIGHT (main)
   local iCELL_WIDTH = 10;
   local iCELL_HEIGHT = 10;

   --these offsets center the game grid
   local iOFFSET_X = (iWINDOW_WIDTH - iCELL_WIDTH*iWORLD_WIDTH)*0.50;
   local iOFFSET_Y = (iWINDOW_HEIGHT - iCELL_HEIGHT*iWORLD_HEIGHT)*0.50;


   if (bDRAW_GRAPHICS) then

   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- draw game grid
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(200, 200, 200, 255);

   --horizontal lines
   for i=1,iWORLD_WIDTH+1 do
      love.graphics.line(iOFFSET_X + (i-1)*iCELL_WIDTH, iOFFSET_Y+0, iOFFSET_X+(i-1)*iCELL_WIDTH, iOFFSET_Y+iCELL_HEIGHT*iWORLD_HEIGHT);
   end

   --vertical lines
   for i=1,iWORLD_HEIGHT+1 do
      love.graphics.line(iOFFSET_X+0, iOFFSET_Y+(i-1)*iCELL_HEIGHT, iOFFSET_X+iCELL_WIDTH*iWORLD_WIDTH, iOFFSET_Y+(i-1)*iCELL_HEIGHT);
   end

   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Draw jungle
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(40, 80, 255, 255);
   love.graphics.rectangle('line', iOFFSET_X + aJUNGLE[1]*iCELL_WIDTH, iOFFSET_Y + aJUNGLE[2]*iCELL_HEIGHT, iCELL_WIDTH*aJUNGLE[3], iCELL_HEIGHT*aJUNGLE[4]);

   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Draw Plants
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(10, 255, 10, 255);
   for i=1,iWORLD_WIDTH do
      for j=1,iWORLD_HEIGHT do
	     if (aaPLANTS[i][j] == true) then
	        love.graphics.rectangle('fill', iOFFSET_X + (i-1)*iCELL_HEIGHT+1, iOFFSET_Y + (j-1)*iCELL_WIDTH+1, iCELL_WIDTH-2, iCELL_HEIGHT-2);
		 end
	  end
   end

   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Draw Animals
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   love.graphics.setColor(200, 80, 20);
   for i,v in ipairs(aANIMALS) do
      love.graphics.rectangle('fill', iOFFSET_X + (v.x-1)*iCELL_HEIGHT+1, iOFFSET_Y + (v.y-1)*iCELL_WIDTH+1, iCELL_WIDTH-2, iCELL_HEIGHT-2);
   end

   end -- switch

   love.graphics.setColor(255, 255, 255, 255);
   local str = "Total Elapsed time: " .. iDAYS .. " days";
   love.graphics.print(str, iWINDOW_WIDTH*0.05, iWINDOW_HEIGHT*0.975);

   str = "Length of a day: " .. fDAY_LENGTH .. "ms";
   love.graphics.print(str, iWINDOW_WIDTH*0.05, iWINDOW_HEIGHT*0.95);

   str = "Number of Animals: " .. #aANIMALS;
   love.graphics.print(str, iWINDOW_WIDTH*0.35, iWINDOW_HEIGHT*0.95);

   str = "(Q)uit, (P)ause, (D)raw, (S)peed (C)hange, (R)eset, Move Jungle: Arrow Keys, Size Jungle: h/j/n/m, Enter: 10k Years";
   love.graphics.print(str, iWINDOW_WIDTH*0.35, iWINDOW_HEIGHT*0.975);

   love.graphics.draw(images["title"], (iWINDOW_WIDTH - 439)*0.50, (iWINDOW_HEIGHT)*0.01);
end

