
classdef RT_Connector_COM2char < RT_Connector
    
    properties
        separator % (optional) char to insert as separation
        portname % serial port specification
        porth % handle to port object
    end
    
    methods
        %Constructor
        function C = RT_Collector_COM2char(portname,separator)
            C.portname = portname;
            C.separator = separator;
        end
        
        function C = connect(C)  
            C.porth = serial(C.portname);
            fopen(C.porth);
        end
        
        function disconnect(C)
            fclose(C.porth);
            delete(C.porth);
        end

        function send(C,out)
            if ischar(out)
                fprintf(C.porth, [out(1) C.separator out(2)],'async'); 
            else
                fprintf(C.porth, [num2str(out(1)) C.separator num2str(out(2))],'async');    
            end
        end
        
    end % methods
    
    
    
    
    
end % classdef