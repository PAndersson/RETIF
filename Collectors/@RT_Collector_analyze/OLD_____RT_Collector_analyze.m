
classdef RT_Collector_analyze < RT_Collector
    
    properties
        dumpdirectory % directory where data arrives
        check_timer % timer object
    end
    
    methods
        %Constructor
        function C = RT_Collector_analyze(input)
            C.dumpdirectory = input{1};
            C.nrdummy = input{2};
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
            
            %Read new Analyze file into data
            newdata = load_nii([C.dumpdirectory,'\',filename]);
            C.data = single(newdata.img);
            notify(C,'NewData');
            
        end % send
        
    end %methods
        
    methods (Static)
        function receiver(tmr,tmrfnc,C)
            
            files = dir([C.dumpdirectory,'\*.hdr']);
            
            temp = 0;
            if ~isempty(files)
                temp = str2double(files(end).name(end-7:end-4));
                temp = temp - C.nrdummy;
            end
            
            if temp>C.latest_dynnr
                C.stop();
                C.latest_dynnr = temp;
                pause(0.1);
                C.send(files(end).name);
            end
        end % receive
        
        
    end % methods
    
end % classdef