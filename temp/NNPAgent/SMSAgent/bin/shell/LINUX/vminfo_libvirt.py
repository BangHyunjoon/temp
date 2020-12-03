import re, sys, os, time
import libvirt
import libxml2

def canon(name):
    return re.sub(r"[^a-zA-Z0-9_]", "_", name)

def print_config(uri):
    """print the plugin config, determine the domains"""

    print """graph_title Virtual Domain Network I/O
    graph_vlabel Bytes rx (-)/ tx (+) per ${graph_period}
    graph_category Virtual Machines
    graph_info This graph shows the network I/O of the virtual machines"""

    conn = libvirt.openReadOnly(uri)
    ids = conn.listDomainsID()
    for id in ids:
        try:
            dom = conn.lookupByID(id)
            name = dom.name()
        except libvirt.libvirtError, err:
            print >>sys.stderr, "Id: %s: %s" % (id, err)
            continue
        if name == "Domain-0":
            continue
        print "%s_rx.label %s" % (canon(name), name)
        print "%s_rx.type DERIVE" % canon(name)
        print "%s_rx.min 0" % canon(name)
        print "%s_rx.graph no" % canon(name)
        print "%s_rx.draw LINE1" % canon(name)
        print "%s_tx.label %s" % (canon(name), name)
        print "%s_tx.type DERIVE" % canon(name)
        print "%s_tx.min 0" % canon(name)
        print "%s_tx.negative %s_rx" % (canon(name), canon(name))
        print "%s_tx.draw LINE1" % canon(name)

def get_ifaces(dom):
    global macs
    global if_cnt
    if_cnt = 0
    macs = ''
    xml = dom.XMLDesc(0)
    #print 'get_ifaces xml =====> ', xml
    doc = None
    try:
        doc = libxml2.parseDoc(xml)
    except:
        return []
    ctx = doc.xpathNewContext()
    ifaces = []
    try:
        ret = ctx.xpathEval("/domain/devices/interface")

        for node in ret:
            devinf = None
            for child in node.children:
                if child.name == "target":
                    devinf = child.prop("dev")
                    #print 'get_ifaces child.name(target) child.prop(dev) ==> ', devinf

                if child.name == "mac":
                    devmac = child.prop("address")
                    #print 'get_ifaces child.name(mac) child.prop(address) ==> ', devmac
                    #print 'MAC ==> ', devmac.upper()
                    if if_cnt == 0:
                        macs = devmac.upper()
                    else:
                        macs += (',' + devmac.upper())
                    if_cnt += 1

            if devinf != None:
                ifaces.append(devinf)
    finally:
        if ctx != None:
            ctx.xpathFreeContext()
        if doc != None:
            doc.freeDoc()
    return ifaces

def get_disks(dom):
    global t_disk_size
    global disk_cnt

    t_disk_size = 0
    disk_cnt = 0
    xml = dom.XMLDesc(0)
    doc = None
    #print 'get_disks xml =====> ', xml
    try:
        doc = libxml2.parseDoc(xml)
    except:
        return []
    ctx = doc.xpathNewContext()
    disks = []
    try:
        ret = ctx.xpathEval("/domain/devices/disk")
        for node in ret:
            devdsk = None
            for child in node.children:
                if child.name == "target":
                    devdsk = child.prop("dev")
                    #print 'get_disks child.name(target) child.prop(dev) ===> ', devdsk

                if child.name == "source":
                    devsrc = child.prop("file")
                    #print 'get_disks child.name(source) child.prop(file) ===> ', devsrc
                    #print devsrc, 'size ==>', os.path.getsize(devsrc) / 1024 / 1024 / 1024, 'GB'
                    try:
                        t_disk_size += os.path.getsize(devsrc) / 1024 / 1024 / 1024
                    except:
                        t_disk_size += 0
                        print "disk file not found(%s)." % devsrc
                        
                    disk_cnt += 1

            if devdsk != None:
                disks.append(devdsk)
    finally:
        if ctx != None:
            ctx.xpathFreeContext()
        if doc != None:
            doc.freeDoc()
    return disks

