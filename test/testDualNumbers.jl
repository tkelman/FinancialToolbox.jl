using Base.Test
using FinancialModule

print_with_color(:green,"Starting Dual Numbers Test\n")

#Test Parameters
testToll=1e-14;
spot=10;K=10;r=0.02;T=2.0;sigma=0.2;d=0.01;

#EuropeanCall Option
PriceCall=blsprice(spot,K,r,T,sigma,d);
DeltaCall=blsdelta(spot,K,r,T,sigma,d);
ThetaCall=blstheta(spot,K,r,T,sigma,d);
RhoCall=blsrho(spot,K,r,T,sigma,d);
SigmaCall=blsimpv(spot, K, r, T, PriceCall, d);

#EuropeanPut Option
PricePut=blsprice(spot,K,r,T,sigma,d,false);
DeltaPut=blsdelta(spot,K,r,T,sigma,d,false);
ThetaPut=blstheta(spot,K,r,T,sigma,d,false);
RhoPut=blsrho(spot,K,r,T,sigma,d,false);
SigmaPut=blsimpv(spot, K, r, T, PricePut, d,false);

#Equals for both Options
Gamma=blsgamma(spot,K,r,T,sigma,d);
Vega=blsvega(spot,K,r,T,sigma,d);

########DUAL NUMBERS
using DualNumbers;
DerToll=1e-13;
#Function definition
#Call
FcallDual(spot)=blsprice(spot,K,r,T,sigma,d);
GcallDual(r)=blsprice(spot,K,r,T,sigma,d);
HcallDual(T)=blsprice(spot,K,r,T,sigma,d);
LcallDual(sigma)=blsprice(spot,K,r,T,sigma,d);
#Put
FputDual(spot)=blsprice(spot,K,r,T,sigma,d,false);
GputDual(r)=blsprice(spot,K,r,T,sigma,d,false);
HputDual(T)=blsprice(spot,K,r,T,sigma,d,false);
#Input
sspot=dual(spot,1.0);
rr=dual(r,1.0);
TT=dual(T,1.0);
ssigma=dual(sigma,1.0);

#Automatic Differentiation Test
#TEST
print_with_color(:yellow,"--- European Call Sensitivities: DualNumbers\n")
print_with_color(:blue,"-----Testing Delta\n");
@test(abs(FcallDual(sspot).epsilon-DeltaCall)<DerToll)
print_with_color(:blue,"-----Testing Rho\n");
@test(abs(GcallDual(rr).epsilon-RhoCall)<DerToll)
print_with_color(:blue,"-----Testing Theta\n");
@test(abs(-HcallDual(TT).epsilon-ThetaCall)<DerToll)

#TEST
print_with_color(:yellow,"--- European Put Sensitivities: DualNumbers\n")
print_with_color(:blue,"-----Testing Delta\n");
@test(abs(FputDual(sspot).epsilon-DeltaPut)<DerToll)
print_with_color(:blue,"-----Testing Rho\n");
@test(abs(GputDual(rr).epsilon-RhoPut)<DerToll)
print_with_color(:blue,"-----Testing Theta\n");
@test(abs(-HputDual(TT).epsilon-ThetaPut)<DerToll)

print_with_color(:blue,"-----Testing Vega\n");
@test(abs(LcallDual(ssigma).epsilon-Vega)<DerToll)
print_with_color(:green,"Dual Numbers Test Passed\n")
println("")

#TEST OF INPUT VALIDATION
print_with_color(:magenta,"Starting Input Validation Test Dual\n")
print_with_color(:cyan,"----Testing Negative  Spot Price \n")
@test_throws(ErrorException, blsprice(-sspot,K,r,T,sigma,d))
@test_throws(ErrorException, blsdelta(-sspot,K,r,T,sigma,d))
@test_throws(ErrorException, blsgamma(-sspot,K,r,T,sigma,d))
@test_throws(ErrorException, blstheta(-sspot,K,r,T,sigma,d))
@test_throws(ErrorException, blsrho(-sspot,K,r,T,sigma,d))
@test_throws(ErrorException, blsvega(-sspot,K,r,T,sigma,d))

print_with_color(:cyan,"----Testing Negative  Strike Price \n")
KK=Dual(K,0);
@test_throws(ErrorException, blsprice(spot,-KK,r,T,sigma,d))
@test_throws(ErrorException, blsdelta(spot,-KK,r,T,sigma,d))
@test_throws(ErrorException, blsgamma(spot,-KK,r,T,sigma,d))
@test_throws(ErrorException, blstheta(spot,-KK,r,T,sigma,d))
@test_throws(ErrorException, blsrho(spot,-KK,r,T,sigma,d))
@test_throws(ErrorException, blsvega(spot,-KK,r,T,sigma,d))

print_with_color(:cyan,"----Testing Negative  Time to Maturity \n")
@test_throws(ErrorException, blsprice(spot,K,r,-TT,sigma,d))
@test_throws(ErrorException, blsdelta(spot,K,r,-TT,sigma,d))
@test_throws(ErrorException, blsgamma(spot,K,r,-TT,sigma,d))
@test_throws(ErrorException, blstheta(spot,K,r,-TT,sigma,d))
@test_throws(ErrorException, blsrho(spot,K,r,-TT,sigma,d))
@test_throws(ErrorException, blsvega(spot,K,r,-TT,sigma,d))

print_with_color(:cyan,"----Testing Negative  Volatility \n")
@test_throws(ErrorException, blsprice(spot,K,r,T,-ssigma,d))
@test_throws(ErrorException, blsdelta(spot,K,r,T,-ssigma,d))
@test_throws(ErrorException, blsgamma(spot,K,r,T,-ssigma,d))
@test_throws(ErrorException, blstheta(spot,K,r,T,-ssigma,d))
@test_throws(ErrorException, blsrho(spot,K,r,T,-ssigma,d))
@test_throws(ErrorException, blsvega(spot,K,r,T,-ssigma,d))

print_with_color(:magenta,"Dual Input Validation Test Passed\n")