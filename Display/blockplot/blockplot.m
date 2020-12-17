function blockplot(instructions,varargin) 
%makes graphical representation of a block design
%
% blockplot(instructions, [plotlim,sfreq])
% 
% 'instructions': a vector with values, each representing 
% one timepoint and its task. 
%
% 'plotlim': (optional,default [-5,5]) the YLim of the plotted bars 
%
%
% 'sfreq': (optional, default 1) the sampling frequency
%
% Ex. instructions = [0 0 0 1 1 1 5 5 8 8 8 8 1 1 1 1 5 5 0 0 0]
%     have 4 types of tasks represented by 0,1,5 and 8.
%     Therefore blockplot(instructions) will show 4 colors.
%

if nargin==2
    temp = varargin{1};
    if length(temp)==1
        plotlim_up = temp;
        plotlim_down = -temp;
    elseif length(temp)==2
        plotlim_up = temp(2);
        plotlim_down = temp(1);        
    end
    sfreq = 1;
elseif nargin==3
    temp = varargin{1};
    if length(temp)==1
        plotlim_up = temp;
        plotlim_down = -temp;
    elseif length(temp)==2
        plotlim_up = temp(2);
        plotlim_down = temp(1);
    end
    temp = varargin{1};
    sfreq = varargin{2};
else
    plotlim_up = 5;
    plotlim_down = -5;
    sfreq = 1;
end
    
    colororder = [0     1     0;
                  1     0     0;
                  0     0.75  0.75;
                  0.75  0     0.75;
                  0.75  0.75  0;
                  0.25  0.25  0.25;
                  0     0     1;
                  0.75  0.75  0.75;
                  0.25  0.75  0;
                  0     0.25  0.75;
                  0.25  0     0.75;
                  0.75  0     0.25]*0.7;

    instructions = instructions(:);
    
    diff = instructions - [instructions(2:end) ; instructions(end)];
    
    diff = [1 ; find(diff)+1 ; length(instructions)];
    
    types = unique(instructions);
    types(types==0) = [];
    
    xmatrix = cell(length(types),1);
    ymatrix = cell(length(types),1);
    for n = 1:length(types)
        xmatrix{n} = [];
        ymatrix{n} = [];
    end
    
    for k = 1:length(diff)-1
        ct = find(instructions(diff(k)) == types);
        if ~isempty(ct)
            xmatrix{ct} = [xmatrix{ct} [diff(k) diff(k) diff(k+1) diff(k+1)]/sfreq];
            ymatrix{ct} = [ymatrix{ct} plotlim_down plotlim_up plotlim_up plotlim_down];
        end
    end

    hold on
    for n = 1:length(types)
        area(xmatrix{n},ymatrix{n},'basev',plotlim_down,'FaceC',colororder(n,:));
    end 
    hold off
    
    %axis([1 length(instructions) -3 3]);

end