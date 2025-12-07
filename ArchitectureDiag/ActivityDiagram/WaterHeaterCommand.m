function HeaterCmd = WaterHeaterCommand(HumidSens)

persistent init;
persistent x;
persistent prevHeaterCmd;

if isempty(init)
    HeaterCmd = 20;
    prevHeaterCmd = 20;
    init = 1;
   
else
    HeaterCmd = prevHeaterCmd;
end

if isempty (x)
    x = 1;
end
 
if HumidSens < 50
    HeaterCmd = HeaterCmd + 5;
    prevHeaterCmd = HeaterCmd;
    x = x + 1;
    hold on;
else
   
end

end