#include "data_structure.h"
#include <stdlib.h>

// 初始化结构体数据
void setDate(Date *date, int year, int month, int day) {
    date->year = year;
    date->month = month;
    date->day = day;
}

void setTime(Time *time, int h, int m, int s) {
    time->h = h;
    time->m = m;
    time->s = s;
}

Date* newDate(int year, int month, int day) {
    Date *date = (Date*)malloc(sizeof(Date));
    if (date != NULL) {
        setDate(date, year, month, day);
    }
    return date;
}

Time* newTime(int h, int m, int s) {
    Time *time = (Time*)malloc(sizeof(Time));
    if (time != NULL) {
        setTime(time, h, m, s);
    }
    return time;
}
