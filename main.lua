-- -- -- -- -- --
-- Evolution
-- -- -- -- -- --

function love.load()

   -- -- -- -- -- -- -- --
   -- global constants
   -- -- -- -- -- -- -- --

   --world dimensions --<< change these in accordance with iCELL_WIDTH and iCELL_HEIGHT (graphics)
   iWORLD_WIDTH = 100;
   iWORLD_HEIGHT = 60;

   --jungle dimensions (rectangle coords)
   aJUNGLE = {05,20,10,10};

   --amount of energy held by plants
   iPLANT_ENERGY = 80;

   --amount of energy required to reproduce
   iREPRODUCTION_ENERGY_COST = 100;

   --time elapsed between days
   fELAPSED = 0.000;

   --real time between days
   fDAY_LENGTH = 0.250;

   --number of days elapsed
   iDAYS = 0;

   --switches
   bPAUSED = false;
   bDRAW_GRAPHICS = true;

   --initial animal energy
   iANIMAL_START_ENERGY = 1000;

   --plants to add in jungle/world every day
   iDAILY_JUNGLE_PLANTS = 1;
   iDAILY_WORLD_PLANTS = 1;

   --Energy cost per animal step
   iMOVEMENT_ENERGY_COST = 1;

   --genetic modifier range
   aGENETIC_MOD = {-1, 1};


   -- -- -- -- -- -- -- -- --
   -- initialize randomizer
   -- -- -- -- -- -- -- -- --
   math.randomseed(os.time());

   -- -- -- -- -- -- --
   -- external files
   -- -- -- -- -- -- --
   require 'graphics';

   -- -- -- -- -- -- --
   -- Begin Simulation
   -- -- -- -- -- -- --
   begin_evolution();

end

function love.update(dt)
   if not (bPAUSED) then
      --collect elapsed time
      fELAPSED = fELAPSED + dt;
   end

   --only do if entire day elapsed
   if (fELAPSED > fDAY_LENGTH) then
      fELAPSED = 0;
	  day();
   end

end

function begin_evolution()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- Initialize routines necessary to begin
   -- a new simulation of evolution
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --Initiate Plantlife
   init_plantlife();

   --Initiate wildlife
   init_wildlife();

   --reset days
   iDAYS = 0;

end

function random_plant(left, top, width, height)
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- return a random location with in
   -- the supplied rectangle coordinates
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   return {x = left + math.random(width), y = top + math.random(height)};
end

function add_plants()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- add two plants to the game world
   -- one plant in jungle, other in world
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --first plant
   for i=1,iDAILY_JUNGLE_PLANTS do
      local pos = random_plant(unpack(aJUNGLE));
      aaPLANTS[pos.x][pos.y] = true;
   end

   --second plant
   for i=1,iDAILY_WORLD_PLANTS do
      pos = random_plant(0, 0, iWORLD_WIDTH, iWORLD_HEIGHT);
      aaPLANTS[pos.x][pos.y] = true;
   end
end

function init_plantlife()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- 2D array of booleans store plants
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   aaPLANTS = {};

   --no plants to begin with
   for i=1,iWORLD_WIDTH do
      aaPLANTS[i] = {};
      for k=1,iWORLD_HEIGHT do
	     aaPLANTS[i][k] = false;
	  end
   end
end

function init_wildlife()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- create "adam" the first animal and add
   -- it to the animal list
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   aANIMALS = {};

   --create first animal
   local first_animal = {
      x = math.floor(iWORLD_WIDTH/2),
	  y = math.floor(iWORLD_HEIGHT/2),
	  energy = iANIMAL_START_ENERGY,
	  dir = math.random(8),
	  genes = generate_genes()
   };

   --add to animal list
   table.insert(aANIMALS, first_animal);
end

function day()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- what goes on in a single day
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --Increment counter
   iDAYS = iDAYS + 1;

   --grow new plants
   add_plants();

   --stuff animals do
   for i,v in ipairs(aANIMALS) do
      --move in animal's direction
      move(v);

	  --possible change in direction
	  turn(v);

	  --possible eat if food here
	  eat(v);

	  --possible reproduce if enough energy
	  reproduce(v);
   end

   --animals die if have no energy
   aANIMALS = remove_dead_animals();
end

function remove_dead_animals()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- start from empty and add the living
   -- return clean list of living animals
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   local clean_animals = {};
   for i,v in ipairs(aANIMALS) do
      if (v.energy > 0) then table.insert(clean_animals, v); end
   end
   return clean_animals;
end

function generate_genes()
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- generate/return a list of direction-genes
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   local genes = {};
   for i=1,8 do
      table.insert(genes, math.random(2)-1);
   end
   return genes;
end

