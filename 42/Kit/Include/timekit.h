#ifndef __TIMEKIT_H__
#define __TIMEKIT_H__

#include <math.h>
#if defined _USE_SYSTEM_TIME_
   #if defined(_WIN32)
      #include <Windows.h>
   #elif defined(__APPLE__)
//      #include <CoreServices/Timer.h> /* For Microseconds high-precision timer */
   #endif
   #include <time.h>
   #ifndef _WIN32
      #include <sys/time.h>
   #endif
#endif

//#ifdef __cplusplus
//namespace Kit {
//#endif

double AbsTimeToJD(double AbsTime);
double JDToAbsTime(double JD);
double DateToAbsTime(long Year, long Month, long Day, long Hour,
   long Minute, double Second);
double YMDHMS2JD(long Year, long Month, long Day,
               long Hour, long Minute, double Second);
void JD2YMDHMS(double JD,long *Year, long *Month, long *Day,
                         long *Hour, long *Minute, double *Second);
long MD2DOY(long Year, long Month, long Day);
void DOY2MD(long Year, long DayOfYear, long *Month, long *Day);
double JD2GMST(double JD);
void DAY2HMS(double *DAY, double *HOUR, double *MINUTE, double *SECOND,
             double DTSIM);
double usec(void);
void RealSystemTime(long *Year, long *DOY, long *Month, long *Day,
                   long *Hour, long *Minute, double *Second);
double RealRunTime(double *RealTimeDT);

//#ifdef __cplusplus
//}
//#endif

#endif /* __TIMEKIT_H__ */
