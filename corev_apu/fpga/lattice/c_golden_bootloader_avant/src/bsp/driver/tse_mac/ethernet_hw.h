#ifndef _ETHERNET_HW_H_
#define _ETHERNET_HW_H_

#include "reg_access.h"
#include <stdio.h>

#define TX_STAT_UNICST                           0x04C
#define TX_STAT_MULTCST                          0x054
#define TX_STAT_BRDCST                           0x05C
#define TX_STAT_BADFCS                           0x064
#define TX_STAT_JMBO                             0x06C
#define TX_STAT_UNDER_RUN                        0x074
#define TX_STAT_PAUSE                            0x07C
#define TX_STAT_VLN_TG                           0x084
#define TX_STAT_FRM_LNGTH                        0x08C
#define TX_STAT_DEFERRED_TRANS                   0x094
#define TX_STAT_EXCESSIVE_DEFERRED_TRANS         0x09C
#define TX_STAT_LATE_COL                         0x0A4
#define TX_STAT_EXCESSIVE_COL                    0x0AC
#define TX_STAT_NUM_EARLY_COL                    0x0B4
#define TX_STAT_SHRT_FRM_DIS_FCS                 0x0BC
#define TX_STAT_PTP1588_FRM                      0x0C4
#define TX_STAT_FRM_64                           0x0CC
#define TX_STAT_FRM_65_127                       0x0D4
#define TX_STAT_FRM_128_255                      0x0DC
#define TX_STAT_FRM_256_511                      0x0E4
#define TX_STAT_FRM_512_1023                     0x0EC
#define TX_STAT_FRM_1024_1518                    0x0F4
#define TX_STAT_FRM_1519_2047                    0x0FC
#define TX_STAT_FRM_2048_4095                    0x104
#define TX_STAT_FRM_4096_9216                    0x10C
#define TX_STAT_FRM_9217_16383                   0x114
#define RX_STAT_FRM_LNGTH                        0x11C
#define RX_STAT_VLN_TG                           0x124
#define RX_STAT_PAUSE                            0x12C
#define RX_STAT_CTRL                             0x134
#define RX_STAT_UNSP_OPCODE                      0x13C
#define RX_STAT_DRIBB_NIBB                       0x144
#define RX_STAT_BRDCST                           0x14C
#define RX_STAT_MULTCST                          0x154
#define RX_STAT_UNICST                           0x15C
#define RX_STAT_RCVD_OK                          0x164
#define RX_STAT_LNGTH_ERR                        0x16C
#define RX_STAT_CRC_ERR                          0x174
#define RX_STAT_PKT_IGNORE                       0x17C
#define RX_STAT_PREVIOUS_CARRIER_EVENT           0x184
#define RX_STAT_PTP1588_FRM                      0x18C
#define RX_STAT_IPG_VIOL                         0x194
#define RX_STAT_SHRT_FRM                         0x19C
#define RX_STAT_LNG_FRM                          0x1A4
#define RX_STAT_FRM_UNDERSIZE                    0x1AC
#define RX_STAT_FRM_FRAGMENTS                    0x1B4
#define RX_STAT_FRM_JABBER                       0x1BC
#define RX_STAT_FRM_64_GOOD_CRC                  0x1C4
#define RX_STAT_FRM_1518_GOOD_CRC                0x1CC
#define RX_STAT_FRM_64                           0x1D4
#define RX_STAT_FRM_65_127                       0x1DC
#define RX_STAT_FRM_128_255                      0x1E4
#define RX_STAT_FRM_256_511                      0x1EC
#define RX_STAT_FRM_512_1023                     0x1F4
#define RX_STAT_FRM_1024_1518                    0x1FC
#define RX_STAT_FRM_1519_2047                    0x204
#define RX_STAT_FRM_2048_4095                    0x20C
#define RX_STAT_FRM_4096_9216                    0x214
#define RX_STAT_FRM_9217_16383                   0x21C


