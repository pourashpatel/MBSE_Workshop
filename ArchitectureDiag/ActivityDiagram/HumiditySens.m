function HumidSens = HumiditySens(HeaterCmd)
persistent x;

switch HeaterCmd
    case 20
        HumidSens = 30;
    case 25
        HumidSens = 35;
    case 30
        HumidSens = 45;
    case 35
        HumidSens = 55;
    case 40
        HumidSens = 65;
    otherwise
        HumidSens = 20;
end
if isempty (x)
    x = 1;
    
else
    x = x+1;
end

yyaxis left;
ylim([10 60]);
ylabel ('Heater Command in degC');
plot(x,HeaterCmd,'o','MarkerFaceColor','red');

yyaxis right;
ylim([0 100])
ylabel ('Humidity level in %');
plot(x,HumidSens,'-p','MarkerFaceColor','blue', 'MarkerSize',15);
legend ('HeaterCmd - degC','HumidityLevel - %');
end