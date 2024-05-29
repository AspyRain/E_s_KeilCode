#ifndef DATA_STRUCTURE_H
#define DATA_STRUCTURE_H

#include <stdint.h>


typedef struct {
    int h;
    int m;
    int s;
} Time;


typedef struct {
    int year;
    int month;
    int day;
} Date;

// 结构体表示每个计划
typedef struct {
    int id;
    int device;
    Time time;  // 假设时间是字符串，以便于处理
    int duration;
    Date beginDate;
    Date endDate;
} Plan;

// 结构体表示每个记录
typedef struct {
    int plans;
    int device;
} Record;

// 主结构体，包含计划和记录

typedef struct {
    Plan* plans;
    Record* records;
} DataStructure;

// 函数声明
void setDate(Date *date,int year,int month,int day);
void setTime(Time *time,int h,int m,int s);
Date* newDate(int year,int month,int day);
Time* newTime(int h,int m,int s);

#endif /* DATA_STRUCTURE_H */
