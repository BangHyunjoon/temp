import xmlrpclib 
import subprocess 
import sys 
import string
import time

 
VDSM_DIR = '/usr/share/vdsm' 
VDSM_CONF = '/etc/vdsm/vdsm.conf' 
 
try: 
    sys.path.append(VDSM_DIR) 
    from config import config 
    sys.path.pop() 
    config.read(VDSM_CONF) 
except: 
    # VDSM not available 
    raise ImportError('local vdsm not found') 

def getTrustStorePath(): 
    tsPath = None 
    if config.getboolean('vars', 'ssl'): 
        tsPath = config.get('vars', 'trust_store_path') 
    return tsPath 
 
def getLocalVdsName(tsPath): 
    p = subprocess.Popen(['/usr/bin/openssl', 'x509', '-noout', '-subject', '-in', 
            '%s/certs/vdsmcert.pem' % tsPath], 
            stdout=subprocess.PIPE, close_fds=True) 
    out, err = p.communicate() 
    if p.returncode != 0: 
        return '0' 
    return out.split('=')[-1].strip() 
 
def connect(): 
    tsPath = getTrustStorePath() 
    port = config.get('addresses', 'management_port') 
    if tsPath: 
        addr = getLocalVdsName(tsPath) 
        from M2Crypto.m2xmlrpclib import SSL_Transport 
        from M2Crypto import SSL 

        KEYFILE = tsPath + '/keys/vdsmkey.pem' 
        CERTFILE = tsPath + '/certs/vdsmcert.pem' 
        CACERT = tsPath + '/certs/cacert.pem' 

        ctx = SSL.Context ('sslv3') 

        ctx.set_verify(SSL.verify_peer | SSL.verify_fail_if_no_peer_cert, 16) 
        ctx.load_verify_locations(CACERT) 
        ctx.load_cert(CERTFILE, KEYFILE) 
 
        server = xmlrpclib.Server('https://%s:%s' % (addr, port), 
                                SSL_Transport(ctx)) 
    else: 
        server = xmlrpclib.Server('http://localhost:%s' % port) 
    return server 
 
