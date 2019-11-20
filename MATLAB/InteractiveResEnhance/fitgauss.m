function err = fitgauss(lambda,t,y,handle)%	Fitting function for gaussian, lambda(1)=position, lambda(2)=width%	Fitgauss assumes a gaussian function %  T. C. O'Haver, 1998. Revised for Matlab 6, March 2006global cA= gaussian(t,lambda(1),lambda(2));c = A\y;z = A*c;err = norm(z-y);