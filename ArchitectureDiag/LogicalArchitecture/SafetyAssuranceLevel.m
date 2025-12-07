classdef SafetyAssuranceLevel < Simulink.IntEnumType
    % SafetyAssuranceLevel Enumeration type definition for use with System Composer profile

    enumeration
        Unset(0)
        Low(1)
        Med(2)
        High(3)
    end

end