if __name__ == '__main__':
    server = connect()

    global DEBUG_PRINT

    DEBUG_PRINT = 0
    while 1 :
        response = server.list(True)
        if response['status']['code'] != 0:
            if DEBUG_PRINT == 1 :
                print "response status code=[%d], message=[%s]" % (response['status']['code'], response['status']['message'])
        else:
            #    for d1 in response['vmList']:
            #        print d1
            STR_SPLIT1 = chr(0x03) + chr(0x1F) + chr(0x7C)
            STR_SPLIT2 = chr(0x03) + chr(0x1F) + chr(0x7E)
            VM_HEAD = "INDEX%sVM_NAME%sEM_MACHINE%sVMID%sCORES_P_SOCKET%sALLOC_MEM%sMAC%sBRIDGE%sBOOT_STATUS%sBOOT_TIME%sCPU_USED%sCPU_IDLE%sCPU_SYS%sCPU_USER%sMEM_USED%sMEM_USE%sRX_RATE%sTX_RATE%sRX_DROP%sTX_DROP%sNWT_CNT%sDSK_SIZE%sDSK_R_RATE%sDSK_W_RATE%sDSK_CNT%sDRV_SIZE%sDRV_CNT%s" % (STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2)
            VDISK_HEAD = "INDEX%sVMID%sDISK_NAME%sIMAGE_ID%sTRUE_SIZE%sAPP_SIZE%sREAD_RATE%sWRITE_RATE%s" % (STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2)
            VNWT_HEAD = "INDEX%sVMID%sMAC%sNWT_NAME%sSPEED%sRX_RATE%sTX_RATE%sRX_ERR%sTX_ERR%sRX_DROP%sTX_DROP%sNWT_STATE%s" % (STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2)
            VDRV_HEAD = "INDEX%sVMID%sVOL_ID%sDOMAIN_ID%sIMAGE_ID%sPOOL_ID%sDRV_PATH%sSERIAL%sBLK_DEV%sTRUE_SIZE%sPROPAGATE_ERR%sBOOT_STATUS%s" % (STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2)
            #print "====================<<response>>========================="
            #print response
            #print "====================<<response['vmList']['vmId']>>========================="
        
            VM_INDEX = 0
            VM_NWT_CNT = 0
            VM_NWT_MAC = '00:00:00:00:00:00'
            VM_BRIDGE = '-'
            VM_DSK_SIZE = 0.0
            VM_DSK_AVG_R_RATE = 0.0
            VM_DSK_AVG_W_RATE = 0.0
            VM_DSK_R_RATE = 0.0
            VM_DSK_W_RATE = 0.0
            VM_DSK_CNT = 0
            VM_DRV_SIZE = 0.0
            VM_DRV_CNT = 0
            VDISK_INDEX = 0
            VNWT_INDEX = 0
            VDRV_INDEX = 0
            VNWT_RXRATE = 0.0
            VNWT_TXRATE = 0.0
            VNWT_T_RXRATE = 0.0
            VNWT_T_TXRATE = 0.0
            VNWT_AVG_RXRATE = 0.0
            VNWT_AVG_TXRATE = 0.0
            VNWT_T_RXDROP = 0.0
            VNWT_T_TXDROP = 0.0
            VNWT_AVG_RXDROP = 0.0
            VNWT_AVG_TXDROP = 0.0
        
            VM_DATA = VM_HEAD
            VDISK_DATA = VDISK_HEAD
            VNWT_DATA = VNWT_HEAD
            VDRV_DATA = VDRV_HEAD
        
            for VM_INFO in response['vmList']:
                #print "====================<<server.getVmStats>>========================="
                VM_STATE_RSP = server.getVmStats(VM_INFO['vmId'])
                VM_INDEX = VM_INDEX + 1
                VM_STATE = VM_STATE_RSP['statsList'][0]

                #print "[%s]:[%s]:%s" % (VM_INFO['vmId'],VM_INFO['vmName'], VM_STATE)
                #CPU_USED = string.atof(VM_STATE['cpuUser']) + string.atof(VM_STATE['cpuSys'])
                CPU_USED = (string.atof(VM_STATE['cpuUser']) + string.atof(VM_STATE['cpuSys'])) / (string.atof(VM_INFO['smpCoresPerSocket']))
                CPU_IDLE = 100.0 - CPU_USED
                MEM_USE = int(string.atof(VM_STATE['memUsage']) / 100 * float(VM_INFO['memSize']))
            
                VM_BOOT_STATE = 1
                if VM_INFO['status'] != '' :
                    if string.upper(VM_INFO['status']) == 'UP' :
                        VM_BOOT_STATE = 1
                    else:
                        VM_BOOT_STATE = 0

                if VM_INFO['timeOffset'] < 0 :
                    TIME_TMP = 0
                else:
                    TIME_TMP = int(time.time()) - int(VM_INFO['timeOffset'])

                if DEBUG_PRINT == 1 :
                    print time.localtime(TIME_TMP)
                    print time.localtime(time.time())
            
                VM_NWT_CNT = 0
                VM_NWT_MAC = '00:00:00:00:00:00'
                VM_BRIDGE = '-'
                VM_DSK_SIZE = 0.0
                VM_DSK_AVG_R_RATE = 0.0
                VM_DSK_AVG_W_RATE = 0.0
                VM_DSK_R_RATE = 0.0
                VM_DSK_W_RATE = 0.0
                VM_DSK_CNT = 0
                VM_DRV_SIZE = 0.0
                VM_DRV_CNT = 0
                for VDISK_NAME in VM_STATE['disks'].keys():
                    #print "VMID=%s, VDISK=NAME=%s" % (VM_INFO['vmId'], VDISK_NAME)
                    try:
                        if VM_STATE['disks'][VDISK_NAME]['truesize'] != '' :
                            VDISK_INDEX = VDISK_INDEX + 1

                            VM_DSK_CNT = VM_DSK_CNT + 1
                            VM_DSK_SIZE = VM_DSK_SIZE + string.atof(VM_STATE['disks'][VDISK_NAME]['truesize'])/1024.0/1024.0
                            VM_DSK_R_RATE = VM_DSK_R_RATE + string.atof(VM_STATE['disks'][VDISK_NAME]['readRate'])
                            VM_DSK_W_RATE = VM_DSK_W_RATE + string.atof(VM_STATE['disks'][VDISK_NAME]['writeRate'])
                            if DEBUG_PRINT == 1 :
                                print "VDISK=%s%d%s%s%s%s%s%s%s%d%s%d%s%0.2f%s%0.2f%s" % (STR_SPLIT1, VDISK_INDEX, STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VDISK_NAME, STR_SPLIT2, VM_STATE['disks'][VDISK_NAME]['imageID'], STR_SPLIT2, string.atoi(VM_STATE['disks'][VDISK_NAME]['truesize'])/1024/1024, STR_SPLIT2, string.atoi(VM_STATE['disks'][VDISK_NAME]['apparentsize'])/1024/1024, STR_SPLIT2, string.atof(VM_STATE['disks'][VDISK_NAME]['readRate']), STR_SPLIT2, string.atof(VM_STATE['disks'][VDISK_NAME]['writeRate']), STR_SPLIT2)
                            VDISK_DATA = VDISK_DATA + "%s%d%s%s%s%s%s%s%s%d%s%d%s%0.2f%s%0.2f%s" % (STR_SPLIT1, VDISK_INDEX, STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VDISK_NAME, STR_SPLIT2, VM_STATE['disks'][VDISK_NAME]['imageID'], STR_SPLIT2, string.atoi(VM_STATE['disks'][VDISK_NAME]['truesize'])/1024/1024, STR_SPLIT2, string.atoi(VM_STATE['disks'][VDISK_NAME]['apparentsize'])/1024/1024, STR_SPLIT2, string.atof(VM_STATE['disks'][VDISK_NAME]['readRate']), STR_SPLIT2, string.atof(VM_STATE['disks'][VDISK_NAME]['writeRate']), STR_SPLIT2)
                    except: 
                            VDISK_INDEX = VDISK_INDEX

                VM_DSK_AVG_R_RATE = VM_DSK_R_RATE / float(VM_DSK_CNT)
                VM_DSK_AVG_W_RATE = VM_DSK_W_RATE / float(VM_DSK_CNT)
            
                for VNWT_NAME in VM_STATE['network'].keys():
                    VNWT_INDEX = VNWT_INDEX + 1
                    if VM_STATE['network'][VNWT_NAME]['macAddr'] != '' :
                        VNWT_MAC = VM_STATE['network'][VNWT_NAME]['macAddr']
                    else:
                        VNWT_MAC = "-"

                    if VM_STATE['network'][VNWT_NAME]['rxDropped'] != '' :
                        if VM_STATE['network'][VNWT_NAME]['rxDropped'] != '0.0' :
                            VNWT_RXDROP = string.atof(VM_STATE['network'][VNWT_NAME]['rxDropped'])
                        else:
                            VNWT_RXDROP = 0.0
                    else:
                        VNWT_RXDROP = 0.0
                    VNWT_T_RXDROP = VNWT_T_RXDROP + VNWT_RXDROP

                    if VM_STATE['network'][VNWT_NAME]['txDropped'] != '' :
                        if VM_STATE['network'][VNWT_NAME]['txDropped'] != '0.0' :
                            VNWT_TXDROP = string.atof(VM_STATE['network'][VNWT_NAME]['txDropped'])
                        else:
                            VNWT_TXDROP = 0.0
                    else:
                        VNWT_TXDROP = 0.0
                    VNWT_T_TXDROP = VNWT_T_TXDROP + VNWT_TXDROP

                    if VM_STATE['network'][VNWT_NAME]['rxErrors'] != '' :
                        VNWT_RXERR = string.atof(VM_STATE['network'][VNWT_NAME]['rxErrors'])
                    else:
                        VNWT_RXERR = 0.0

                    if VM_STATE['network'][VNWT_NAME]['txErrors'] != '' :
                        VNWT_TXERR = string.atof(VM_STATE['network'][VNWT_NAME]['txErrors'])
                    else:
                        VNWT_TXERR = 0.0

                    if VM_STATE['network'][VNWT_NAME]['rxRate'] != '' :
                        if VM_STATE['network'][VNWT_NAME]['rxRate'] != '0.0' :
                            VNWT_RXRATE = string.atof(VM_STATE['network'][VNWT_NAME]['rxRate'])
                        else:
                            VNWT_RXRATE = 0.0
                    else:
                        VNWT_RXRATE = 0.0
                    VNWT_T_RXRATE = VNWT_T_RXRATE + VNWT_RXRATE

                    if VM_STATE['network'][VNWT_NAME]['txRate'] != '' :
                        if VM_STATE['network'][VNWT_NAME]['txRate'] != '0.0' :
                            VNWT_TXRATE = string.atof(VM_STATE['network'][VNWT_NAME]['txRate'])
                        else:
                            VNWT_TXRATE = 0.0
                    else:
                        VNWT_TXRATE = 0.0
                    VNWT_T_TXRATE = VNWT_TXRATE + VNWT_TXRATE 
                
                    if VM_STATE['network'][VNWT_NAME]['state'] != '' :
                        if string.upper(VM_STATE['network'][VNWT_NAME]['state']) == 'UP' :
                            VNWT_STATE = 1
                        else:
                            VNWT_STATE = 0
                    else:
                        VNWT_STATE = 1
                    
                    VM_NWT_CNT = VM_NWT_CNT + 1

                    if DEBUG_PRINT == 1 :
                        print "VNWT=%s%d%s%s%s%s%s%s%s%d%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%d%s" % (STR_SPLIT1, VNWT_INDEX, STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, string.upper(VNWT_MAC), STR_SPLIT2, VNWT_NAME, STR_SPLIT2, string.atoi(VM_STATE['network'][VNWT_NAME]['speed']), STR_SPLIT2, VNWT_RXRATE, STR_SPLIT2, VNWT_TXRATE, STR_SPLIT2, VNWT_RXERR, STR_SPLIT2, VNWT_TXERR, STR_SPLIT2, VNWT_RXDROP, STR_SPLIT2, VNWT_TXDROP, STR_SPLIT2, VNWT_STATE, STR_SPLIT2)
                    VNWT_DATA = VNWT_DATA + "%s%d%s%s%s%s%s%s%s%d%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%d%s" % (STR_SPLIT1, VNWT_INDEX, STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, string.upper(VNWT_MAC), STR_SPLIT2, VNWT_NAME, STR_SPLIT2, string.atoi(VM_STATE['network'][VNWT_NAME]['speed']), STR_SPLIT2, VNWT_RXRATE, STR_SPLIT2, VNWT_TXRATE, STR_SPLIT2, VNWT_RXERR, STR_SPLIT2, VNWT_TXERR, STR_SPLIT2, VNWT_RXDROP, STR_SPLIT2, VNWT_TXDROP, STR_SPLIT2, VNWT_STATE, STR_SPLIT2)
    
                try:
                    for VDRV_INFO in VM_INFO['drives']:
                        VDRV_INDEX = VDRV_INDEX + 1
    
                        try:
                            if VDRV_INFO['blockDev'] != '' :
                                if VDRV_INFO['blockDev'] == True :
                                    VDRV_BLOCK_DEV = 1
                                else:
                                    VDRV_BLOCK_DEV = 0
                            else:
                                VDRV_BLOCK_DEV = 0
                        except: 
                            VDRV_BLOCK_DEV = 0
                    
                        try:
                            if VDRV_INFO['propagateErrors'] != '' :
                                if string.upper(VDRV_INFO['propagateErrors']) == 'OFF' :
                                    VDRV_PROPAGATE = 0
                                else:
                                    VDRV_PROPAGATE = 1
                            else:
                                VDRV_PROPAGATE = 0
                        except: 
                            VDRV_PROPAGATE = 0
                        
                        try:
                            if VDRV_INFO['boot'] != '' :
                                if string.upper(VDRV_INFO['boot']) == 'UP' :
                                    VDRV_STATE = 1
                                else:
                                    VDRV_STATE = 0
                            else:
                                VDRV_STATE = 1
                        except: 
                            VDRV_STATE = 1
                    
                        try:
                            VM_DRV_SIZE = VM_DRV_SIZE + string.atof(VDRV_INFO['truesize'])/1024.0/1024.0
                            VM_DRV_CNT = VM_DRV_CNT + 1
                        except: 
                            VM_DRV_SIZE = VM_DRV_SIZE
                            VM_DRV_CNT = VM_DRV_CNT

                        try:
                            if DEBUG_PRINT == 1 :
                                print "VDRV=%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%d%s%d%s%d%s%d%s" % (STR_SPLIT1, VDRV_INDEX, STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VDRV_INFO['volumeID'], STR_SPLIT2, VDRV_INFO['domainID'], STR_SPLIT2, VDRV_INFO['imageID'], STR_SPLIT2, VDRV_INFO['poolID'], STR_SPLIT2, VDRV_INFO['path'], STR_SPLIT2, VDRV_INFO['serial'], STR_SPLIT2, VDRV_BLOCK_DEV, STR_SPLIT2, string.atoi(VDRV_INFO['truesize'])/1024/1024, STR_SPLIT2, VDRV_PROPAGATE, STR_SPLIT2, VDRV_STATE, STR_SPLIT2)
                            VDRV_DATA = VDRV_DATA + "%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%d%s%d%s%d%s%d%s" % (STR_SPLIT1, VDRV_INDEX, STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VDRV_INFO['volumeID'], STR_SPLIT2, VDRV_INFO['domainID'], STR_SPLIT2, VDRV_INFO['imageID'], STR_SPLIT2, VDRV_INFO['poolID'], STR_SPLIT2, VDRV_INFO['path'], STR_SPLIT2, VDRV_INFO['serial'], STR_SPLIT2, VDRV_BLOCK_DEV, STR_SPLIT2, string.atoi(VDRV_INFO['truesize'])/1024/1024, STR_SPLIT2, VDRV_PROPAGATE, STR_SPLIT2, VDRV_STATE, STR_SPLIT2)
                        except:
                            VDRV_DATA = VDRV_DATA    
                except:
                    VDRV_DATA = VDRV_DATA

                if VM_NWT_CNT != 0 :
                    VNWT_AVG_RXRATE = VNWT_T_RXRATE / VM_NWT_CNT
                    VNWT_AVG_TXRATE = VNWT_T_TXRATE / VM_NWT_CNT
                    VNWT_AVG_RXDROP = VNWT_T_RXDROP / VM_NWT_CNT
                    VNWT_AVG_TXDROP = VNWT_T_TXDROP / VM_NWT_CNT

                VM_NIC_INFO = '-'
                VM_NIC_INDEX = 0
                try: 
                    VM_NWT_MAC = VM_INFO['macAddr']
                    VM_BRIDGE = VM_INFO['bridge']
                except: 
                    try:
                        for VM_NIC_INFO in VM_INFO['devices']:
                            VM_NIC_INDEX = VM_NIC_INDEX + 1

                            try:
                                VM_NWT_MAC = VM_NIC_INFO['macAddr']
                            except:
                                VM_NWT_MAC = VM_NWT_MAC
                        
                    except:
                        VM_NWT_MAC = '00:00:00:00:00:00'
                    VM_BRIDGE = '-'

                if DEBUG_PRINT == 1 :
                    #print "VM=%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%d%s%d%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%d%s%s%s%s%s%s%s%s%s%d%s%0.2f%s%0.2f%s%0.2f%s%d%s%0.2f%s%d%s" % (STR_SPLIT1, VM_INDEX, STR_SPLIT2, VM_INFO['vmName'], STR_SPLIT2, VM_INFO['emulatedMachine'], STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VM_INFO['smpCoresPerSocket'], STR_SPLIT2, VM_INFO['memSize'], STR_SPLIT2, string.upper(VM_NWT_MAC), STR_SPLIT2, VM_INFO['bridge'], STR_SPLIT2, VM_BOOT_STATE, STR_SPLIT2, TIME_TMP, STR_SPLIT2, CPU_USED, STR_SPLIT2, CPU_IDLE, STR_SPLIT2, (string.atof(VM_STATE['cpuSys'])) / (string.atof(VM_INFO['smpCoresPerSocket'])), STR_SPLIT2, (string.atof(VM_STATE['cpuUser'])) / (string.atof(VM_INFO['smpCoresPerSocket'])), STR_SPLIT2, string.atof(VM_STATE['memUsage']), STR_SPLIT2, MEM_USE, STR_SPLIT2, VNWT_AVG_RXRATE, STR_SPLIT2, VNWT_AVG_TXRATE, STR_SPLIT2, VNWT_AVG_RXDROP, STR_SPLIT2, VNWT_AVG_TXDROP, STR_SPLIT2, VM_NWT_CNT, STR_SPLIT2, VM_DSK_SIZE, STR_SPLIT2, VM_DSK_AVG_R_RATE, STR_SPLIT2, VM_DSK_AVG_W_RATE, STR_SPLIT2, VM_DSK_CNT, STR_SPLIT2, VM_DRV_SIZE, STR_SPLIT2, VM_DRV_CNT, STR_SPLIT2)
                    print "VM=%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%d%s%d%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%d%s%s%s%s%s%s%s%s%s%d%s%0.2f%s%0.2f%s%0.2f%s%d%s%0.2f%s%d%s" % (STR_SPLIT1, VM_INDEX, STR_SPLIT2, VM_INFO['vmName'], STR_SPLIT2, VM_INFO['emulatedMachine'], STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VM_INFO['smpCoresPerSocket'], STR_SPLIT2, VM_INFO['memSize'], STR_SPLIT2, string.upper(VM_NWT_MAC), STR_SPLIT2, VM_BRIDGE, STR_SPLIT2, VM_BOOT_STATE, STR_SPLIT2, TIME_TMP, STR_SPLIT2, CPU_USED, STR_SPLIT2, CPU_IDLE, STR_SPLIT2, (string.atof(VM_STATE['cpuSys'])) / (string.atof(VM_INFO['smpCoresPerSocket'])), STR_SPLIT2, (string.atof(VM_STATE['cpuUser'])) / (string.atof(VM_INFO['smpCoresPerSocket'])), STR_SPLIT2, string.atof(VM_STATE['memUsage']), STR_SPLIT2, MEM_USE, STR_SPLIT2, VNWT_AVG_RXRATE, STR_SPLIT2, VNWT_AVG_TXRATE, STR_SPLIT2, VNWT_AVG_RXDROP, STR_SPLIT2, VNWT_AVG_TXDROP, STR_SPLIT2, VM_NWT_CNT, STR_SPLIT2, VM_DSK_SIZE, STR_SPLIT2, VM_DSK_AVG_R_RATE, STR_SPLIT2, VM_DSK_AVG_W_RATE, STR_SPLIT2, VM_DSK_CNT, STR_SPLIT2, VM_DRV_SIZE, STR_SPLIT2, VM_DRV_CNT, STR_SPLIT2)
                    #print "VM=%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%d%s%d%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%d%s%s%s%s%s%s%s%s%s%d%s%0.2f%s%0.2f%s%0.2f%s%d%s%0.2f%s%d%s" % (STR_SPLIT1, VM_INDEX, STR_SPLIT2, VM_INFO['vmName'], STR_SPLIT2, VM_INFO['emulatedMachine'], STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VM_INFO['smpCoresPerSocket'], STR_SPLIT2, VM_INFO['memSize'], STR_SPLIT2, string.upper(VM_NWT_MAC), STR_SPLIT2, VM_INFO['bridge'], STR_SPLIT2, VM_BOOT_STATE, STR_SPLIT2, TIME_TMP, STR_SPLIT2, CPU_USED, STR_SPLIT2, CPU_IDLE, STR_SPLIT2, string.atof(VM_STATE['cpuSys']), STR_SPLIT2, string.atof(VM_STATE['cpuUser']), STR_SPLIT2, string.atof(VM_STATE['memUsage']), STR_SPLIT2, MEM_USE, STR_SPLIT2, string.atof(VM_STATE['rxRate']), STR_SPLIT2, string.atof(VM_STATE['txRate']), STR_SPLIT2, string.atof(VM_STATE['rxDropped']), STR_SPLIT2, string.atof(VM_STATE['txDropped']), STR_SPLIT2, VM_NWT_CNT, STR_SPLIT2, VM_DSK_SIZE, STR_SPLIT2, VM_DSK_AVG_R_RATE, STR_SPLIT2, VM_DSK_AVG_W_RATE, STR_SPLIT2, VM_DSK_CNT, STR_SPLIT2, VM_DRV_SIZE, STR_SPLIT2, VM_DRV_CNT, STR_SPLIT2)
                VM_DATA = VM_DATA + "%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%d%s%d%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%d%s%s%s%s%s%s%s%s%s%d%s%0.2f%s%0.2f%s%0.2f%s%d%s%0.2f%s%d%s" % (STR_SPLIT1, VM_INDEX, STR_SPLIT2, VM_INFO['vmName'], STR_SPLIT2, VM_INFO['emulatedMachine'], STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VM_INFO['smpCoresPerSocket'], STR_SPLIT2, VM_INFO['memSize'], STR_SPLIT2, string.upper(VM_NWT_MAC), STR_SPLIT2, VM_BRIDGE, STR_SPLIT2, VM_BOOT_STATE, STR_SPLIT2, TIME_TMP, STR_SPLIT2, CPU_USED, STR_SPLIT2, CPU_IDLE, STR_SPLIT2, (string.atof(VM_STATE['cpuSys'])) / (string.atof(VM_INFO['smpCoresPerSocket'])), STR_SPLIT2, (string.atof(VM_STATE['cpuUser'])) / (string.atof(VM_INFO['smpCoresPerSocket'])), STR_SPLIT2, string.atof(VM_STATE['memUsage']), STR_SPLIT2, MEM_USE, STR_SPLIT2, VNWT_AVG_RXRATE, STR_SPLIT2, VNWT_AVG_TXRATE, STR_SPLIT2, VNWT_AVG_RXDROP, STR_SPLIT2, VNWT_AVG_TXDROP, STR_SPLIT2, VM_NWT_CNT, STR_SPLIT2, VM_DSK_SIZE, STR_SPLIT2, VM_DSK_AVG_R_RATE, STR_SPLIT2, VM_DSK_AVG_W_RATE, STR_SPLIT2, VM_DSK_CNT, STR_SPLIT2, VM_DRV_SIZE, STR_SPLIT2, VM_DRV_CNT, STR_SPLIT2)
                #VM_DATA = VM_DATA + "%s%d%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%d%s%d%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%0.2f%s%d%s%s%s%s%s%s%s%s%s%d%s%0.2f%s%0.2f%s%0.2f%s%d%s%0.2f%s%d%s" % (STR_SPLIT1, VM_INDEX, STR_SPLIT2, VM_INFO['vmName'], STR_SPLIT2, VM_INFO['emulatedMachine'], STR_SPLIT2, VM_INFO['vmId'], STR_SPLIT2, VM_INFO['smpCoresPerSocket'], STR_SPLIT2, VM_INFO['memSize'], STR_SPLIT2, string.upper(VM_NWT_MAC), STR_SPLIT2, VM_INFO['bridge'], STR_SPLIT2, VM_BOOT_STATE, STR_SPLIT2, TIME_TMP, STR_SPLIT2, CPU_USED, STR_SPLIT2, CPU_IDLE, STR_SPLIT2, string.atof(VM_STATE['cpuSys']), STR_SPLIT2, string.atof(VM_STATE['cpuUser']), STR_SPLIT2, string.atof(VM_STATE['memUsage']), STR_SPLIT2, MEM_USE, STR_SPLIT2, string.atof(VM_STATE['rxRate']), STR_SPLIT2, string.atof(VM_STATE['txRate']), STR_SPLIT2, string.atof(VM_STATE['rxDropped']), STR_SPLIT2, string.atof(VM_STATE['txDropped']), STR_SPLIT2, VM_NWT_CNT, STR_SPLIT2, VM_DSK_SIZE, STR_SPLIT2, VM_DSK_AVG_R_RATE, STR_SPLIT2, VM_DSK_AVG_W_RATE, STR_SPLIT2, VM_DSK_CNT, STR_SPLIT2, VM_DRV_SIZE, STR_SPLIT2, VM_DRV_CNT, STR_SPLIT2)

        if DEBUG_PRINT == 1 :
            print VM_DATA
            print VDISK_DATA
            print VNWT_DATA
            print VDRV_DATA
    
        data_file = open("../aproc/shell/vm.dat", 'w')
        data_file.write(VM_DATA.encode('utf-8'))
        data_file.close()

        data_file = open("../aproc/shell/vdisk.dat", 'w')
        data_file.write(VDISK_DATA.encode('utf-8'))
        data_file.close()
    
        data_file = open("../aproc/shell/vnwt.dat", 'w')
        data_file.write(VNWT_DATA.encode('utf-8'))
        data_file.close()    

        data_file = open("../aproc/shell/vdrv.dat", 'w')
        data_file.write(VDRV_DATA.encode('utf-8'))
        data_file.close()
        time.sleep(10)
