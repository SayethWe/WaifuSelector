classdef WaifuSelector < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        LargeGridLayout                 matlab.ui.container.GridLayout
        
        WelcomePanel                    matlab.ui.container.Panel
        WelcomeGridLayout               matlab.ui.container.GridLayout
        WaifuRatingLabel                matlab.ui.control.Label
        LoadButton                      matlab.ui.control.Button
        NewButton                       matlab.ui.control.Button
        DatafileEditField               matlab.ui.control.EditField
        WelcomeStatusLabel              matlab.ui.control.Label
        
        NavigatePanel                   matlab.ui.container.Panel
        NavigateGridLayout              matlab.ui.container.GridLayout
        TabGroup                        matlab.ui.container.TabGroup
        
        OverviewTab                     matlab.ui.container.Tab
        OverviewGridLayout              matlab.ui.container.GridLayout
        SearchButton                    matlab.ui.control.StateButton
        CalculateRoundButton            matlab.ui.control.Button
        OverviewRoundsLabel             matlab.ui.control.Label
        GenerateNewButton               matlab.ui.control.Button
        SaveandExitButton               matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        GenerateImageButton             matlab.ui.control.Button
        OverviewTable                   matlab.ui.control.Table
        OverviewCountLabel              matlab.ui.control.Label
        OverviewElimLabel               matlab.ui.control.Label
        
        AddRemoveTab                    matlab.ui.container.Tab
        AddGridLayout                   matlab.ui.container.GridLayout
        AddField                        matlab.ui.control.EditField
        AddStatusMessageLabel           matlab.ui.control.Label
        AddConfirmButton                matlab.ui.control.Button
        AddRemoveButton                 matlab.ui.control.Button
        AddClearButton                  matlab.ui.control.Button
        AddImportFileButton             matlab.ui.control.StateButton
        
        VotesTab                        matlab.ui.container.Tab
        VotesGridLayout                 matlab.ui.container.GridLayout
        RoundsTab                       matlab.ui.container.Tab
        RoundsGridLayout                matlab.ui.container.GridLayout
        RoundsUITable                   matlab.ui.control.Table
        RoundsSpinner                   matlab.ui.control.Spinner
        RoundsUIAxes                    matlab.ui.control.UIAxes
        RoundsUIAxes2                   matlab.ui.control.UIAxes
        
        VotingImageTab                  matlab.ui.container.Tab
        ImageGridLayout                 matlab.ui.container.GridLayout
        Image                           matlab.ui.control.Image
        
        CreatePanel                     matlab.ui.container.Panel
        CreateGridLayout                matlab.ui.container.GridLayout
        ProbabilityScaleEditFieldLabel  matlab.ui.control.Label
        ProbabilityScaleEditField       matlab.ui.control.NumericEditField
        ImmunityScaleEditFieldLabel     matlab.ui.control.Label
        ImmunityScaleEditField          matlab.ui.control.NumericEditField
        SelectivityEditFieldLabel       matlab.ui.control.Label
        SelectivityEditField            matlab.ui.control.NumericEditField
        CreateTitle                     matlab.ui.control.Label
        CreateButton                    matlab.ui.control.Button
        CreateWarningLabel              matlab.ui.control.Label
        CollageHeightSpinnerLabel       matlab.ui.control.Label
        CollageHeightSpinner            matlab.ui.control.Spinner
        CollageWidthSpinnerLabel        matlab.ui.control.Label
        CollageWidthSpinner             matlab.ui.control.Spinner
        ImageHeightSpinnerLabel         matlab.ui.control.Label
        ImageHeightSpinner              matlab.ui.control.Spinner
        RoundSizeSpinnerLabel           matlab.ui.control.Label
        RoundSizeSpinner                matlab.ui.control.Spinner
        IndexFromZeroLabel              matlab.ui.control.Label
        ZeroIndexButton                 matlab.ui.control.StateButton
        SearchbyNameEditFieldLabel      matlab.ui.control.Label
        SearchbyNameEditField           matlab.ui.control.EditField
        RoundsCutoffLabel               matlab.ui.control.Label
    end
    
    
    properties (Access = private)
        %waifus=table([0;0;0],[1;1;1],'rowNames',["a","b","c"],'VariableNames',["Immunity","Probability"]); % list of all waifus
        waifus                                  table
        displayTable                            table
        title                                   string
        probabilityScale                        double % Offset for diminishing probability
        immunityScale                           double %coefficient for immunity length
        selectivity                             double %How strictly to eliminate
        roundSize                               double
        currentRoundSize                        double
        thisRound                               (:,1) string
        votes                                   (:,1) double % List of votes cast this round
        pastRounds                              (:,:) string %All Rounds
        pastVotes                               (:,:) double %All Votes
        roundNum                                double %current round
        roundView                               double %round currently veiwed
        numRounds                               double %Number of rounds completed
        imgTargetHeight                         double
        collageRows                             double
        collageColumns                          double
        votingNums                              (:,1) double
        loaded=false;
    end
    
    methods (Access = private)
        
        function loadFromFile(app)
            s=load(sprintf("%s\\save.mat",app.title),"waifus","pastRounds",...
                "pastVotes","probabilityScale","immunityScale",...
                "selectivity","roundSize","thisRound","votes",...
                "roundNum","imgTargetHeight","collageRows",...
                'collageColumns',"votingNums");
            app.waifus = s.waifus;
            app.displayTable=s.waifus;
            app.pastRounds=s.pastRounds;
            app.pastVotes=s.pastVotes;
            app.probabilityScale=s.probabilityScale;
            app.immunityScale=s.immunityScale;
            app.selectivity=s.selectivity;
            app.roundSize=s.roundSize;
            app.thisRound=s.thisRound;
            app.votes=s.votes;
            app.roundNum=s.roundNum;
            app.imgTargetHeight=s.imgTargetHeight;
            app.collageRows=s.collageRows;
            app.collageColumns=s.collageColumns;
            app.votingNums=s.votingNums;
            app.numRounds=size(app.pastRounds,2);
            app.currentRoundSize=length(app.thisRound);
            app.loaded=true;
        end
        
        function  saveToFile(app)
            if app.loaded
                if ~isfolder(app.title)
                    mkdir(app.title);
                    mkdir([app.title, '\\img']);
                end
                waifus=app.waifus;                      %#ok<NASGU,*ADPROP>
                pastRounds=app.pastRounds;              %#ok<NASGU,*ADPROP>
                pastVotes=app.pastVotes;                %#ok<NASGU,*ADPROP>
                probabilityScale=app.probabilityScale;  %#ok<NASGU,*ADPROP>
                immunityScale=app.immunityScale;        %#ok<NASGU,*ADPROP>
                selectivity=app.selectivity;            %#ok<NASGU,*ADPROP>
                roundSize=app.roundSize;                %#ok<NASGU,*ADPROP>
                thisRound=app.thisRound;                %#ok<NASGU,*ADPROP>
                votes=app.votes;                        %#ok<NASGU,*ADPROP>
                roundNum=app.roundNum;                  %#ok<NASGU,*ADPROP>
                imgTargetHeight=app.imgTargetHeight;    %#ok<NASGU,*ADPROP>
                collageRows=app.collageRows;            %#ok<NASGU,*ADPROP>
                collageColumns=app.collageColumns;      %#ok<*ADPROP>
                votingNums=app.votingNums;              %#ok<NASGU,*ADPROP>
                save(sprintf("%s\\save.mat",app.title),"waifus","pastRounds",...
                    "pastVotes","probabilityScale","immunityScale",...
                    "selectivity","roundSize","thisRound","votes",...
                    "roundNum","imgTargetHeight","collageRows",...
                    'collageColumns',"votingNums");
            end
        end
        
        function createNew(app,probability,immunity,select,size,height,width,imageSize,zeroIndex)
            app.probabilityScale=probability;
            app.immunityScale=immunity;
            app.selectivity=select;
            app.roundSize=size;
            app.thisRound=zeros(app.roundSize,1);
            app.votes=zeros(app.roundSize,1);
            app.pastVotes=[];
            app.pastRounds=[];
            app.roundNum=0;
            app.numRounds=0;
            app.roundView=1;
            app.collageRows=height;
            app.collageColumns=width;
            app.imgTargetHeight=imageSize;
            app.votingNums=(1:app.roundSize)-zeroIndex;
            app.waifus=table('Size',[0,2],'VariableTypes',["double","double"],'VariableNames',["Immunity","Probability"]);
            app.displayTable=app.waifus;
            app.loaded=true;
        end
        
        function results = updateVotes(app,~,~,i,field)
            results=field.Value;
            app.votes(i)=results;
        end
        
        function cutoff = getCutoff(app,votesIn)
            cutoff=mean(votesIn(votesIn~=0))+app.selectivity*std(votesIn(votesIn~=0));
        end
        
        function updateOverview(app)
            app.OverviewTable.Data=app.displayTable;
            app.OverviewTable.RowName=app.displayTable.Properties.RowNames;
            app.OverviewTable.ColumnName=app.displayTable.Properties.VariableNames;
            app.OverviewTable.ColumnSortable=[true,true];
            if(app.numRounds ~= app.roundNum)
                app.CalculateRoundButton.Enable='on';
            else
                app.CalculateRoundButton.Enable='off';
            end
            %app.SearchButton.Value=false;
            app.OverviewCountLabel.Text =sprintf("%03.0f Waifus Added",length(app.waifus.Properties.RowNames));
            app.OverviewElimLabel.Text = sprintf("%03.0f Eliminated",sum(app.waifus.Immunity==-1));
            app.OverviewRoundsLabel.Text=sprintf("%1.0f Rounds Run",app.numRounds);
        end
        
        function populateVotes(app)
            app.VotesGridLayout.Visible=false;
            delete(app.VotesGridLayout);
            app.VotesGridLayout = uigridlayout(app.VotesTab,'ColumnWidth',{'5x','1x'},'Scrollable','on');
            app.VotesGridLayout.RowHeight=num2cell(30*ones(1,app.roundSize));
            app.VotesGridLayout.Visible=true;
            for i=1:app.currentRoundSize
                %create label
                label=uilabel(app.VotesGridLayout);
                label.Layout.Column=1;
                label.Layout.Row=i;
                label.Text=app.thisRound(i);
                label.FontSize=24;
                label.HorizontalAlignment='right';
                
                %Create spinner
                spinner=uispinner(app.VotesGridLayout);
                spinner.Limits=[0 Inf];
                spinner.Value=app.votes(i);
                spinner.Layout.Column=2;
                spinner.Layout.Row=i;
                spinner.ValueChangedFcn={@app.updateVotes,i,spinner};
            end
        end
        
        function extant = exists(app,name)
            extant=find(contains(app.waifus.Properties.RowNames,name))~=0;
        end
        
        function [elim,update] = runRound(app,round,votes,roundNum)
            round=round(:);
            votes=votes(:);
            
            valid=round(votes~=0); %Eject all characters not voted for
            votesValid=votes(votes~=0);
            
            center=mean(votesValid);
            dev=std(votesValid);
            cutoff=center+app.selectivity*dev;
            
            safe=valid(votesValid>=cutoff);
            votesValid=votesValid(votesValid>=cutoff);
            elim=setdiff(round,safe);
            immunity=floor(roundNum+(1-app.selectivity)+(votesValid-center)/dev);
            pickChance=1./(app.probabilityScale+votesValid);
            
            update=table(immunity,pickChance,'RowNames',safe,'VariableNames',app.waifus.Properties.VariableNames);
        end
        
        function updateWaifus(app,elimKeys,update)
            app.waifus(elimKeys,:)=table(-1*ones(length(elimKeys),1),zeros(length(elimKeys),1),'VariableNames',app.waifus.Properties.VariableNames,'RowNames',elimKeys);
            app.waifus(update.Properties.RowNames,:)=update;
        end
        
        function [round,size] = generateRound(app)
            %copy over
            pickable=app.waifus;
            
            %exclude Eliminated Waifus from being selected
            pickable=pickable(app.waifus.Immunity ~= -1,:);
            
            %exclude immune from being selected
            pickable=pickable(pickable.Immunity < app.roundNum,:);
            
            %Set Weights
            weights=table2array(pickable(:,'Probability'));
            
            %check if we have enough left
            pickCount=min(length(pickable.Properties.RowNames),app.roundSize);
            %if pickCount>=app.roundSize
            round=string(datasample(pickable.Properties.RowNames,pickCount,'Weights',weights,'Replace',false));
            size=pickCount;
            %else
            %    round=[];
            %    size=0;
            %proceed with fewer
            %round=string(datasample(pickable.Properties.RowNames,pickCount,'Weights',weights,'Replace',false));
            %size=pickCount;
            %end
        end
        
        function img = createImg(app)
            imgNameNum=@(i)sprintf('%s\\icon\\%02.0f.png',app.title,i);
            imgNameWaifu=@(s)sprintf('%s\\img\\%s.png',app.title,s);
            
            img=[];
            longestRow=0;
            for i=1:app.collageRows
                row=[];
                for j=1:app.collageColumns
                    k=(i-1)*app.collageColumns+j;
                    if (k>app.currentRoundSize)
                        break;
                    end
                    iconName=imgNameNum(app.votingNums(k));
                    [iconImg,map]=imread(iconName);
                    iconImg=ind2rgb(iconImg,map);
                    [~,iconImgWidth,~]=size(iconImg);
                    
                    waifuName=imgNameWaifu(app.thisRound(k));
                    [waifuImg,map]=imread(waifuName);
                    if size(waifuImg,3)~=3
                        waifuImg=ind2rgb(waifuImg,map);
                    end
                    [waifuImgHeight,~,~]=size(waifuImg);
                    scaleFactor=app.imgTargetHeight/waifuImgHeight;
                    waifuImgScale=imresize(waifuImg,scaleFactor,'ColorMap','original');
                    waifuImgPad=padarray(waifuImgScale,[0,iconImgWidth,0],255,'pre');
                    
                    imgcat=imfuse(iconImg,waifuImgPad,'blend','Scaling','none');
                    imgtext=insertText(imgcat,[20,app.imgTargetHeight-50],app.thisRound(k),'BoxColor','black',...
                        'BoxOpacity',0.6,'FontSize',36,'TextColor','white');
                    imgtext=imgtext(1:app.imgTargetHeight,:,:);
                    row=[row,imgtext]; %#ok<AGROW>
                end
                rowLen=size(row,2);
                if longestRow==0
                    longestRow=rowLen;
                end
                if(rowLen>longestRow)
                    %pad existing img
                    img=padarray(img,[0,rowLen-longestRow,0],255,'post');
                    longestRow=rowLen;
                else
                    row=padarray(row,[0,longestRow-rowLen,0],255,'post');
                end
                img=[img;row]; %#ok<AGROW>
            end
        end
    end
    
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Button pushed function: LoadButton
        function LoadButtonPushed(app, ~)
            value=app.DatafileEditField.Value;
            if ~isempty(value)
                app.title=value;
                if isfile([value '\\save.mat'])
                    app.WelcomeStatusLabel.Text=sprintf("Loading %s",value);
                    app.loadFromFile();
                    app.WelcomePanel.Visible=false;
                    app.NavigatePanel.Visible=true;
                    app.NavigatePanel.Title=app.title;
                    app.updateOverview();
                else
                    app.WelcomeStatusLabel.Text=sprintf("File '%s' not found. Did you mean to create it?",[value '.mat']);
                end
            else
                app.WelcomeStatusLabel.Text="Please enter a filename";
            end
        end
        
        % Button pushed function: AddConfirmButton
        function AddConfirmButtonPushed(app, ~)
            value=app.AddField.Value;
            if app.AddImportFileButton.Value
                file=[value '.mat'];
                folder=[value '\\save.mat'];
                if isfile(file)
                    loadWaifus=load(file,"waifus");
                    keys=loadWaifus.waifus.Properties.RowNames;
                    app.waifus(keys,:)=array2table([zeros(length(keys),1),ones(length(keys),1)],'RowNames',string(keys),'VariableNames',app.waifus.Properties.VariableNames);
                    app.AddStatusMessageLabel.Text=sprintf('all of %s added or reset.',file);
                elseif isfile(folder)
                    loadWaifus=load(file,"waifus");
                    keys=loadWaifus.waifus.Properties.RowNames;
                    app.waifus(keys,:)=array2table([zeros(length(keys),1),ones(length(keys),1)],'RowNames',string(keys),'VariableNames',app.waifus.Properties.VariableNames);
                    app.AddStatusMessageLabel.Text=sprintf('all of %s added or reset.',file);
                else
                    app.AddStatusMessageLabel.Text=sprintf('files %s and %s not found.',file,folder);
                end
            else
                %load one
                if app.exists(value)
                    app.AddStatusMessageLabel.Text=sprintf('%s already exists.',value);
                else
                    app.waifus(value,:)=array2table([0,1],'RowNames',string(value),"VariableNames",app.waifus.Properties.VariableNames);
                    app.AddStatusMessageLabel.Text=sprintf('%s added.',value);
                end
            end
            
        end
        
        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, ~)
            selectedTab = app.TabGroup.SelectedTab;
            switch selectedTab
                case app.VotesTab
                    if(app.roundNum==0) %no rounds created
                        app.TabGroup.SelectedTab=app.OverviewTab;
                    else
                        %populate votes tab
                        app.populateVotes();
                    end
                case app.OverviewTab
                    %refresh
                    app.updateOverview()
                case app.RoundsTab
                    if(app.roundNum==0) %no rounds created
                        app.TabGroup.SelectedTab=app.OverviewTab;
                    else
                        %refresh
                        RoundsSpinnerValueChanged(app,0);
                        if(app.roundNum>1)
                            app.RoundsSpinner.Limits=[1,(app.roundNum)];
                            app.RoundsSpinner.Enable=true;
                        else
                            app.RoundsSpinner.Enable=false;
                            app.roundView=1;
                        end
                        app.RoundsSpinner.Value=app.roundView;
                    end
                case app.VotingImageTab
                    app.Image.ImageSource = sprintf("%s\\round%01.0f.png",app.title,app.roundNum);
                otherwise
                    %do nothing
            end
        end
        
        % Button pushed function: AddClearButton
        function AddClearButtonPushed(app, ~)
            app.AddStatusMessageLabel.Text="Entry Field Cleared";
            app.AddField.Value="";
            app.AddImportFileButton.Value=false;
        end
        
        % Value changed function: RoundsSpinner
        function RoundsSpinnerValueChanged(app, ~)
            value = app.RoundsSpinner.Value;
            app.roundView = value;
            
            if(app.roundNum==value)
                viewRound=app.thisRound(:);
                viewVotes=app.votes(:);
            else
                viewRound=app.pastRounds(:,value);
                viewVotes=app.pastVotes(:,value);
            end
            
            viewRound=viewRound(viewRound~="");
            viewVotes=viewVotes(viewVotes~=-1);
            
            ax1=app.RoundsUIAxes;
            ax2=app.RoundsUIAxes2;
            
            fill=table(viewVotes,'RowNames',string(viewRound),'VariableNames',"votes");
            app.RoundsUITable.ColumnName=fill.Properties.VariableNames;
            app.RoundsUITable.RowName=fill.Properties.RowNames;
            app.RoundsUITable.Data=fill;
            
            cutoff=app.getCutoff(viewVotes);
            
            bar(ax1,reordercats(categorical(viewRound),viewRound),viewVotes);
            hold(ax1,'on');
            plot(ax1,get(ax1,'xlim'),floor([cutoff,cutoff])+0.5,'LineWidth',2);
            %legend(ax1,'Votes',sprintf('%3.2f',cutoff),'Location','eastoutside')
            hold(ax1,'off');
            
            histogram(ax2,viewVotes,'NumBins',max(viewVotes)+2,'BinEdges',-0.5:max(viewVotes)+0.5);
            hold(ax2,'on');
            plot(ax2,[cutoff,cutoff],get(ax2,'ylim'),'LineWidth',2);
            xticks(ax2,0:max(viewVotes));
            %legend(ax2,'Votes',sprintf('Cutoff (%3.2f)',cutoff),...
            %    'Location','southoutside','NumColumns',2);
            %legend(ax2,'boxoff');
            hold(ax2,'off');
            
            app.RoundsCutoffLabel.Text=sprintf('Cutoff at %3.2f',cutoff);
        end
        
        % Button pushed function: AddRemoveButton
        function AddRemoveButtonPushed(app, ~)
            value=app.AddField.Value;
            if app.AddImportFileButton.Value
                file=[value '.mat'];
                folder=[value '\\save.mat'];
                if isfile(file)
                    loadWaifus=load(file,"waifus");
                    keys=loadWaifus.waifus.Properties.RowNames;
                    app.waifus(keys,:)=[];
                    app.AddStatusMessageLabel.Text=sprintf('all of %s removed.',file);
                elseif isfile(folder)
                    loadWaifus=load(folder,"waifus");
                    keys=loadWaifus.waifus.Properties.RowNames;
                    app.waifus(keys,:)=[];
                    app.AddStatusMessageLabel.Text=sprintf('all of %s removed.',file);
                else
                    app.AddStatusMessageLabel.Text=sprintf('files %s and %s not found.',file,folder);
                end
            else
                if app.exists(value)
                    app.waifus(value,:)=[];
                    app.AddStatusMessageLabel.Text=sprintf('%s removed.',value);
                else
                    app.AddStatusMessageLabel.Text=sprintf('%s not found.',value);
                end
            end
        end
        
        % Callback function: SaveandExitButton, UIFigure
        function UIFigureCloseRequest(app, ~)
            app.saveToFile();
            delete(app);
        end
        
        % Button pushed function: NewButton
        function NewButtonPushed(app, ~)
            value=app.DatafileEditField.Value;
            if ~isempty(value)
                if ~isfile([value '.mat'])
                    app.title=value;
                    app.CreateTitle.Text=sprintf("Create %s",value);
                    app.WelcomePanel.Visible=false;
                    app.CreatePanel.Visible=true;
                else
                    app.WelcomeStatusLabel.Text=sprintf("File '%s' Exists. Did you mean to load it?",[value '.mat']);
                end
            else
                app.WelcomeStatusLabel.Text="Please enter a filename";
            end
        end
        
        % Button pushed function: CreateButton
        function CreateButtonPushed(app, ~)
            app.createNew(app.ProbabilityScaleEditField.Value,...
                app.ImmunityScaleEditField.Value,...
                app.SelectivityEditField.Value,app.RoundSizeSpinner.Value,...
                app.CollageHeightSpinner.Value,app.CollageWidthSpinner.Value,...
                app.ImageHeightSpinner.Value,app.ZeroIndexButton.Value);
            app.CreatePanel.Visible=false;
            app.NavigatePanel.Visible=true;
        end
        
        % Button pushed function: CalculateRoundButton
        function CalculateRoundButtonPushed(app, ~)
            if(app.numRounds ~= app.roundNum)
                app.numRounds=app.roundNum;
                app.pastRounds=[app.pastRounds,[app.thisRound(:);randsample("",app.roundSize-app.currentRoundSize,true)]];
                app.pastVotes=[app.pastVotes,[app.votes(:);-1*ones(app.roundSize-app.currentRoundSize,1)]];
            end
            [elim,update]=app.runRound(app.thisRound,app.votes,app.roundNum);
            app.updateWaifus(elim,update);
            app.updateOverview();
        end
        
        % Button pushed function: GenerateNewButton
        function GenerateNewButtonPushed(app, ~)
            app.roundNum=app.numRounds+1;
            [app.thisRound,app.currentRoundSize]=app.generateRound;
            app.votes=zeros(app.currentRoundSize,1);
        end
        
        % Button pushed function: SaveButton
        function SaveButtonPushed(app, ~)
            app.saveToFile();
        end
        
        % Button pushed function: GenerateImageButton
        function GenerateImageButtonPushed(app, ~)
            img=app.createImg();
            imwrite(img,sprintf("%s\\round%01.0f.png",app.title,app.roundNum))
            app.Image.ImageSource=img;
        end
        
        % Value changed function: CollageHeightSpinner,
        % CollageWidthSpinner
        function CollageWidthSpinnerValueChanged(app, ~)
            width = app.CollageWidthSpinner.Value;
            height = app.CollageHeightSpinner.Value;
            res=app.RoundSizeSpinner.Value;
            if(width*height<res)
                app.CreateButton.Enable=false;
            else
                app.CreateButton.Enable=true;
            end
            
        end
        
        % Value changed function: AddImportFileButton
        function SearchValueChanged(app, ~)
            value = app.SearchButton.Value;
            if value
                search = string(app.SearchbyNameEditField.Value);
                names=string(app.waifus.Properties.RowNames);
                inds = contains(names, search,'IgnoreCase',true);
                rows=names(inds);
                app.displayTable=app.waifus(rows,:);
            else
                app.displayTable=app.waifus;
            end
            app.updateOverview();
        end
        
        %function SearchValueChanged(app,event)
        %    app.SearchButton.Value=false;
        %end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 500 500];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            
            % Create LargeGridLayout
            app.LargeGridLayout=uigridlayout(app.UIFigure);
            app.LargeGridLayout.ColumnWidth={'1x'};
            app.LargeGridLayout.RowHeight={'1x'};
            app.LargeGridLayout.Padding=0;
            
            % Create WelcomePanel
            %app.WelcomePanel = uipanel(app.UIFigure);
            app.WelcomePanel = uipanel(app.LargeGridLayout);
            app.WelcomePanel.Title = 'Welcome';
            %app.WelcomePanel.Position = [0 0 500 500];
            app.WelcomePanel.Layout.Column=1;
            app.WelcomePanel.Layout.Row=1;
            
            % Create WelcomeGridLayout
            app.WelcomeGridLayout = uigridlayout(app.WelcomePanel);
            app.WelcomeGridLayout.ColumnWidth = {'1x'};
            app.WelcomeGridLayout.RowHeight = {'2x', '1x', '1x', '0.5x', '1x'};
            
            % Create WaifuRatingLabel
            app.WaifuRatingLabel = uilabel(app.WelcomeGridLayout);
            app.WaifuRatingLabel.HorizontalAlignment = 'center';
            app.WaifuRatingLabel.FontSize = 36;
            app.WaifuRatingLabel.Layout.Row = 1;
            app.WaifuRatingLabel.Layout.Column = 1;
            app.WaifuRatingLabel.Text = 'Waifu Rating';
            
            % Create DatafileEditField
            app.DatafileEditField = uieditfield(app.WelcomeGridLayout, 'text');
            app.DatafileEditField.FontSize = 18;
            app.DatafileEditField.Layout.Row = 2;
            app.DatafileEditField.Layout.Column = 1;
            
            % Create LoadButton
            app.LoadButton = uibutton(app.WelcomeGridLayout, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Layout.Row = 3;
            app.LoadButton.Layout.Column = 1;
            app.LoadButton.Text = 'Load';
            
            % Create NewButton
            app.NewButton = uibutton(app.WelcomeGridLayout, 'push');
            app.NewButton.ButtonPushedFcn = createCallbackFcn(app, @NewButtonPushed, true);
            app.NewButton.Layout.Row = 5;
            app.NewButton.Layout.Column = 1;
            app.NewButton.Text = 'New';
            
            % Create WelcomeStatusLabel
            app.WelcomeStatusLabel = uilabel(app.WelcomeGridLayout);
            app.WelcomeStatusLabel.HorizontalAlignment = 'center';
            app.WelcomeStatusLabel.Layout.Row = 4;
            app.WelcomeStatusLabel.Layout.Column = 1;
            app.WelcomeStatusLabel.Text = '';
            
            % Create NavigatePanel
            %app.NavigatePanel = uipanel(app.UIFigure);
            app.NavigatePanel = uipanel(app.LargeGridLayout);
            app.NavigatePanel.Title = 'Navigate';
            app.NavigatePanel.Visible = 'off';
            %app.NavigatePanel.Position = [0 0 500 500];
            app.NavigatePanel.Layout.Row=1;
            app.NavigatePanel.Layout.Column=1;
            
            % Create NavigateGridLayout
            app.NavigateGridLayout=uigridlayout(app.NavigatePanel);
            app.NavigateGridLayout.ColumnWidth={'1x'};
            app.NavigateGridLayout.RowHeight={'1x'};
            app.NavigateGridLayout.Padding = 0;
            
            % Create TabGroup
            app.TabGroup = uitabgroup(app.NavigateGridLayout);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            %app.TabGroup.Position = [0 0 500 480];
            app.TabGroup.Layout.Column=1;
            app.TabGroup.Layout.Row=1;
            
            % Create OverviewTab
            app.OverviewTab = uitab(app.TabGroup);
            app.OverviewTab.Title = 'Overview';
            
            %Create OverviewGridLayout
            app.OverviewGridLayout=uigridlayout(app.OverviewTab);
            app.OverviewGridLayout.ColumnWidth={'1x',100};
            app.OverviewGridLayout.RowHeight={25,25,25,25,'1x',15,15,15,25,25};
            
            % Create SearchbyNameEditFieldLabel
            %app.SearchbyNameEditFieldLabel = uilabel(app.UIFigure);
            %app.SearchbyNameEditFieldLabel.HorizontalAlignment = 'center';
            %app.SearchbyNameEditFieldLabel.Enable = 'off';
            %app.SearchbyNameEditFieldLabel.Position = [168 516 95 25];
            %app.SearchbyNameEditFieldLabel.Text = 'Search by Name';
            
            % Create SearchbyNameEditField
            app.SearchbyNameEditField = uieditfield(app.OverviewGridLayout, 'text');
            app.SearchbyNameEditField.ValueChangedFcn = createCallbackFcn(app, @SearchValueChanged, true);
            %app.SearchbyNameEditField.ValueChangingFcn = createCallbackFcn(app, @SearchValueChanged, true);
            %app.SearchbyNameEditField.Editable = 'off';
            %app.SearchbyNameEditField.Enable = 'off';
            app.SearchbyNameEditField.Layout.Row = 1;
            app.SearchbyNameEditField.Layout.Column = 1;
            
            % Create SearchButton
            app.SearchButton = uibutton(app.OverviewGridLayout, 'state');
            app.SearchButton.Layout.Row = 1;
            app.SearchButton.Layout.Column = 2;
            app.SearchButton.ValueChangedFcn = createCallbackFcn(app, @SearchValueChanged, true);
            app.SearchButton.Text = 'Search';
            
            % Create CalculateRoundButton
            app.CalculateRoundButton = uibutton(app.OverviewGridLayout, 'push');
            app.CalculateRoundButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateRoundButtonPushed, true);
            app.CalculateRoundButton.Layout.Row = 2;
            app.CalculateRoundButton.Layout.Column = 2;
            app.CalculateRoundButton.Text = 'Calculate Round';
            
            % Create OverviewRoundsLabel
            app.OverviewRoundsLabel = uilabel(app.OverviewGridLayout);
            app.OverviewRoundsLabel.HorizontalAlignment = 'center';
            app.OverviewRoundsLabel.Layout.Row = 6;
            app.OverviewRoundsLabel.Layout.Column = 2;
            app.OverviewRoundsLabel.Text = 'Rounds';
            
            % Create OverviewCountLabel
            app.OverviewCountLabel = uilabel(app.OverviewGridLayout);
            app.OverviewCountLabel.HorizontalAlignment = 'center';
            app.OverviewCountLabel.Layout.Row = 7;
            app.OverviewCountLabel.Layout.Column = 2;
            app.OverviewCountLabel.Text = 'Waifus';
            
            % Create OverviewElimLabel
            app.OverviewElimLabel = uilabel(app.OverviewGridLayout);
            app.OverviewElimLabel.HorizontalAlignment = 'center';
            app.OverviewElimLabel.Layout.Row = 8;
            app.OverviewElimLabel.Layout.Column = 2;
            app.OverviewElimLabel.Text = 'Eliminated';
            
            
            % Create GenerateNewButton
            app.GenerateNewButton = uibutton(app.OverviewGridLayout, 'push');
            app.GenerateNewButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateNewButtonPushed, true);
            app.GenerateNewButton.Layout.Row = 3;
            app.GenerateNewButton.Layout.Column = 2;
            app.GenerateNewButton.Text = 'Generate New';
            
            % Create GenerateImageButton
            app.GenerateImageButton = uibutton(app.OverviewGridLayout, 'push');
            app.GenerateImageButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateImageButtonPushed, true);
            app.GenerateImageButton.Layout.Row = 4;
            app.GenerateImageButton.Layout.Column = 2;
            app.GenerateImageButton.Text = 'Generate Image';
            
            % Create SaveButton
            app.SaveButton = uibutton(app.OverviewGridLayout, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Layout.Row = 9;
            app.SaveButton.Layout.Column = 2;
            app.SaveButton.Text = 'Save';
            
            % Create SaveandExitButton
            app.SaveandExitButton = uibutton(app.OverviewGridLayout, 'push');
            app.SaveandExitButton.ButtonPushedFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.SaveandExitButton.Layout.Row = 10;
            app.SaveandExitButton.Layout.Column=2;
            app.SaveandExitButton.Text = 'Save and Exit';
            
            % Create OverviewTable
            app.OverviewTable = uitable(app.OverviewGridLayout);
            app.OverviewTable.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'};
            app.OverviewTable.RowName = {'Row A'; ' Row B'; ' Row C'};
            app.OverviewTable.Layout.Row = [2 10];
            app.OverviewTable.Layout.Column = 1;
            
            % Create AddRemoveTab
            app.AddRemoveTab = uitab(app.TabGroup);
            app.AddRemoveTab.Title = 'Add/Remove';
            
            % Create AddGridLayout
            app.AddGridLayout = uigridlayout(app.AddRemoveTab);
            app.AddGridLayout.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.AddGridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            
            % Create AddField
            app.AddField = uieditfield(app.AddGridLayout, 'text');
            app.AddField.FontSize = 36;
            app.AddField.Layout.Row = 3;
            app.AddField.Layout.Column = [1 4];
            
            % Create AddStatusMessageLabel
            app.AddStatusMessageLabel = uilabel(app.AddGridLayout);
            app.AddStatusMessageLabel.HorizontalAlignment = 'center';
            app.AddStatusMessageLabel.FontSize = 24;
            app.AddStatusMessageLabel.Layout.Row = 4;
            app.AddStatusMessageLabel.Layout.Column = [1 4];
            app.AddStatusMessageLabel.Text = 'Enter Name';
            
            % Create AddConfirmButton
            app.AddConfirmButton = uibutton(app.AddGridLayout, 'push');
            app.AddConfirmButton.ButtonPushedFcn = createCallbackFcn(app, @AddConfirmButtonPushed, true);
            app.AddConfirmButton.Layout.Row = 5;
            app.AddConfirmButton.Layout.Column = 4;
            app.AddConfirmButton.Text = 'Add';
            
            % Create AddRemoveButton
            app.AddRemoveButton = uibutton(app.AddGridLayout, 'push');
            app.AddRemoveButton.ButtonPushedFcn = createCallbackFcn(app, @AddRemoveButtonPushed, true);
            app.AddRemoveButton.Layout.Row = 5;
            app.AddRemoveButton.Layout.Column = 3;
            app.AddRemoveButton.Text = 'Remove';
            
            % Create AddClearButton
            app.AddClearButton = uibutton(app.AddGridLayout, 'push');
            app.AddClearButton.ButtonPushedFcn = createCallbackFcn(app, @AddClearButtonPushed, true);
            app.AddClearButton.Layout.Row = 5;
            app.AddClearButton.Layout.Column = 1;
            app.AddClearButton.Text = 'Clear';
            
            % Create AddImportFileButton
            app.AddImportFileButton = uibutton(app.AddGridLayout, 'state');
            app.AddImportFileButton.Text = {'Import File'; '[toggle]'};
            app.AddImportFileButton.Layout.Row = 5;
            app.AddImportFileButton.Layout.Column = 2;
            
            % Create VotesTab
            app.VotesTab = uitab(app.TabGroup);
            app.VotesTab.Title = 'Votes';
            
            % Create VotesGridLayout
            app.VotesGridLayout = uigridlayout(app.VotesTab);
            app.VotesGridLayout.ColumnWidth = {'5x', '1x'};
            app.VotesGridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.VotesGridLayout.Scrollable = 'on';
            
            % Create RoundsTab
            app.RoundsTab = uitab(app.TabGroup);
            app.RoundsTab.Title = 'Rounds';
            
            % Create RoundsGridLayout
            app.RoundsGridLayout = uigridlayout(app.RoundsTab);
            app.RoundsGridLayout.RowHeight = {'3x', '3x', '0.5x', '1x'};
            
            % Create RoundsUITable
            app.RoundsUITable = uitable(app.RoundsGridLayout);
            app.RoundsUITable.ColumnName = {'Column 1';};
            app.RoundsUITable.RowName = {};
            app.RoundsUITable.Layout.Row = [1 4];
            app.RoundsUITable.Layout.Column = 1;
            
            % Create RoundsSpinner
            app.RoundsSpinner = uispinner(app.RoundsGridLayout);
            app.RoundsSpinner.Limits = [1 Inf];
            app.RoundsSpinner.ValueChangedFcn = createCallbackFcn(app, @RoundsSpinnerValueChanged, true);
            app.RoundsSpinner.HorizontalAlignment = 'center';
            app.RoundsSpinner.FontSize = 36;
            app.RoundsSpinner.Layout.Row = 4;
            app.RoundsSpinner.Layout.Column = 2;
            app.RoundsSpinner.Value = 1;
            
            % Create RoundsUIAxes
            app.RoundsUIAxes = uiaxes(app.RoundsGridLayout);
            title(app.RoundsUIAxes, 'Votes')
            xlabel(app.RoundsUIAxes, '')
            ylabel(app.RoundsUIAxes, 'Votes')
            %app.RoundsUIAxes.PlotBoxAspectRatio = [1.453125 1 1];
            app.RoundsUIAxes.Layout.Row = 1;
            app.RoundsUIAxes.Layout.Column = 2;
            
            % Create RoundsUIAxes2
            app.RoundsUIAxes2 = uiaxes(app.RoundsGridLayout);
            title(app.RoundsUIAxes2, 'Distribution')
            xlabel(app.RoundsUIAxes2, 'Votes')
            ylabel(app.RoundsUIAxes2, 'Number')
            %app.RoundsUIAxes2.PlotBoxAspectRatio = [1.453125 1 1];
            app.RoundsUIAxes2.Layout.Row = 2;
            app.RoundsUIAxes2.Layout.Column = 2;
            
            %Create RoundsCutoffLabel
            app.RoundsCutoffLabel = uilabel(app.RoundsGridLayout);
            app.RoundsCutoffLabel.Layout.Row = 3;
            app.RoundsCutoffLabel.Layout.Column = 2;
            app.RoundsCutoffLabel.Text = "Cutoff";
            app.RoundsCutoffLabel.HorizontalAlignment = 'center';
            
            % Create VotingImageTab
            app.VotingImageTab = uitab(app.TabGroup);
            app.VotingImageTab.Title = 'VotingImage';
            
            % Create ImageGridLayout
            app.ImageGridLayout = uigridlayout(app.VotingImageTab);
            app.ImageGridLayout.ColumnWidth = {'1x'};
            app.ImageGridLayout.RowHeight = {'1x'};
            
            % Create Image
            app.Image = uiimage(app.ImageGridLayout);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;
            
            % Create CreatePanel
            app.CreatePanel = uipanel(app.UIFigure);
            app.CreatePanel.Title = 'Create';
            app.CreatePanel.Visible = 'off';
            app.CreatePanel.Position = [0 0 500 500];
            
            % Create CreateGridLayout
            app.CreateGridLayout = uigridlayout(app.CreatePanel);
            app.CreateGridLayout.ColumnWidth = {'4x', '1x'};
            app.CreateGridLayout.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            
            % Create ProbabilityScaleEditFieldLabel
            app.ProbabilityScaleEditFieldLabel = uilabel(app.CreateGridLayout);
            app.ProbabilityScaleEditFieldLabel.HorizontalAlignment = 'right';
            app.ProbabilityScaleEditFieldLabel.Layout.Row = 2;
            app.ProbabilityScaleEditFieldLabel.Layout.Column = 1;
            app.ProbabilityScaleEditFieldLabel.Text = 'Probability Scale';
            
            % Create ProbabilityScaleEditField
            app.ProbabilityScaleEditField = uieditfield(app.CreateGridLayout, 'numeric');
            app.ProbabilityScaleEditField.Limits = [0 Inf];
            app.ProbabilityScaleEditField.Tooltip = {'Offset for choice Probability after surviving a round'; ''; 'default:2'; ''; 'probability=1/(probability_scale+votes)'};
            app.ProbabilityScaleEditField.Layout.Row = 2;
            app.ProbabilityScaleEditField.Layout.Column = 2;
            app.ProbabilityScaleEditField.Value = 2;
            
            % Create ImmunityScaleEditFieldLabel
            app.ImmunityScaleEditFieldLabel = uilabel(app.CreateGridLayout);
            app.ImmunityScaleEditFieldLabel.HorizontalAlignment = 'right';
            app.ImmunityScaleEditFieldLabel.Layout.Row = 3;
            app.ImmunityScaleEditFieldLabel.Layout.Column = 1;
            app.ImmunityScaleEditFieldLabel.Text = 'Immunity Scale';
            
            % Create ImmunityScaleEditField
            app.ImmunityScaleEditField = uieditfield(app.CreateGridLayout, 'numeric');
            app.ImmunityScaleEditField.Limits = [0 Inf];
            app.ImmunityScaleEditField.Tooltip = {'Coefficient for length of Immunity after surviving a round'; ''; 'default:1'; ''; 'Immunity_Length=floor(1+Immunity_Scale*Stdev_above_elimination)'};
            app.ImmunityScaleEditField.Layout.Row = 3;
            app.ImmunityScaleEditField.Layout.Column = 2;
            app.ImmunityScaleEditField.Value = 1;
            
            % Create SelectivityEditFieldLabel
            app.SelectivityEditFieldLabel = uilabel(app.CreateGridLayout);
            app.SelectivityEditFieldLabel.HorizontalAlignment = 'right';
            app.SelectivityEditFieldLabel.Layout.Row = 4;
            app.SelectivityEditFieldLabel.Layout.Column = 1;
            app.SelectivityEditFieldLabel.Text = 'Selectivity';
            
            % Create SelectivityEditField
            app.SelectivityEditField = uieditfield(app.CreateGridLayout, 'numeric');
            app.SelectivityEditField.Tooltip = {'Number of Standard Deviations above the mean number of votes to avoid elimination each round'; ''; 'default:-1'; ''; 'eliminate_below=mean+selectivity*stdev'};
            app.SelectivityEditField.Layout.Row = 4;
            app.SelectivityEditField.Layout.Column = 2;
            app.SelectivityEditField.Value = -1;
            
            % Create RoundSizeSpinnerLabel
            app.RoundSizeSpinnerLabel = uilabel(app.CreateGridLayout);
            app.RoundSizeSpinnerLabel.HorizontalAlignment = 'right';
            app.RoundSizeSpinnerLabel.Layout.Row = 5;
            app.RoundSizeSpinnerLabel.Layout.Column = 1;
            app.RoundSizeSpinnerLabel.Text = 'Round Size';
            
            % Create RoundSizeSpinner
            app.RoundSizeSpinner = uispinner(app.CreateGridLayout);
            app.RoundSizeSpinner.Limits = [1 Inf];
            app.RoundSizeSpinner.Tooltip = {'How Many Waifus appear in a round'; ''; 'default:10'};
            app.RoundSizeSpinner.Layout.Row = 5;
            app.RoundSizeSpinner.Layout.Column = 2;
            app.RoundSizeSpinner.Value = 10;
            
            % Create CollageWidthSpinnerLabel
            app.CollageWidthSpinnerLabel = uilabel(app.CreateGridLayout);
            app.CollageWidthSpinnerLabel.HorizontalAlignment = 'right';
            app.CollageWidthSpinnerLabel.Layout.Row = 6;
            app.CollageWidthSpinnerLabel.Layout.Column = 1;
            app.CollageWidthSpinnerLabel.Text = 'Collage Width';
            
            % Create CollageWidthSpinner
            app.CollageWidthSpinner = uispinner(app.CreateGridLayout);
            app.CollageWidthSpinner.Limits = [1 Inf];
            app.CollageWidthSpinner.ValueChangedFcn = createCallbackFcn(app, @CollageWidthSpinnerValueChanged, true);
            app.CollageWidthSpinner.Tooltip = {'How Many Images to include side-by-side in one row of the Collage'; ''; 'default:5'};
            app.CollageWidthSpinner.Layout.Row = 6;
            app.CollageWidthSpinner.Layout.Column = 2;
            app.CollageWidthSpinner.Value = 5;
            
            % Create CollageHeightSpinnerLabel
            app.CollageHeightSpinnerLabel = uilabel(app.CreateGridLayout);
            app.CollageHeightSpinnerLabel.HorizontalAlignment = 'right';
            app.CollageHeightSpinnerLabel.Layout.Row = 7;
            app.CollageHeightSpinnerLabel.Layout.Column = 1;
            app.CollageHeightSpinnerLabel.Text = 'Collage Height';
            
            % Create CollageHeightSpinner
            app.CollageHeightSpinner = uispinner(app.CreateGridLayout);
            app.CollageHeightSpinner.Limits = [1 Inf];
            app.CollageHeightSpinner.ValueChangedFcn = createCallbackFcn(app, @CollageWidthSpinnerValueChanged, true);
            app.CollageHeightSpinner.Tooltip = {'How Many Rows of Images to Include Vertically in the Collage'; ''; 'default:2'};
            app.CollageHeightSpinner.Layout.Row = 7;
            app.CollageHeightSpinner.Layout.Column = 2;
            app.CollageHeightSpinner.Value = 2;
            
            % Create ImageHeightSpinnerLabel
            app.ImageHeightSpinnerLabel = uilabel(app.CreateGridLayout);
            app.ImageHeightSpinnerLabel.HorizontalAlignment = 'right';
            app.ImageHeightSpinnerLabel.Layout.Row = 8;
            app.ImageHeightSpinnerLabel.Layout.Column = 1;
            app.ImageHeightSpinnerLabel.Text = 'Image Height';
            
            % Create ImageHeightSpinner
            app.ImageHeightSpinner = uispinner(app.CreateGridLayout);
            app.ImageHeightSpinner.Step = 20;
            app.ImageHeightSpinner.Tooltip = {'How High Each image in the Collage should be'; ''; 'default: 800'};
            app.ImageHeightSpinner.Layout.Row = 8;
            app.ImageHeightSpinner.Layout.Column = 2;
            app.ImageHeightSpinner.Value = 800;
            
            % Create IndexFromZeroLabel
            app.IndexFromZeroLabel = uilabel(app.CreateGridLayout);
            app.IndexFromZeroLabel.HorizontalAlignment = 'right';
            app.IndexFromZeroLabel.Tooltip = {'Index Icon Values starting at Zero'; ''; 'default: false'};
            app.IndexFromZeroLabel.Layout.Row = 9;
            app.IndexFromZeroLabel.Layout.Column = 1;
            app.IndexFromZeroLabel.Text = 'Index From Zero';
            
            % Create ZeroIndexButton
            app.ZeroIndexButton = uibutton(app.CreateGridLayout, 'state');
            app.ZeroIndexButton.Text = 'Zero Index';
            app.ZeroIndexButton.Layout.Row = 9;
            app.ZeroIndexButton.Layout.Column = 2;
            
            % Create CreateTitle
            app.CreateTitle = uilabel(app.CreateGridLayout);
            app.CreateTitle.HorizontalAlignment = 'center';
            app.CreateTitle.FontSize = 36;
            app.CreateTitle.Layout.Row = 1;
            app.CreateTitle.Layout.Column = [1 2];
            app.CreateTitle.Text = 'Create New';
            
            % Create CreateButton
            app.CreateButton = uibutton(app.CreateGridLayout, 'push');
            app.CreateButton.ButtonPushedFcn = createCallbackFcn(app, @CreateButtonPushed, true);
            app.CreateButton.Layout.Row = 10;
            app.CreateButton.Layout.Column = 2;
            app.CreateButton.Text = 'Create';
            
            % Create CreateWarningLabel
            app.CreateWarningLabel = uilabel(app.CreateGridLayout);
            app.CreateWarningLabel.HorizontalAlignment = 'center';
            app.CreateWarningLabel.FontSize = 18;
            app.CreateWarningLabel.Layout.Row = 10;
            app.CreateWarningLabel.Layout.Column = 1;
            app.CreateWarningLabel.Text = 'No values defined here can be changed later';
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = WaifuSelector
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