function move(animal)
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- move an animal in direction it faces
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   local dir = animal.dir;

   --move x (wrap abound the world)
   if (dir >= 2 and dir <= 4) then animal.x = math.mod(animal.x + 1, iWORLD_WIDTH);
   elseif (dir == 0 or dir >= 6) then animal.x = math.mod(animal.x - 1, iWORLD_WIDTH); end
   if (animal.x < 1) then animal.x = iWORLD_WIDTH; end

   --move y (wrap abound the world)
   if (dir <= 2) then animal.y = math.mod(animal.y - 1, iWORLD_HEIGHT);
   elseif (dir >= 4 and dir <= 6) then animal.y = math.mod(animal.y + 1, iWORLD_HEIGHT); end
   if (animal.y < 1) then animal.y = iWORLD_HEIGHT; end

   --deduct energy
   animal.energy = animal.energy - iMOVEMENT_ENERGY_COST;
end

function turn(animal)
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- turn in random direction based on genes
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --sum up genes and pick random
   local sum = 0;
   for i,v in ipairs(animal.genes) do sum = sum + v; end
   local pick = 0; --stays zero if sum is zero
   if not (sum == 0) then pick = math.random(sum); end

   --get gene associated with this random pick
   local sum2 = 0;
   local gene_choice;
   for i,v in ipairs(animal.genes) do
      sum2 = sum2 + v;
	  if (pick <= sum2) then gene_choice = (i-1); break; end
   end

   --set the direction with choice
   --if (gene_choice == nil) then gene_choice = 0; end --safeguard
   animal.dir = gene_choice;

end

function eat(animal)
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- eat if plant here
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   if (aaPLANTS[animal.x][animal.y] == true) then
      --remove the plant
      aaPLANTS[animal.x][animal.y] = false;

	  --give animal the plant energy
	  animal.energy = animal.energy + iPLANT_ENERGY;
   end
end

function copy_genes(animal)
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- simple gene copier; return copied list
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   local copied_genes = {};
   for i,v in ipairs(animal.genes) do table.insert(copied_genes, v); end
   return copied_genes;
end

function reproduce(animal)
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
   -- reproduce if an animal can
   -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

   --reproduce if have enough energy
   if (animal.energy > iREPRODUCTION_ENERGY_COST) then

      --split energy in half to the newborn
      animal.energy = math.floor(animal.energy*0.50);

	  --birth a new animal
	  local new_animal = {
         x = animal.x,
	     y = animal.y,
	     energy = animal.energy,
	     dir = animal.dir,
	     genes = copy_genes(animal)
      };

	  --pick a random gene to mutate
	  local m = math.random(1,8);

	  --mutate the random gene
	  new_animal.genes[m] = math.max(0, new_animal.genes[m] + math.random(unpack(aGENETIC_MOD)));

	  --add the new animal to the pride
	  table.insert(aANIMALS, new_animal);
   end
end

function love.keypressed(key, unicode)
   if key == 'P' or key == 'p' then
      --pause evolution/unpause
      bPAUSED = not(bPAUSED);
   end

   if key == 'D' or key == 'd' then
      --toggle graphics off
      bDRAW_GRAPHICS = not(bDRAW_GRAPHICS);
   end

   if key == 's' or key == 'S' then
      --Slow down evolution
      fDAY_LENGTH = fDAY_LENGTH*2.000;
   end

   if key == 'c' or key == 'C' then
      --speed up evolution
      fDAY_LENGTH = math.max(0.0001, fDAY_LENGTH/2.000);
   end

   if key == 'r' or key == 'R' then
      --reset evolution
	  begin_evolution();
   end

   if key == 'up' then
      --move the jungle up one cell
      aJUNGLE[2] = aJUNGLE[2] - 1;
   end

   if key == 'down' then
      --move the jungle down one cell
      aJUNGLE[2] = aJUNGLE[2] + 1;
   end

   if key == 'left' then
      --move the jungle left one cell
      aJUNGLE[1] = aJUNGLE[1] - 1;
   end

   if key == 'right' then
      --move the jungle right one cell
      aJUNGLE[1] = aJUNGLE[1] + 1;
   end

   if key == 'h' or key == 'H' then
      --shrink the width of the party by one cell
      aJUNGLE[3] = aJUNGLE[3] - 1;
   end

   if key == 'j' or key == 'J' then
      --expand the width of the party by one cell
      aJUNGLE[3] = aJUNGLE[3] + 1;
   end

   if key == 'n' or key == 'N' then
      --shrink the height of the party by one cell
       aJUNGLE[4] = aJUNGLE[4] - 1;
   end

   if key == 'm' or key == 'M' then
      --expand the height of the party by one cell
      aJUNGLE[4] = aJUNGLE[4] + 1;
   end

   if key =='return' then
      --Evolutionary spike of 10thousand days *takes a small while to do*
      local temp = bPAUSED;
      bPAUSED = true;
      for i=1,10000 do day(); end
	  bPAUSED = temp;
   end

   if key == 'Q' or key == 'q' then
      os.exit();
   end
end
