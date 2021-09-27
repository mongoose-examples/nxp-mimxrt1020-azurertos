/**************************************************************************/
/*                                                                        */
/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
/*                                                                        */
/*       This software is licensed under the Microsoft Software License   */
/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
/*       and in the root directory of this software.                      */
/*                                                                        */
/**************************************************************************/

#include "fsl_common.h"
#include "fsl_debug_console.h"
#include "pin_mux.h"
#include "clock_config.h"
#include "board.h"

#include "nx_api.h"
#include "nxd_dns.h"
#include "nx_secure_tls_api.h"

#include "fsl_gpio.h"
#include "fsl_iomuxc.h"
#include "nx_bsd.h"
#include "web_server.h"

/*******************************************************************************
 * Definitions
 ******************************************************************************/

#define SAMPLE_HELPER_STACK_SIZE (4096)
#define SAMPLE_HELPER_THREAD_PRIORITY (4)

#define SAMPLE_IP_STACK_SIZE (2048)
#define SAMPLE_PACKET_COUNT (32)
#define SAMPLE_PACKET_SIZE (1536)
#define SAMPLE_POOL_SIZE ((SAMPLE_PACKET_SIZE + sizeof(NX_PACKET)) * SAMPLE_PACKET_COUNT)
#define SAMPLE_ARP_CACHE_SIZE (512)
#define SAMPLE_IP_THREAD_PRIORITY (1)

/*******************************************************************************
 * Variables
 ******************************************************************************/

static TX_THREAD sample_helper_thread;
static NX_PACKET_POOL pool_0;
static NX_IP ip_0;
static NX_DNS dns_0;


/* Define the stack/cache for ThreadX.  */
static ULONG sample_ip_stack[SAMPLE_IP_STACK_SIZE / sizeof(ULONG)];
AT_NONCACHEABLE_SECTION_ALIGN(ULONG sample_pool_stack[SAMPLE_POOL_SIZE / sizeof(ULONG)], 64);
static ULONG sample_pool_stack_size = sizeof(sample_pool_stack);
static ULONG sample_arp_cache_area[SAMPLE_ARP_CACHE_SIZE / sizeof(ULONG)];
static ULONG sample_helper_thread_stack[SAMPLE_HELPER_STACK_SIZE / sizeof(ULONG)];
static ULONG tcp_stack[SAMPLE_IP_STACK_SIZE / sizeof(ULONG)];

static void sample_helper_thread_entry(ULONG parameter);

/*******************************************************************************
 * Prototypes
 ******************************************************************************/

/* Include the platform IP driver. */
extern VOID nx_driver_imx(NX_IP_DRIVER *driver_req_ptr);

extern uint32_t get_seed(void);
extern void delay(void);

/*******************************************************************************
 * Code
 ******************************************************************************/
void BOARD_InitModuleClock(void)
{
    const clock_enet_pll_config_t config = {
        .enableClkOutput = true, .enableClkOutput500M = false, .enableClkOutput25M = false, .loopDivider = 1};
    CLOCK_InitEnetPll(&config);
}

/* return the ENET MDIO interface clock frequency */
uint32_t BOARD_GetMDIOClock(void)
{
    return CLOCK_GetFreq(kCLOCK_IpgClk);
}

/* Define main entry point.  */
int main(void)
{
    /* Init board hardware. */
    gpio_pin_config_t gpio_config = {kGPIO_DigitalOutput, 0, kGPIO_NoIntmode};

    BOARD_ConfigMPU();
    BOARD_InitBootPins();
    BOARD_InitBootClocks();
    BOARD_InitDebugConsole();
    BOARD_InitModuleClock();

    IOMUXC_EnableMode(IOMUXC_GPR, kIOMUXC_GPR_ENET1TxClkOutputDir, true);

    GPIO_PinInit(GPIO1, 4, &gpio_config);
    GPIO_PinInit(GPIO1, 22, &gpio_config);
    GPIO_PinInit(GPIO1, 5, &gpio_config);
    IOMUXC_SetPinMux(IOMUXC_GPIO_AD_B0_05_GPIO1_IO05, 0U);
    IOMUXC_SetPinConfig(IOMUXC_GPIO_AD_B0_05_GPIO1_IO05, 0x10B0U);

    /* pull up the ENET_INT before RESET. */
    GPIO_WritePinOutput(GPIO1, 22, 1);
    GPIO_WritePinOutput(GPIO1, 4, 0);
    delay();
    GPIO_WritePinOutput(GPIO1, 4, 1);

    /* Enter the ThreadX kernel.  */
    tx_kernel_enter();

    return 0;
}

