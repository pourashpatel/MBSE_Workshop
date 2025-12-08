cp = currentProject;

if (pwd ~= fullfile(cp.RootFolder,"Working"))
    cd Working
end

%Expand the System Composer tree and select Create Model by clicking on the Architecture Model button
FunctionalArchitectureModel = systemcomposer.createModel('Functional_Ventilation'); open(FunctionalArchitectureModel);
% Add main components on functional architecture
AddFunctionalComponent(bdroot, {'Setting Up Ventilation', 'Humidifier Setup', 'Ventilator Connection to Patient', 'Monitoring & Safety Checks'});
% Add child components on 'Setting up ventilation' component
AddFunctionalComponent(bdroot + "/Setting Up Ventilation", {'Connection With Air', 'Connection With O2'});

% Save file 
save_system("Functional_Ventilation")




%% ADD Functional Component API 
function AddFunctionalComponent(ArchitectureName, ComponentName)
    FunctionalArchitectureModel = systemcomposer.loadModel(bdroot);
    FunctionalArchitecture = FunctionalArchitectureModel.lookup('Path',ArchitectureName);
    if isa(FunctionalArchitecture, 'systemcomposer.arch.Architecture')
        addComponent(FunctionalArchitecture, ComponentName);
    else
        addComponent(FunctionalArchitecture.Architecture, ComponentName);
    end
    
    Simulink.BlockDiagram.arrangeSystem(bdroot);
end
