/**************************************************************************************
 * \file   SYS_config.h
 * \brief  Application-level XCP and system configuration.
 *         Required by GO_xcp.c (Linux build).
 **************************************************************************************/

#ifndef SYS_CONFIG_H
#define SYS_CONFIG_H

/* XCP TCP/UDP listener port (must match HANtune or other master tool) */
#define XCP_PORT_NUM            17725

/* XCP station identifier shown in the master tool */
#define kXcpStationIdString     "GOcontroll-App"
#define kXcpStationIdLength     (sizeof(kXcpStationIdString) - 1u)

#endif /* SYS_CONFIG_H */
