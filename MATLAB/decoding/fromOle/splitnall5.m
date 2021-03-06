function splitnall 
% function splitnall 

load pos
load ttheta

tmin = [1.00e4 1.02e4 1.04e4 1.06e4 1.08e4]; 
tmax = [1.02e4 1.04e4 1.06e4 1.08e4 1.10e4]; 
  
for div=1:4:5   
    for i=1:5 
        fname = strcat('nalla',num2str(i))  ;
        fname = strcat(fname,'d') ;  
        fname = strcat(fname,num2str(div))  
        nall = buildplacefield(p,ttheta,div,tmin(i),tmax(i));
        nall = filtplacefields(nall); 
        save(fname,'nall'); 
    end
end
