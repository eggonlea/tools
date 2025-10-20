#include <stdlib.h>
#include <stdio.h>

#define LOG(args...) fprintf(stderr, args)

#pragma pack(push)  /* push current alignment to stack */
#pragma pack(1)     /* set alignment to 1 byte boundary */
 
typedef struct my_packed_data
{
    char char1;
    float fdata[4];
    char char2;
} my_packed_data_t;
 
int main()
{
    my_packed_data_t unalignedData;
    my_packed_data_t *p;
    void *pp = malloc(128);
    LOG("zhhe-camera2: unaligned data ptr = %p, sizeof = %d\n", &unalignedData, sizeof(my_packed_data_t));
    LOG("zhhe-camera2: unaligned data ptr = %p, sizeof = %d\n", &unalignedData.char1, sizeof(my_packed_data_t));
    LOG("zhhe-camera2: unaligned data ptr = %p, sizeof = %d\n", unalignedData.fdata, sizeof(my_packed_data_t));
    LOG("zhhe-camera2: unaligned data ptr = %p, sizeof = %d\n", &(unalignedData.fdata[0]), sizeof(my_packed_data_t));
    LOG("zhhe-camera2: unaligned data ptr = %p, sizeof = %d\n", &unalignedData.char2, sizeof(my_packed_data_t));

    unalignedData.char1 = 'A';
//    unalignedData.fdata[0] = 1;
//    unalignedData.fdata[1] = 2;
//    unalignedData.fdata[2] = 3;
//    unalignedData.fdata[3] = 4;
    unalignedData.char2 = 'B';
    p = &unalignedData;
    LOG("*pp+1 = %f\n", *((float *) (((int)pp) + 1)));

    float test0 = p->fdata[0]; // Works fine here
    float test1 = p->fdata[1];
    LOG("zhhe-camera2: unaligned data fdata0 = %d, fdata1 = %d, test0 = %f, test1 = %f\n", unalignedData.fdata[0], unalignedData.fdata[0], test0, test1);
    LOG("zhhe-camera2: unaligned data fdata2 = %d, fdata3 = %d, test0 = %f, test1 = %f\n", unalignedData.fdata[2], unalignedData.fdata[3], unalignedData.fdata[2], unalignedData.fdata[3]);
    LOG("zhhe-camera2: unaligned data char1 = %d, char2 = %d\n", unalignedData.char1, unalignedData.char2);

    return 0;
}