/* Define what the initial system looks like.  */
void tx_application_define(void *first_unused_memory)
{
    UINT status;

    /* Initialize the NetX system.  */
    nx_system_initialize();

    /* Create a packet pool.  */
    status = nx_packet_pool_create(&pool_0, "NetX Main Packet Pool", SAMPLE_PACKET_SIZE, (UCHAR *)sample_pool_stack,
                                   sample_pool_stack_size);

    /* Check for pool creation error.  */
    if (status)
    {
        PRINTF("nx_packet_pool_create fail: %u\r\n", status);
        return;
    }

    /* Create an IP instance.  */
    status = nx_ip_create(&ip_0, "NetX IP Instance 0", SAMPLE_IPV4_ADDRESS, SAMPLE_IPV4_MASK, &pool_0, nx_driver_imx,
                          (UCHAR *)sample_ip_stack, sizeof(sample_ip_stack), SAMPLE_IP_THREAD_PRIORITY);

    /* Check for IP create errors.  */
    if (status)
    {
        PRINTF("nx_ip_create fail: %u\r\n", status);
        return;
    }

    /* Enable ARP and supply ARP cache memory for IP Instance 0.  */
    status = nx_arp_enable(&ip_0, (VOID *)sample_arp_cache_area, sizeof(sample_arp_cache_area));

    /* Check for ARP enable errors.  */
    if (status)
    {
        PRINTF("nx_arp_enable fail: %u\r\n", status);
        return;
    }

    /* Check for ICMP enable errors.  */
    if (status)
    {
        PRINTF("nx_icmp_enable fail: %u\r\n", status);
        return;
    }

    /* Enable TCP traffic.  */
    status = nx_tcp_enable(&ip_0);

    /* Check for TCP enable errors.  */
    if (status)
    {
        PRINTF("nx_tcp_enable fail: %u\r\n", status);
        return;
    }

    /* Check for UDP enable errors.  */
    if (status)
    {
        PRINTF("nx_udp_enable fail: %u\r\n", status);
        return;
    }

    status = (UINT)bsd_initialize (&ip_0, &pool_0, (void*)tcp_stack, sizeof(tcp_stack), 2);

    /* Create sample helper thread. */
    status = tx_thread_create(&sample_helper_thread, "Demo Thread", sample_helper_thread_entry, 0,
                              sample_helper_thread_stack, SAMPLE_HELPER_STACK_SIZE, SAMPLE_HELPER_THREAD_PRIORITY,
                              SAMPLE_HELPER_THREAD_PRIORITY, TX_NO_TIME_SLICE, TX_AUTO_START);

    /* Check status.  */
    if (status)
    {
        PRINTF("Demo helper thread creation fail: %u\r\n", status);
        return;
    }
}

/* Define sample helper thread entry.  */
static void sample_helper_thread_entry(ULONG parameter)
{
    UINT status;
    ULONG ip_address      = 0;
    ULONG network_mask    = 0;
    ULONG gateway_address = 0;

    /* Use a random number to init the seed.  */
    srand(get_seed());

    nx_ip_gateway_address_set(&ip_0, SAMPLE_GATEWAY_ADDRESS);

    /* Get IP address and gateway address. */
    nx_ip_address_get(&ip_0, &ip_address, &network_mask);
    nx_ip_gateway_address_get(&ip_0, &gateway_address);

    /* Output IP address and gateway address. */
    PRINTF("IP address: %lu.%lu.%lu.%lu\r\n", (ip_address >> 24), (ip_address >> 16 & 0xFF), (ip_address >> 8 & 0xFF),
           (ip_address & 0xFF));
    PRINTF("Mask: %lu.%lu.%lu.%lu\r\n", (network_mask >> 24), (network_mask >> 16 & 0xFF), (network_mask >> 8 & 0xFF),
           (network_mask & 0xFF));
    PRINTF("Gateway: %lu.%lu.%lu.%lu\r\n", (gateway_address >> 24), (gateway_address >> 16 & 0xFF),
           (gateway_address >> 8 & 0xFF), (gateway_address & 0xFF));


    /* Check for DNS create errors.  */
    if (status)
    {
        PRINTF("dns_create fail: %u\r\n", status);
        return;
    }

    /* Start sample.  */
    mg_run_server();
}
