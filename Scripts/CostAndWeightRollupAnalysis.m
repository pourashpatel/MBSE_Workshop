function totalCost = CostAndWeightRollupAnalysis(instance,varargin)
% Analysis function for the Logical_Ventilator.slx example

totalCost = 0;

% Calculate total price
if instance.isComponent() && ~isempty(instance.Components)...
 && instance.hasValue('Ventilator_System.DurableComponent.UnitCost')
        sysComponent_unitPrice = 0; 
        for child = instance.Components
            if child.hasValue('Ventilator_System.DurableComponent.UnitCost')
               comp_price = child.getValue('Ventilator_System.DurableComponent.UnitCost');
               sysComponent_unitPrice = sysComponent_unitPrice + comp_price;
            end
        end
    if sysComponent_unitPrice>0
        instance.setValue('Ventilator_System.DurableComponent.UnitCost',sysComponent_unitPrice);
    end
    totalCost = totalCost + sysComponent_unitPrice;
end

% Calculate total weight
if instance.isComponent() && ~isempty(instance.Components)...
 && instance.hasValue('Ventilator_System.DurableComponent.Size')
        sysComponent_unitMass = 0; %instance.getValue('Profile_InsulinSystem.DurableComponent.Size');
        for child = instance.Components
            if child.hasValue('Ventilator_System.DurableComponent.Size')
               comp_weight = child.getValue('Ventilator_System.DurableComponent.Size');
               sysComponent_unitMass = sysComponent_unitMass + comp_weight;
            end
        end
    if sysComponent_unitMass>0
        instance.setValue('Ventilator_System.DurableComponent.Size',sysComponent_unitMass);
    end
end

