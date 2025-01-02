/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class SchedulerBase implements System.Schedulable {
    global bdrs.SchedulerBase.Interval interval {
        get;
        set;
    }
    global SchedulerBase() {

    }
    global virtual void execute(System.SchedulableContext sc) {

    }
    global virtual void executeBusiness() {

    }
    global void process() {

    }
    global void restart() {

    }
    global void setInstance(bdrs.SchedulerBase instanceObject) {

    }
    global void setInstance(bdrs.SchedulerBase instanceObject, Boolean allowsQueueable) {

    }
    global void start() {

    }
    global void stop() {

    }
global class Interval {
    global Boolean absoluteHourAlways {
        get;
        set;
    }
    global Boolean businessDaysOnly {
        get;
        set;
    }
    global String customExpression {
        get;
        set;
    }
    global List<Integer> fixedDays {
        get;
        set;
    }
    global List<Integer> fixedHours {
        get;
        set;
    }
    global Integer fixedMinute {
        get;
        set;
    }
    global Integer hours {
        get;
        set;
    }
    global Integer minutes {
        get;
        set;
    }
    global Interval() {

    }
}
}
