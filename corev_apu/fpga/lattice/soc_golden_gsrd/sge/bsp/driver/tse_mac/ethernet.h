/*   ==================================================================

     >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
     ------------------------------------------------------------------
     Copyright (c) 2019-2024 by Lattice Semiconductor Corporation
     ALL RIGHTS RESERVED
     ------------------------------------------------------------------

       IMPORTANT: THIS FILE IS USED BY OR GENERATED BY the LATTICE PROPEL™
       DEVELOPMENT SUITE, WHICH INCLUDES PROPEL BUILDER AND PROPEL SDK.

       Lattice grants permission to use this code pursuant to the
       terms of the Lattice Propel License Agreement.

     DISCLAIMER:

    LATTICE MAKES NO WARRANTIES ON THIS FILE OR ITS CONTENTS,
    WHETHER EXPRESSED, IMPLIED, STATUTORY,
    OR IN ANY PROVISION OF THE LATTICE PROPEL LICENSE AGREEMENT OR
    COMMUNICATION WITH LICENSEE,
    AND LATTICE SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
    MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
    LATTICE DOES NOT WARRANT THAT THE FUNCTIONS CONTAINED HEREIN WILL MEET
    LICENSEE 'S REQUIREMENTS, OR THAT LICENSEE' S OPERATION OF ANY DEVICE,
    SOFTWARE OR SYSTEM USING THIS FILE OR ITS CONTENTS WILL BE
    UNINTERRUPTED OR ERROR FREE,
    OR THAT DEFECTS HEREIN WILL BE CORRECTED.
    LICENSEE ASSUMES RESPONSIBILITY FOR SELECTION OF MATERIALS TO ACHIEVE
    ITS INTENDED RESULTS, AND FOR THE PROPER INSTALLATION, USE,
    AND RESULTS OBTAINED THEREFROM.
    LICENSEE ASSUMES THE ENTIRE RISK OF THE FILE AND ITS CONTENTS PROVING
    DEFECTIVE OR FAILING TO PERFORM PROPERLY AND IN SUCH EVENT,
    LICENSEE SHALL ASSUME THE ENTIRE COST AND RISK OF ANY REPAIR, SERVICE,
    CORRECTION,
    OR ANY OTHER LIABILITIES OR DAMAGES CAUSED BY OR ASSOCIATED WITH THE
    SOFTWARE.IN NO EVENT SHALL LATTICE BE LIABLE TO ANY PARTY FOR DIRECT,
    INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES,
    INCLUDING LOST PROFITS,
    ARISING OUT OF THE USE OF THIS FILE OR ITS CONTENTS,
    EVEN IF LATTICE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
    LATTICE 'S SOLE LIABILITY, AND LICENSEE' S SOLE REMEDY,
    IS SET FORTH ABOVE.
    LATTICE DOES NOT WARRANT OR REPRESENT THAT THIS FILE,
    ITS CONTENTS OR USE THEREOF DOES NOT INFRINGE ON THIRD PARTIES'
    INTELLECTUAL PROPERTY RIGHTS, INCLUDING ANY PATENT. IT IS THE USER' S
    RESPONSIBILITY TO VERIFY THE USER SOFTWARE DESIGN FOR CONSISTENCY AND
    FUNCTIONALITY THROUGH THE USE OF FORMAL SOFTWARE VALIDATION METHODS.
     ------------------------------------------------------------------
     ================================================================== */
/**
 * @file : This file is used to intizalize the ethernet module and configure for sending and receving
 * of ethernet packet.
 */

#ifndef ETHERNET_H_
#define ETHERNET_H_

//Driver Details
#define TSE_DRV_VER "v2024.01.00"

#define 		SUCCESS								1
#define 		FAILURE								0
#define 		IPG_TIME							12
#define 		MAX_PACKET_SIZE						1500
#define			SPEED_10_OR_100_MBPS				0
#define			SPEED_1G							0
#define			SET_FULL_DUPLEX_MODE				5
#define			SET_HALF_DUPLEX_MODE				5

// Mode Register
#define TX_EN          1 << 3
#define RX_EN          1 << 2
#define FC_EN          1 << 1
#define GBIT_EN        1 << 0

typedef struct
{
	unsigned char speed_mode;
	unsigned int adr;
	unsigned int frame_length;
	unsigned int mac_upper;
	unsigned int mac_lower;
	unsigned int multicast_upper;
	unsigned int multicast_lower;
	unsigned int tx_rx_ctrl_var;
	unsigned int enable_tx_mac;
	unsigned int enable_rx_mac;
}tsemac_handle_t;

/**
 * @brief Ethernet register.
 */
typedef struct
{
	volatile unsigned int mode_reg;    					//0x0000
	volatile unsigned int tx_rx_ctrl;
	volatile unsigned int max_packet_size;
	volatile unsigned int ipg;
	volatile unsigned int mac_addr0;						//0x0010
	volatile unsigned int mac_addr1;
	volatile unsigned int tx_rx_status;
	volatile unsigned int vlan_tag;
	volatile unsigned int gmii_mgmt_ctrl;				//0x0020
	volatile unsigned int gmii_mgmt_data;
	volatile unsigned int multi_cast0;
	volatile unsigned int multi_cast1;
	volatile unsigned int pause_opcode;					//0x0030
	volatile unsigned int tx_fifo_afull;
	volatile unsigned int tx_fifo_aempty;
	volatile unsigned int rx_fifo_afull;
	volatile unsigned int rx_fifo_aempty;				//0x0040
	volatile unsigned int interrupt_status;
	volatile unsigned int interrupt_enable;				//0x0048
}tsemac_reg_type_t;

/**
 * @brief enum to set speed for tsemac
 */
enum speed_mode_set
{
	fast_half_duplex_mode = 1,
	fast_full_duplex_mode,
	one_g_mode,
};

unsigned char ethernet_init(tsemac_handle_t *handle);
void ethernet_packet_handle(tsemac_handle_t *handle,unsigned int *src_packet,unsigned int *dest_packet);
unsigned char ethernet_set_mac_address(tsemac_handle_t *handle);
unsigned char ethernet_get_mac_address(tsemac_handle_t *handle);
unsigned char ethernet_set_multicast_address(tsemac_handle_t *handle);
unsigned char ethernet_get_multicast_address(tsemac_handle_t *handle);
unsigned char ethernet_set_speed(tsemac_handle_t *handle);
unsigned char ethernet_enable_tx_rx_mac(tsemac_handle_t *handle);
unsigned char ethernet_disable_tx_rx_mac(tsemac_handle_t *handle);
unsigned char ethernet_tx_rx_control_reg_set(tsemac_handle_t *handle,unsigned char bit_pos);
unsigned int ethernet_mode_reg_read(tsemac_handle_t *handle);
unsigned int ethernet_tx_rx_status_reg_read(tsemac_handle_t *handle);
#endif /* ETHERNET_H_ */
