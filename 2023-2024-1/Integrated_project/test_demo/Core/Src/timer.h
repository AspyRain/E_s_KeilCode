#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>
#include <stdlib.h>
#include "data_structure.h"

typedef struct
{
    Time *time;
    Date *date;
    Plan *plans;
} Timer;

extern Timer *timerData;  

int timerInit(Date *now_date, Time *now_time, Plan *now_plan);
void setTimerAll(Date *now_date, Time *now_time, Plan *now_plan);
void setTimerDate(Date *now_date);
void setTimerTime(Time *now_time);
void setTimerPlan(Plan *now_plans);
Date *getTimerDate();
Time *getTimerTime();
int timerRun(int deviceNum,int* device_status);
int isTimeReached(const Plan *plan);

#endif /* TIMER_H */
