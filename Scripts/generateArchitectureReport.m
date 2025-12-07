function generateArchitectureReport(modelName, outputPath)
    %% Generates report for modelName
    arguments
        modelName  (1,:) char
        outputPath (1,:) char = ''
    end
    % Need to replace with something better
    allocationSetPath = cleanPath('FunctionalToLogical.mldatx');

    import mlreportgen.report.*
    import slreportgen.report.*
    import slreportgen.finder.*
    import mlreportgen.dom.*
    import mlreportgen.utils.*
    import systemcomposer.query.*
    import systemcomposer.rptgen.finder.*

    % Tolerate the model name without extension, model name as a full path,
    % or model name with extension.
    modelName = cleanPath(modelName);

    % Loading model
    model = systemcomposer.loadModel(modelName);

    if isempty(outputPath)
        % Output the report in the current directory.
        outputPath = fullfile(pwd, [model.Name '.pdf']);
    else
        % Tolerate the report name without extension, report name as a full
        % path, or report name with extension.
        outputPath = cleanPath(outputPath, '.pdf');
    end

    % Initialising the report
    rpt = slreportgen.report.Report('OutputPath', outputPath, 'CompileModelBeforeReporting', false);

    % Appending title page and table of contents
    add(rpt,TitlePage("Title", sprintf('%s',model.Name)));
    add(rpt,TableOfContents);
    
    %% Chapter for Introduction 
    % Add sections and paragraphs to add textual information in the report
    Introduction = Chapter("Title", "Introduction");
    sec1_1 = Section('Title', "Purpose");
    p1 = Paragraph(['This document provides a comprehensive architectural' ...
        ' overview of the system using a number of different architecture views' ...
        ' to depict different aspects of the system. It is intended to capture' ...
        ' and convey the significant architectural decisions which have been' ...
        ' made for the system.']);
    append(sec1_1, p1);
    
    sec1_2 = Section("Scope");
    p2 = Paragraph(['This System Architecture Description provides an architectural...' ...
        ' overview of the ' model.Name ' architecture.']);
    append(sec1_2, p2);
    append(Introduction, sec1_1);
    append(Introduction, sec1_2);
    
    %% Chapter for Architectural Elements
    ArchitecturalElements = Chapter("Architecture Description");
    
    % Use the Simulink Diagram Finder to add a snapshot 
    % of the model in the report
    systemContext = Section(model.Name);
    finder = SystemDiagramFinder(model.Name);
    finder.SearchDepth = 0;
    results = find(finder);
    append(systemContext, results);
    
    append(ArchitecturalElements, systemContext);
    
    % Use the ComponentFinder to report on components in the model
    cf = ComponentFinder(model.Name);
    cf.Query = AnyComponent();
    comp_finder = find(cf);
    
    for comp = comp_finder
        componentSection = Section("Title", comp.Name);
        % List of components allocated from/to a particular component 
        d = AllocationListFinder(allocationSetPath);
        compObject = lookup(model,'UUID',comp.Object);
        d.ComponentName = getfullname(compObject.SimulinkHandle);
        result = find(d);
        append(componentSection, comp);
    
        % Component Information
        append(systemContext, componentSection);
    
        % Allocation Information
        append(systemContext, result);
    end
    
    %% Chapter for Allocation Sets in the model
    % Report on Allocation Sets associated with the model
    [~,allocSetName] = fileparts(allocationSetPath);
    allocation_finder = AllocationSetFinder(allocationSetPath);
    AllocationChapter = Chapter("Allocations");
    while hasNext(allocation_finder)
        alloc = next(allocation_finder);
        allocationName = Section(alloc.Name);
        append(allocationName, alloc);
        append(AllocationChapter, allocationName);
    end
    allocSet = systemcomposer.allocation.AllocationSet.find(allocSetName);
    close(allocSet);
    
    %% Chapters for Architecture Views in the model
    ViewChapter = Chapter("Architecture Views");
    view_finder = ViewFinder(model.Name);
    while(hasNext(view_finder))
        v = next(view_finder);
        viewName = Section('Title', v.Name);
        append(viewName, v);
        append(ViewChapter, viewName);
    end
    
    %% Chapter for Dependency Graph Image
    Packaging = Chapter("Packaging");
    packaging = Section('Title', 'Packaging');
    graph = systemcomposer.rptgen.report.DependencyGraph("Source", which(modelName));
    append(packaging, graph);
    append(Packaging, packaging);
    
    [linkSetPath, reqSetPaths] = getReqSets(modelName);

    if ~isempty(reqSetPaths)
        %% Chapter for Requirement Sets and LinkSets in the model 
        % Report on all the requirement sets associated with the model
        r = slreq.data.ReqData.getInstance();
        r.reset();
        ReqChapter = Chapter("Requirements Analysis");
        RequirementSetSection = Section("Requirement Sets");
        for reqSetPath = reqSetPaths
            reqFinder1 = RequirementSetFinder(reqSetPath);
            [~, reqSetName] = fileparts(reqSetPath);
            result = find(reqFinder1);
            r = slreq.data.ReqData.getInstance();
            r.reset();
            paragraphText = sprintf("This section captures the requirements associated with the '%s' architecture model that are captured in requirement set '%s'.", model.Name, reqSetName);
            pp = Paragraph(paragraphText);
            append(RequirementSetSection, pp);
            append(RequirementSetSection, result.getReporter);
        end
        
        % % Report on all the requirement link sets associated with the model
        RequirementLinkSection = Section("Requirement Link Sets");
        reqLinkFinder = RequirementLinkFinder(linkSetPath);
        resultL = find(reqLinkFinder);
        r = slreq.data.ReqData.getInstance();
        r.reset();
        rptr = systemcomposer.rptgen.report.RequirementLink("Source", resultL);
        append(RequirementLinkSection, rptr);
        
        append(ReqChapter, RequirementSetSection);
        append(ReqChapter, RequirementLinkSection);
    end
    
    %% Chapter for Interfaces in the model
    % Check if there are any dictionaries linked with the model
    df = DictionaryFinder(model.Name);
    dictionary = find(df); %#ok<EFIND> 
    
    if ~isempty(dictionary)
        % Create a seperate chapter for interfaces to report on all the
        % interfaces associated with the model
        InterfaceChapter = Chapter("Interfaces Appendix");
        interfaceFinder = InterfaceFinder(model.Name);
        interfaceFinder.SearchIn = "Model";
        while hasNext(interfaceFinder)
            intf = next(interfaceFinder);
            interfaceName = Section(intf.InterfaceName);
            append(interfaceName, intf);
            append(InterfaceChapter, interfaceName);
        end
    end
    
    %% Chapter for Profiles in the model
    if ~isempty(model.Profiles)
        ProfileChapter = Chapter("Profiles Appendix");
        profileFiles = string(strcat({model.Profiles.Name}, '.xml'));
        for profileFile = reshape(profileFiles, 1, [])
            pf = ProfileFinder(profileFile);
            while hasNext(pf)
                intf = next(pf);
                profileName = Section(intf.Name);
                append(profileName, intf);
                append(ProfileChapter, profileName);
            end

            %% Chapter for Stereotypes in the model 
            StereotypeSection = Section("Stereotypes");
            sf = StereotypeFinder(profileFile);
            while hasNext(sf)
                stf = next(sf);
                stereotypeName = Section(stf.Name);
                append(stereotypeName, stf);
                append(StereotypeSection, stereotypeName);
            end
            
            append(ProfileChapter, StereotypeSection);
        end
    end
    
    %% Add all the chapters to the report in the desired order 
    append(rpt, Introduction);
    append(rpt, ArchitecturalElements);
    append(rpt, ViewChapter);
    append(rpt, Packaging);
    append(rpt, AllocationChapter);

    if ~isempty(reqSetPaths)
        append(rpt, RequirementSetSection);
        append(rpt, RequirementLinkSection);
    end

    if ~isempty(dictionary)
        append(rpt, InterfaceChapter);
    end

    if ~isempty(model.Profiles)
        append(rpt, ProfileChapter);
    end
    
    %% Open the report
    rptview(rpt)
end

function CleanPath = cleanPath(dirtyPath, newExt)
    [pathDir, fileName, fileExt] = fileparts(which(dirtyPath));
    if nargin > 1
        % Use the user-provided file extension instead.
        fileExt = newExt;
    end

    CleanPath = [pathDir filesep fileName fileExt];
end

function [linksetPath, reqSetPaths] = getReqSets(modelName)
    linksetPath = cleanPath(modelName, '.slmx');
    reqSetPaths = [];
    
    if exist(linksetPath, 'file')
        linkSet = slreq.load(linksetPath);
        links = linkSet.getLinks;
        reqSetPaths = string.empty(numel(links), 0);
        reqSetPathsIndex = 1;
        for link = links
            reqSetPaths(reqSetPathsIndex) = link.destination.artifact;
            reqSetPathsIndex = reqSetPathsIndex + 1;
        end
        reqSetPaths = unique(reqSetPaths);

        % Only accept requirement set files
        [~,~,extensions] = fileparts(reqSetPaths);
        reqSetPaths = reqSetPaths(extensions==".slreqx");
    else
        linksetPath = [];
    end
end