#define ethernet_reg_name_str(Offset) \
    (((Offset) == TX_STAT_UNICST)                   ? "TX_STAT_UNICST"                      : \
    ((Offset) == TX_STAT_MULTCST)                   ? "TX_STAT_MULTCST"                     : \
    ((Offset) == TX_STAT_BRDCST)                    ? "TX_STAT_BRDCST"                      : \
    ((Offset) == TX_STAT_BADFCS)                    ? "TX_STAT_BADFCS"                      : \
    ((Offset) == TX_STAT_JMBO)                      ? "TX_STAT_JMBO"                        : \
    ((Offset) == TX_STAT_UNDER_RUN)                 ? "TX_STAT_UNDER_RUN"                   : \
    ((Offset) == TX_STAT_PAUSE)                     ? "TX_STAT_PAUSE"                       : \
    ((Offset) == TX_STAT_VLN_TG)                    ? "TX_STAT_VLN_TG"                      : \
    ((Offset) == TX_STAT_FRM_LNGTH)                 ? "TX_STAT_FRM_LNGTH"                   : \
    ((Offset) == TX_STAT_DEFERRED_TRANS)            ? "TX_STAT_DEFERRED_TRANS"              : \
    ((Offset) == TX_STAT_EXCESSIVE_DEFERRED_TRANS)  ? "TX_STAT_EXCESSIVE_DEFERRED_TRANS"    : \
    ((Offset) == TX_STAT_LATE_COL)                  ? "TX_STAT_LATE_COL"                    : \
    ((Offset) == TX_STAT_EXCESSIVE_COL)             ? "TX_STAT_EXCESSIVE_COL"               : \
    ((Offset) == TX_STAT_NUM_EARLY_COL)             ? "TX_STAT_NUM_EARLY_COL"               : \
    ((Offset) == TX_STAT_SHRT_FRM_DIS_FCS)          ? "TX_STAT_SHRT_FRM_DIS_FCS"            : \
    ((Offset) == TX_STAT_PTP1588_FRM)               ? "TX_STAT_PTP1588_FRM"                 : \
    ((Offset) == TX_STAT_FRM_64)                    ? "TX_STAT_FRM_64"                      : \
    ((Offset) == TX_STAT_FRM_65_127)                ? "TX_STAT_FRM_65_127"                  : \
    ((Offset) == TX_STAT_FRM_128_255)               ? "TX_STAT_FRM_128_255"                 : \
    ((Offset) == TX_STAT_FRM_256_511)               ? "TX_STAT_FRM_256_511"                 : \
    ((Offset) == TX_STAT_FRM_512_1023)              ? "TX_STAT_FRM_512_1023"                : \
    ((Offset) == TX_STAT_FRM_1024_1518)             ? "TX_STAT_FRM_1024_1518"               : \
    ((Offset) == TX_STAT_FRM_1519_2047)             ? "TX_STAT_FRM_1519_2047"               : \
    ((Offset) == TX_STAT_FRM_2048_4095)             ? "TX_STAT_FRM_2048_4095"               : \
    ((Offset) == TX_STAT_FRM_4096_9216)             ? "TX_STAT_FRM_4096_9216"               : \
    ((Offset) == TX_STAT_FRM_9217_16383)            ? "TX_STAT_FRM_9217_16383"              : \
    ((Offset) == RX_STAT_FRM_LNGTH)                 ? "RX_STAT_FRM_LNGTH"                   : \
    ((Offset) == RX_STAT_VLN_TG)                    ? "RX_STAT_VLN_TG"                      : \
    ((Offset) == RX_STAT_PAUSE)                     ? "RX_STAT_PAUSE"                       : \
    ((Offset) == RX_STAT_CTRL)                      ? "RX_STAT_CTRL"                        : \
    ((Offset) == RX_STAT_UNSP_OPCODE)               ? "RX_STAT_UNSP_OPCODE"                 : \
    ((Offset) == RX_STAT_DRIBB_NIBB)                ? "RX_STAT_DRIBB_NIBB"                  : \
    ((Offset) == RX_STAT_BRDCST)                    ? "RX_STAT_BRDCST"                      : \
    ((Offset) == RX_STAT_MULTCST)                   ? "RX_STAT_MULTCST"                     : \
    ((Offset) == RX_STAT_UNICST)                    ? "RX_STAT_UNICST"                      : \
    ((Offset) == RX_STAT_RCVD_OK)                   ? "RX_STAT_RCVD_OK"                     : \
    ((Offset) == RX_STAT_LNGTH_ERR)                 ? "RX_STAT_LNGTH_ERR"                   : \
    ((Offset) == RX_STAT_CRC_ERR)                   ? "RX_STAT_CRC_ERR"                     : \
    ((Offset) == RX_STAT_PKT_IGNORE)                ? "RX_STAT_PKT_IGNORE"                  : \
    ((Offset) == RX_STAT_PREVIOUS_CARRIER_EVENT)    ? "RX_STAT_PREVIOUS_CARRIER_EVENT"      : \
    ((Offset) == RX_STAT_PTP1588_FRM)               ? "RX_STAT_PTP1588_FRM"                 : \
    ((Offset) == RX_STAT_IPG_VIOL)                  ? "RX_STAT_IPG_VIOL"                    : \
    ((Offset) == RX_STAT_SHRT_FRM)                  ? "RX_STAT_SHRT_FRM"                    : \
    ((Offset) == RX_STAT_LNG_FRM)                   ? "RX_STAT_LNG_FRM"                     : \
    ((Offset) == RX_STAT_FRM_UNDERSIZE)             ? "RX_STAT_FRM_UNDERSIZE"               : \
    ((Offset) == RX_STAT_FRM_FRAGMENTS)             ? "RX_STAT_FRM_FRAGMENTS"               : \
    ((Offset) == RX_STAT_FRM_JABBER)                ? "RX_STAT_FRM_JABBER"                  : \
    ((Offset) == RX_STAT_FRM_64_GOOD_CRC)           ? "RX_STAT_FRM_64_GOOD_CRC"             : \
    ((Offset) == RX_STAT_FRM_1518_GOOD_CRC)         ? "RX_STAT_FRM_1518_GOOD_CRC"           : \
    ((Offset) == RX_STAT_FRM_64)                    ? "RX_STAT_FRM_64"                      : \
    ((Offset) == RX_STAT_FRM_65_127)                ? "RX_STAT_FRM_65_127"                  : \
    ((Offset) == RX_STAT_FRM_128_255)               ? "RX_STAT_FRM_128_255"                 : \
    ((Offset) == RX_STAT_FRM_256_511)               ? "RX_STAT_FRM_256_511"                 : \
    ((Offset) == RX_STAT_FRM_512_1023)              ? "RX_STAT_FRM_512_1023"                : \
    ((Offset) == RX_STAT_FRM_1024_1518)             ? "RX_STAT_FRM_1024_1518"               : \
    ((Offset) == RX_STAT_FRM_1519_2047)             ? "RX_STAT_FRM_1519_2047"               : \
    ((Offset) == RX_STAT_FRM_2048_4095)             ? "RX_STAT_FRM_2048_4095"               : \
    ((Offset) == RX_STAT_FRM_4096_9216)             ? "RX_STAT_FRM_4096_9216"               : \
    ((Offset) == RX_STAT_FRM_9217_16383)            ? "RX_STAT_FRM_9217_16383"              : \
    "unknown")

static unsigned long long ethernet_get_statstic_counter(unsigned int base_addr, unsigned int offset)
{
    unsigned int val_lo = 0;
    unsigned int val_hi = 0;
    unsigned long long val = 0;
    reg_32b_read(base_addr + offset, &val_lo);
    reg_32b_read(base_addr + offset + 4, &val_hi);
    val = ((unsigned long long)val_hi) << 32 + val_lo;

    return val;
}

static void ethernet_print_statstic_counter(unsigned int base_addr, unsigned int offset)
{
    unsigned long long val = ethernet_get_statstic_counter(base_addr, offset);

    printf("statics_counters %s = %16x\r\n", ethernet_reg_name_str(offset), val);
}

static void ethernet_print_all_statstics_counters(unsigned int base_addr)
{
    int i = TX_STAT_UNICST;
    for (i = TX_STAT_UNICST; i <= RX_STAT_FRM_9217_16383; i + 8)
    {
    	ethernet_print_statstic_counter(base_addr, i);
    }
}

#endif