def fetch_values(uri):
    conn = libvirt.openReadOnly(uri)
    #print conn.getInfo()
    #print 'processors :', conn.getInfo()[2]
    #print 'hostmem :', conn.getInfo()[1] * 1024 * 1024
    #processors = float(conn.getInfo()[2])
    #hostmem = conn.getInfo()[1] * 1024 * 1024

    cpu_total = 0.0
    mem_total = 0
    mem_total_max = 0

    ids = conn.listDomainsID()

    DEBUG_PRINT = 0

    while 1 :

      STR_SPLIT1 = chr(0x03) + chr(0x1F) + chr(0x7C)
      STR_SPLIT2 = chr(0x03) + chr(0x1F) + chr(0x7E)

      VM_HEAD = "INDEX%sVM_NAME%sVMID%sCORES_P_SOCKET%sALLOC_MEM%sMAC%sBOOT_STATUS%sCPU_USED%sMEM_USED%sMEM_USE%sRX_RATE%sTX_RATE%sNWT_CNT%sDSK_SIZE%sDSK_R_RATE%sDSK_W_RATE%sDSK_CNT%s" % (STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2, STR_SPLIT2)

      VM_INDEX = 0
      VM_DATA = VM_HEAD

      for id in ids:

        VM_INDEX = VM_INDEX + 1

        rd = 0
        wr = 0
        try:
            dom = conn.lookupByID(id)
            name = dom.name()
        except libvirt.libvirtError, err:
            print >>sys.stderr, "Id: %s: %s" % (id, err)
            continue
        if name == "Domain-0":
            continue

        #print 'getType :', conn.getType()
        #print 'numOfNetworks :', conn.numOfNetworks()
        #print 'getInfo :', conn.getInfo()
        #print 'sysinfo:', conn.sysinfo()
        #print 'getCellsFreeMemory :', conn.getCellsFreeMemory()
        #print 'listDefinedDomains :', conn.listDefinedDomains()

        t_state, t_maxMem, t_memory, t_numVirtCpu, t_cpuTime = dom.info()
        #print 'vm vcpus[(index, state, ctime, cpu usage)], [(Affinity)]:', dom.vcpus()
        #print 'vm vcpus[(index, state, ctime, cpu usage)], [(Affinity)]:', dom.vcpus()[0]

        vcpu_usage = 0
        for vcpu in dom.vcpus()[0]:
            #print 'vm vcpu usage :', vcpu[3]
            vcpu_usage += vcpu[3]
        #print 'vm vcpu_usage sum :', vcpu_usage

        #print 'vm info(state, maxMem, memory, numVirtCpu, cpuTime) :', dom.info()
        #print "vm info(%d, %d MB, %d MB, %d, %.2f)" % (t_state, t_maxMem/1024, t_memory/1024, t_numVirtCpu, t_cpuTime/float(1000000))

        #cputime = float(dom.info()[4])
        #cputime_percentage = 1.0e-7 * cputime / processors
        #cpu_total += cputime_percentage
        #print "%s_cputime.value %.0f" % (canon(name), cputime_percentage)
        mem_usage = 0
        mem_usage = dom.info()[2]


        mem_used = 0.0
        mem_used = float(mem_usage / t_memory) * 100.0


        ifaces = get_ifaces(dom)
        #print 'interfaces :', ifaces

        before_rx_bytes = 0
        before_tx_bytes = 0
        before_rx_pakets = 0
        before_tx_pakets = 0
        before_rx_errs = 0
        before_tx_errs = 0
        before_rx_drop = 0
        before_tx_drop = 0
        before_if_time = time.time()
        for iface in ifaces:
            try:
                stats = dom.interfaceStats(iface)
                #print 'interfaces stats :', iface,
                #print stats
                before_rx_bytes += stats[0]
                before_tx_bytes += stats[4]
                before_rx_pakets += stats[1]
                before_tx_pakets += stats[5]
                before_rx_errs += stats[2]
                before_tx_errs += stats[6]
                before_rx_drop += stats[3]
                before_tx_drop += stats[7]
            except TypeError:
                print >> sys.stderr, "Cannot get ifstats for '%s' on '%s'" % (iface, name)

        #print "before rx bytes : %d" % (before_rx_bytes)
        #print "before tx bytes : %d" % (before_tx_bytes)
        #print "before rx pakets : %d" % (before_rx_pakets)
        #print "before tx pakets : %d" % (before_tx_pakets)
        #print "before rx errs : %d" % (before_rx_errs)
        #print "before tx errs : %d" % (before_tx_errs)
        #print "before rx drop : %d" % (before_rx_drop)
        #print "before tx drop : %d" % (before_tx_drop)

        disks = get_disks(dom)
        #print 'listStoragePools :', conn.listStoragePools()
        #print 'listDefinedInterfaces :', conn.listDefinedInterfaces()
        #print 'listDevices :', conn.listDevices('default')
        #print 'disks :', disks

        before_rd_req = 0
        before_wr_req = 0
        before_rd_bytes = 0
        before_wr_bytes = 0
        before_disk_time = time.time()
        for disk in disks:
            try:
                rd_req, rd_bytes, wr_req, wr_bytes, errs = dom.blockStats(disk)
                blkstats = dom.blockStats(disk)
                #print 'blk stats :', disk,
                #print blkstats

                before_rd_req += rd_req
                before_wr_req += wr_req
                before_rd_bytes += rd_bytes
                before_wr_bytes += wr_bytes
            except TypeError:
                print >>sys.stderr, "Cannot get blockstats for '%s' on '%s'" % (disk, name)

        #print "before rd req : %d" % (before_rd_req)
        #print "before wr req : %d" % (before_wr_req)
        #print "before rd bytes : %d" % (before_rd_bytes)
        #print "before wr bytes : %d" % (before_wr_bytes)

        #print "1 time = %d" % time.time()
        time.sleep(1)
        #print "2 time = %d" % time.time()

        #ifaces = get_ifaces(dom)
        #print 'interfaces :', ifaces

        after_rx_bytes = 0
        after_tx_bytes = 0
        after_rx_pakets = 0
        after_tx_pakets = 0
        after_rx_errs = 0
        after_tx_errs = 0
        after_rx_drop = 0
        after_tx_drop = 0
        after_if_time = time.time()

        for iface in ifaces:
            try:
                stats = dom.interfaceStats(iface)
                #print 'interfaces stats :', iface,
                #print stats
                after_rx_bytes += stats[0]
                after_tx_bytes += stats[4]
                after_rx_pakets += stats[1]
                after_tx_pakets += stats[5]
                after_rx_errs += stats[2]
                after_tx_errs += stats[6]
                after_rx_drop += stats[3]
                after_tx_drop += stats[7]
            except TypeError:
                print >> sys.stderr, "Cannot get ifstats for '%s' on '%s'" % (iface, name)

        #print "after rx bytes : %d" % (after_rx_bytes)
        #print "after tx bytes : %d" % (after_tx_bytes)
        #print "after rx pakets : %d" % (after_rx_pakets)
        #print "after tx pakets : %d" % (after_tx_pakets)
        #print "after rx errs : %d" % (after_rx_errs)
        #print "after tx errs : %d" % (after_tx_errs)
        #print "after rx drop : %d" % (after_rx_drop)
        #print "after tx drop : %d" % (after_tx_drop)

        #disks = get_disks(dom)
        #print 'listStoragePools :', conn.listStoragePools()
        #print 'listDefinedInterfaces :', conn.listDefinedInterfaces()
        #print 'listDevices :', conn.listDevices('default')
        #print 'disks :', disks

        after_rd_req = 0
        after_wr_req = 0
        after_rd_bytes = 0
        after_wr_bytes = 0
        after_disk_time = time.time()

        for disk in disks:
            try:
                rd_req, rd_bytes, wr_req, wr_bytes, errs = dom.blockStats(disk)
                blkstats = dom.blockStats(disk)
                #print 'blk stats :', disk,
                #print blkstats

                after_rd_req += rd_req
                after_wr_req += wr_req
                after_rd_bytes += rd_bytes
                after_wr_bytes += wr_bytes
            except TypeError:
                print >>sys.stderr, "Cannot get blockstats for '%s' on '%s'" % (disk, name)
        
        #print "after rd req : %d" % (after_rd_req)
        #print "after wr req : %d" % (after_wr_req)
        #print "after rd bytes : %d" % (after_rd_bytes)
        #print "after wr bytes : %d" % (after_wr_bytes)

        #==========================<vm info>========================================================
        if DEBUG_PRINT == 1 :
            print 'id = ', id
            print 'vm id :', dom.UUIDString()
            print 'vm name :', canon(name)
            print 'vm state : ', t_state
            print "vm vCpu core : %d" % (t_numVirtCpu)
            print "vm MemSize : %d MB" % (t_memory/1024)
            print 'vm vcpu_usage avg : %.2f' % (float(vcpu_usage) / float(t_numVirtCpu))
            print 'mem usage : %d MB' % (mem_usage/1024.0)
            print 'mem used : %.2f' % (mem_used)

            print "interfaces count : %d" % (if_cnt)
            print "interfaces macs : %s" % (macs)
            print "rx bytes/sec : %d" % ((after_rx_bytes - before_rx_bytes) / (after_if_time - before_if_time))
            print "tx bytes/sec : %d" % ((after_tx_bytes - before_tx_bytes) / (after_if_time - before_if_time))
            print "rx pakets/sec : %d" % ((after_rx_pakets - before_rx_pakets) / (after_if_time - before_if_time))
            print "tx pakets/sec : %d" % ((after_tx_pakets - before_tx_pakets) / (after_if_time - before_if_time))
            print "rx errs/sec : %d" % ((after_rx_errs - before_rx_errs) / (after_if_time - before_if_time))
            print "tx errs/sec : %d" % ((after_tx_errs - before_tx_errs) / (after_if_time - before_if_time))
            print "rx drop/sec : %d" % ((after_rx_drop - before_rx_drop) / (after_if_time - before_if_time))
            print "tx drop/sec : %d" % ((after_tx_drop - before_tx_drop) / (after_if_time - before_if_time))

            print "disk count : %d" % disk_cnt
            print "disk total size : %d GB" % t_disk_size
            print "rd req/sec : %d" % ((after_rd_req - before_rd_req) / (after_disk_time - before_disk_time))
            print "wr req/sec : %d" % ((after_wr_req - before_wr_req) / (after_disk_time - before_disk_time))
            print "rd bytes/sec : %d" % ((after_rd_bytes - before_rd_bytes) / (after_disk_time - before_disk_time))
            print "wr bytes/sec : %d" % ((after_wr_bytes - before_wr_bytes) / (after_disk_time - before_disk_time))
        #===========================================================================================

        VM_DATA = VM_DATA + "%s%d%s%s%s%s%s%d%s%d%s%s%s%d%s%.2f%s%.2f%s%d%s%d%s%d%s%d%s%d%s%d%s%d%s%d%s" % (STR_SPLIT1, VM_INDEX, STR_SPLIT2, canon(name), STR_SPLIT2, dom.UUIDString(), STR_SPLIT2, t_numVirtCpu, STR_SPLIT2, t_memory/1024, STR_SPLIT2, macs, STR_SPLIT2, t_state, STR_SPLIT2, float(vcpu_usage) / float(t_numVirtCpu), STR_SPLIT2, mem_used, STR_SPLIT2, mem_usage/1024.0, STR_SPLIT2, (after_rx_bytes - before_rx_bytes) / (after_if_time - before_if_time), STR_SPLIT2, (after_tx_bytes - before_tx_bytes) / (after_if_time - before_if_time), STR_SPLIT2, if_cnt, STR_SPLIT2, t_disk_size, STR_SPLIT2, (after_rd_bytes - before_rd_bytes) / (after_disk_time - before_disk_time), STR_SPLIT2, (after_wr_bytes - before_wr_bytes) / (after_disk_time - before_disk_time), STR_SPLIT2, disk_cnt, STR_SPLIT2)

        if DEBUG_PRINT == 1 :
            print "======================================================================================================="
            print VM_DATA
            print "======================================================================================================="

      data_file = open("../aproc/shell/vm_libvirt.dat", 'w')
      #data_file = open("./vm_libvirt.dat", 'w')
      data_file.write(VM_DATA)
      data_file.close()

      time.sleep(10)
      

def main(sys):
    # KVM Monitoring
    #uri = os.getenv("uri", "qemu:///system")

    # Xen Monitoring
    uri = os.getenv("uri", "xen:///")

    if len(sys) > 1:
        if sys[1] in [ 'autoconf', 'detect' ]:
            if libvirt.openReadOnly(uri):
                print "yes"
                return 0
            else:
                print "no"
                return 1
        elif sys[1] == 'config':
            print_config(uri)
            return 0
    fetch_values(uri)
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))

