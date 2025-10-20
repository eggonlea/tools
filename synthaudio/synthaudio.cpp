/*
 * Copyright (C) 2011 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Synthetic workload designed to model AudioFlinger and AudioTrack

#include <signal.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sched.h>
#include <sys/resource.h>

#define ATRACE_TAG ATRACE_TAG_AUDIO
#include <utils/Trace.h>

static struct timespec previous;
static int count = 0;
#define MAX_COUNT 10000
static struct timespec delta_ts[MAX_COUNT];
//#define PERIOD_NS 2902494   // 128 frames at 44.1 kHz
//#define PERIOD_NS 5804988   // 256 frames at 44.1 kHz
//#define PERIOD_NS 5333333   // 256 frames at 48 kHz
#define PERIOD_NS  10666666   // 512 frames at 48 kHz

int compar(const void *p, const void *q)
{
    const struct timespec *ts_p = (const struct timespec *) p;
    const struct timespec *ts_q = (const struct timespec *) q;
    if (ts_p->tv_sec < ts_q->tv_sec)
        return -1;
    else if (ts_p->tv_sec > ts_q->tv_sec)
        return 1;
    else
        return ts_p->tv_nsec - ts_q->tv_nsec;
}

#ifdef USE_TIMER
void notify_function(union sigval sv)
{
    int ok;
    struct timespec ts;
    //write(1, ".", 1);
    if (count == 0) {
        printf("notify_function: getpid()=%d, gettid()=%d\n", getpid(), gettid());
        ok = sched_getscheduler(gettid());
        printf("scheduler = %d\n", ok);
    }
    if (count < MAX_COUNT) {
        ok = clock_gettime(CLOCK_MONOTONIC, &ts);
        if (0 == ok) {
            unsigned delta_sec = ts.tv_sec - previous.tv_sec;
            int delta_ns = ts.tv_nsec - previous.tv_nsec;
            if (delta_ns < 0) {
                delta_ns += 1000000000;
                --delta_sec;
            }
            struct timespec delta_x;
            delta_x.tv_sec = delta_sec;
            delta_x.tv_nsec = delta_ns;
            delta_ts[count++] = delta_x;
            previous = ts;
            ATRACE_INT("cycle_us", delta_ns / 1000);
        }
    }
}
#endif

#define PRIORITY 2 // was 1

int main(int argc, char **argv __unused)
{
    printf("main: getpid()=%d, gettid()=%d\n", getpid(), gettid());
    int ok;
    bool fifo = argc == 1;
    if (fifo) {
        struct sched_param param;
        param.sched_priority = PRIORITY;
        ok = sched_setscheduler(gettid(), SCHED_FIFO, &param);
        printf("sched_setscheduler = %d\n", ok);
    } else {
        ok = setpriority(PRIO_PROCESS, 0 /* self */, -19);
        printf("setpriority = %d\n", ok);
    }
#ifdef USE_TIMER
    timer_t timerid;
    struct sigevent ev;
#endif
    clockid_t clockid;
    clockid = CLOCK_MONOTONIC;
#ifdef USE_TIMER
    ev.sigev_notify = SIGEV_THREAD;
    ev.sigev_signo = 0;
    ev.sigev_value.sival_int = 0;
    ev.sigev_notify_function = notify_function;
    ev.sigev_notify_attributes = NULL;
    //ev.sigev_notify_thread_id = 0;
    ok = timer_create(clockid, &ev, &timerid);
    //printf("timer_create ok=%d, timerid=%p\n", ok, timerid);
#endif
    ok = clock_gettime(CLOCK_MONOTONIC, &previous);
    //printf("clock_gettime ok=%d\n", ok);
#ifdef USE_TIMER
    int flags = 0;
    struct itimerspec new_;
    struct itimerspec old;
    new_.it_interval.tv_sec = 0;
    new_.it_interval.tv_nsec = PERIOD_NS;
    new_.it_value.tv_sec = 0;
    new_.it_value.tv_nsec = PERIOD_NS;
#endif
    int seconds = (int) (((long long) PERIOD_NS * (long long) MAX_COUNT) / 1000000000LL);
    printf("please wait %d seconds\n", seconds);
#ifdef USE_TIMER
    ok = timer_settime(timerid, flags, &new_, &old);
    //printf("timer_settime ok=%d\n", ok);
    sleep(seconds + 1);
    ok = timer_delete(timerid);
    //printf("\ntimer_delete ok=%d\n", ok);
#else
    struct timespec delay;
    delay.tv_sec = 0;
    delay.tv_nsec = PERIOD_NS;
    for (count = 0; count < MAX_COUNT; ++count) {
        {
        android::ScopedTrace(ATRACE_TAG, "nanosleep");
        nanosleep(&delay, NULL);
        }
        struct timespec ts;
        {
        android::ScopedTrace(ATRACE_TAG, "clock_gettime");
        ok = clock_gettime(CLOCK_MONOTONIC, &ts);
        }
        if (0 == ok) {
            unsigned delta_sec = ts.tv_sec - previous.tv_sec;
            int delta_ns = ts.tv_nsec - previous.tv_nsec;
            if (delta_ns < 0) {
                delta_ns += 1000000000;
                --delta_sec;
            }
            struct timespec delta_x;
            delta_x.tv_sec = delta_sec;
            delta_x.tv_nsec = delta_ns;
            delta_ts[count] = delta_x;
            previous = ts;
            ATRACE_INT("cycle_us", delta_ns / 1000);
        }
    }
#endif
    printf("expected samples: %d, actual samples: %d\n", MAX_COUNT, count);
    qsort(delta_ts, count, sizeof(struct timespec), compar);
#if 0
    int i;
    for (i = 0; i < count; ++i) {
        printf("delta ts [%2d] = %lu.%09lu\n", i, delta_ts[i].tv_sec, delta_ts[i].tv_nsec);
    }
#endif
    printf("99.8%% CDF, ideal is all ~%d ns:\n", PERIOD_NS);
    int i;
    for (i = (count * 998) / 1000; i < count; ++i) {
        printf("%lu.%09lu", delta_ts[i].tv_sec, delta_ts[i].tv_nsec);
#if 0
        printf(" secs %.3f", (i * 100.0) / count);
#endif
        printf("\n");
    }
    return EXIT_SUCCESS;
}
