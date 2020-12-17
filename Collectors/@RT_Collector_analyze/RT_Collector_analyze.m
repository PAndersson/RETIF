
classdef RT_Collector_analyze < RT_Collector
    
    properties
        dumpdirectory % directory where data arrives
        check_timer % timer object
        force_order = false; %Does new volume needs to have subsequent number?
                             %If 'true', it's possible to run offline with
                             %all images pre-placed in dumpdirectory.
        nametemplate = '$$$.hdr'; %template for name of nifti files.
                                  %Needs to end with e.g. '$$$.nii' for the numbering
                                  %where each $ is one digit.
                                  %OBS! No other '$'s are allowed in the
                                  %template.
        numlength = 3;
        
        GUI_tic %for logging
        logfp % logfile
    end
    
    methods
        %Constructor
        function C = RT_Collector_analyze(input)

            C.dumpdirectory = input{1};
            if ~strcmp(C.dumpdirectory(end),'\')
                C.dumpdirectory(end+1) = '\';
            end
            
            C.nrdummy = input{2};
            
            C.nametemplate = input{3};
            temp = strfind(C.nametemplate, '$');
            C.numlength = length(temp);
            C.nametemplate =  C.nametemplate(1:temp-1);
            
            C.force_order = input{4};
            
            C.latest_dynnr = 0;
            C.data = [];
            C.check_timer = timer('StartDelay', 0,'Period', 0.1,'TasksToExecute', 50000,...
                'ExecutionMode','fixedRate','TimerFcn',{@RT_Collector_analyze.receiver,C});
        end
        
        function delete(C)
            delete(timerfindall);%OBS!! deletes ALL timer instances
        end
        
        function start(C)
            start(C.check_timer);
        end
        
        function stop(C)
            stop(C.check_timer);
        end
        
        function send(C,filename)
            
            %             start(C.check_timer);
            disp(filename);
            
            %Read new file into data
            newdata = load_nii([C.dumpdirectory,'\',filename]);
            C.data = single(newdata.img);
            notify(C,'NewData');
            
        end % send
        
    end %methods
        
    methods (Static)
        function receiver(tmr,tmrfnc,C)
            
            temp = 0;
            if C.force_order
                
                eval(['nr = sprintf(''%0' num2str(C.numlength) 'd'',C.latest_dynnr + C.nrdummy + 1);']);
                files = dir([C.dumpdirectory,C.nametemplate,nr,'.hdr']);
                
                if ~isempty(files)
  
                    C.stop();
                    %write to log%%%%%%%%
                    if ~isempty(C.logfp) && ~isempty(C.GUI_tic) 
                         temp = toc(C.GUI_tic);
                         fprintf(C.logfp,'Found\t%s\t%f\n',files.name,temp);
                    end
                    %%%%%%%%%%%%
                    C.latest_dynnr = C.latest_dynnr + 1;
                    pause(0.1);
                    C.send(files.name);
                end                
                
            else
                
                files = dir([C.dumpdirectory,C.nametemplate,'*.hdr']);
                
                if ~isempty(files)
                    temp = str2double(files(end).name(end-3-C.numlength:end-4));
                    temp = temp - C.nrdummy;
                end
                
                if temp>C.latest_dynnr
                    C.stop();
                    C.latest_dynnr = temp;
                    pause(0.1);
                    C.send(files(end).name);
                end
                
                
            end
                

        end % receive
        
        
    end % methods
    
end % classdef