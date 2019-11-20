#include "mex.h" /* Always include this */
#include <math.h>
#include "matrix.h"


void mexFunction(int nlhs, mxArray *plhs[], /* Output variables */
                 int nrhs, const mxArray *prhs[]) /* Input variables */
{
#define ccr(ai,bi,ci) (ccr[ai+Nss[0]*(bi+Nss[1]*ci)])
#define cci(ai,bi,ci) (cci[ai+Nss[0]*(bi+Nss[1]*ci)])
#define kk1(ai,bi,ci) (kk1[ai+Nss[0]*(bi+Nss[1]*ci)])
#define kk2(ai,bi,ci) (kk2[ai+Nss[0]*(bi+Nss[1]*ci)])
#define kb(loc1,loc2,ai,bi) kb[loc1+NB1*(loc2+NB2*(ai+Nss[0]*bi))]
#define avgdx(loc1,loc2,ai,bi) avgdx[loc1+NB1*(loc2+NB2*(ai+Nss[0]*bi))]
#define avgdy(loc1,loc2,ai,bi) avgdy[loc1+NB1*(loc2+NB2*(ai+Nss[0]*bi))]
    
    size_t ai, bi, ci;
    int NB1, NB2, loc1, loc2, di = 0;
    double *kk1, *kk2, *ccr, *cci, *kb, *avgdx, *avgdy;
    double EXT, num_dir, da, dr, r, agl, R_low;
    double temp_energy;
    ccr = mxGetPr(prhs[0]);
    cci = mxGetPi(prhs[0]);
    kk1 = mxGetPr(prhs[1]);
    kk2 = mxGetPr(prhs[2]);
    EXT = mxGetScalar(prhs[3]);
    num_dir = mxGetScalar(prhs[4]);
    da = mxGetScalar(prhs[5]);
    dr = mxGetScalar(prhs[6]);
    NB1 = mxGetScalar(prhs[7]);
    NB2 = mxGetScalar(prhs[8]);
    R_low = mxGetScalar(prhs[9]);
    const mwSize *Nss = mxGetDimensions(prhs[0]);
    nrhs = 10;
    
    nlhs = 3;
    int ndim = 4, dims[4] = {NB1,NB2,Nss[0],Nss[1]};
    plhs[0] = mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS,mxREAL);
    kb = mxGetPr(plhs[0]);
    plhs[1] = mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS,mxREAL);
    avgdx = mxGetPr(plhs[1]);
    plhs[2] = mxCreateNumericArray(ndim,dims,mxDOUBLE_CLASS,mxREAL);
    avgdy = mxGetPr(plhs[2]);
    
    for (ai=0;ai<Nss[0];ai++) {
        for (bi=0;bi<Nss[1];bi++) {
            for (ci=0;ci<Nss[2];ci++) {
                if (kk1(ai,bi,ci)<EXT) {
                    r = sqrt(kk1(ai,bi,ci)*kk1(ai,bi,ci)+kk2(ai,bi,ci)*kk2(ai,bi,ci));
                    if (kk1(ai,bi,ci)>=0) {
                        agl = fmod(acos(kk2(ai,bi,ci)/r),num_dir);
                    }
                    else
                        agl = fmod(3.1415926-acos(kk2(ai,bi,ci)/r),num_dir);
                    loc1 = round((r-R_low)/dr);
                    loc2 = round(agl/da);
                    
                    temp_energy = ccr(ai,bi,ci)*ccr(ai,bi,ci) + cci(ai,bi,ci)*cci(ai,bi,ci);
                    if (0){
                        if (loc2==0){
                            if (kk1(ai,bi,ci)>=0) {
                                kb(loc1,loc2,ai,bi) = kb(loc1,loc2,ai,bi) + temp_energy;
                                avgdx(loc1,loc2,ai,bi) = avgdx(loc1,loc2,ai,bi) + r * cos(agl) * temp_energy;
                                avgdy(loc1,loc2,ai,bi) = avgdy(loc1,loc2,ai,bi) + r * sin(agl) * temp_energy;
                            }
                            else{
                                kb(loc1,NB2-1,ai,bi) = kb(loc1,NB2-1,ai,bi) + temp_energy;
                                avgdx(loc1,NB2-1,ai,bi) = avgdx(loc1,NB2-1,ai,bi) - r * cos(agl) * temp_energy;
                                avgdy(loc1,NB2-1,ai,bi) = avgdy(loc1,NB2-1,ai,bi) + r * sin(agl) * temp_energy;
                            }
                        }else if (loc2==NB2-1){
                            if (kk1(ai,bi,ci)>=0) {
                                kb(loc1,loc2,ai,bi) = kb(loc1,loc2,ai,bi) + temp_energy;
                                avgdx(loc1,loc2,ai,bi) = avgdx(loc1,loc2,ai,bi) + r * cos(agl) * temp_energy;
                                avgdy(loc1,loc2,ai,bi) = avgdy(loc1,loc2,ai,bi) + r * sin(agl) * temp_energy;
                            }
                            else{
                                avgdx(loc1,0,ai,bi) = avgdx(loc1,0,ai,bi) - r * cos(agl) * temp_energy;
                                kb(loc1,0,ai,bi) = kb(loc1,0,ai,bi) + temp_energy;
                                avgdy(loc1,0,ai,bi) = avgdy(loc1,0,ai,bi) + r * sin(agl) * temp_energy;
                            }
                        }else{
                            kb(loc1,loc2,ai,bi) = kb(loc1,loc2,ai,bi) + temp_energy;
                            avgdx(loc1,loc2,ai,bi) = avgdx(loc1,loc2,ai,bi) + r * cos(agl) * temp_energy;
                            avgdy(loc1,loc2,ai,bi) = avgdy(loc1,loc2,ai,bi) + r * sin(agl) * temp_energy;
                        }
                    }
                    else{
                        kb(loc1,loc2,ai,bi) = kb(loc1,loc2,ai,bi) + temp_energy;
                        avgdx(loc1,loc2,ai,bi) = avgdx(loc1,loc2,ai,bi) + r * cos(agl) * temp_energy;
                        avgdy(loc1,loc2,ai,bi) = avgdy(loc1,loc2,ai,bi) + r * sin(agl) * temp_energy;
                        /* cannot use kk since those are symmetric */
                    }
                }
            }
        }
    }
    
    return;
}
