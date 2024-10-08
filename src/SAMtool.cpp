#define TMB_LIB_INIT R_init_SAMtool
#include <TMB.hpp>
#include "../inst/include/functions.hpp"

template<class Type>
Type objective_function<Type>::operator() ()
{
  DATA_STRING(model);
  if(model == "DD") {
    return DD(this);
  } else if(model =="SP") {
    return SP(this);
  } else if(model == "SCA") {
    return SCA(this);
  } else if(model == "VPA") {
    return VPA(this);
  } else if(model == "cDD") {
    return cDD(this);
  } else if(model == "RCM") {
    return RCM(this);
  }
  return 0;
}


